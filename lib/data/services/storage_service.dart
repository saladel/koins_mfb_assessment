import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/product_model.dart';
import '../models/savings_plan_model.dart';
import '../models/user_model.dart';

/// Local persistence, backed by Hive.
///
/// Objects are stored as encoded JSON strings rather than through generated
/// TypeAdapters. That keeps `build_runner` and `hive_ce_generator` out of the
/// project, and it sidesteps Hive's `Map<dynamic, dynamic>` cast problem when
/// reading back nested maps.
///
/// Four boxes:
///   `user_box`     -> key `current_user`, value: encoded [UserModel]
///   `savings_box`  -> key: plan id,       value: encoded [SavingsPlanModel]
///   `products_box` -> key `catalogue`,    value: encoded product array
///   `pending_box`  -> key: plan id,       value: ISO timestamp queued at
///
/// `pending_box` is the outbox. A plan created while the server is
/// unreachable lands in `savings_box` immediately so the user never loses it,
/// and its id goes here so the sync service knows to retry the POST.
class StorageService {
  StorageService(
    this._userBox,
    this._savingsBox,
    this._productsBox,
    this._pendingBox,
  );

  static const String userBoxName = 'user_box';
  static const String savingsBoxName = 'savings_box';
  static const String productsBoxName = 'products_box';
  static const String pendingBoxName = 'pending_box';

  static const String _currentUserKey = 'current_user';
  static const String _catalogueKey = 'catalogue';
  static const String _biometricKey = 'biometric_enabled';

  bool get isBiometricEnabled => _userBox.get(_biometricKey) == 'true';

  Future<void> setBiometricEnabled(bool enabled) =>
      _userBox.put(_biometricKey, enabled.toString());

  final Box<String> _userBox;
  final Box<String> _savingsBox;
  final Box<String> _productsBox;
  final Box<String> _pendingBox;

  /// Opens Hive and every box. Call this once from `main()` before `runApp`.
  static Future<StorageService> initialise() async {
    await Hive.initFlutter();

    final List<Box<String>> boxes = await Future.wait(<Future<Box<String>>>[
      Hive.openBox<String>(userBoxName),
      Hive.openBox<String>(savingsBoxName),
      Hive.openBox<String>(productsBoxName),
      Hive.openBox<String>(pendingBoxName),
    ]);

    return StorageService(boxes[0], boxes[1], boxes[2], boxes[3]);
  }

  // User
  UserModel? readUser() {
    final String? raw = _userBox.get(_currentUserKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserModel.fromRaw(raw);
    } catch (_) {
      // Corrupt entry: drop it rather than crashing on launch.
      _userBox.delete(_currentUserKey);
      return null;
    }
  }

  Future<void> saveUser(UserModel user) =>
      _userBox.put(_currentUserKey, user.toRaw());

  Future<void> clearUser() async {
    await _userBox.clear();
    await _savingsBox.clear();
    await _productsBox.clear();
    await _pendingBox.clear();
  }

  /// Alias for clearing all local Hive boxes on logout.
  Future<void> clearAll() => clearUser();

  bool get hasUser => readUser() != null;

  // Savings plans
  bool get hasSavingsPlans => _savingsBox.isNotEmpty;

  List<SavingsPlanModel> readSavingsPlans() {
    final List<SavingsPlanModel> plans = <SavingsPlanModel>[];
    for (final String raw in _savingsBox.values) {
      try {
        plans.add(SavingsPlanModel.fromRaw(raw));
      } catch (_) {
        // Skip unreadable entries instead of failing the whole read.
        continue;
      }
    }
    plans.sort(
      (SavingsPlanModel a, SavingsPlanModel b) =>
          b.createdAt.compareTo(a.createdAt),
    );
    return plans;
  }

  SavingsPlanModel? readSavingsPlan(String id) {
    final String? raw = _savingsBox.get(id);
    if (raw == null || raw.isEmpty) return null;
    try {
      return SavingsPlanModel.fromRaw(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSavingsPlan(SavingsPlanModel plan) =>
      _savingsBox.put(plan.id, plan.toRaw());

  Future<void> saveSavingsPlans(List<SavingsPlanModel> plans) {
    return _savingsBox.putAll(<String, String>{
      for (final SavingsPlanModel plan in plans) plan.id: plan.toRaw(),
    });
  }

  Future<void> deleteSavingsPlan(String id) => _savingsBox.delete(id);

  Future<void> clearSavingsPlans() => _savingsBox.clear();

  // Cached product catalogue
  /// Last catalogue successfully fetched from the server, or an empty list if
  /// the app has never managed a successful fetch.
  List<ProductModel> readCachedProducts() {
    final String? raw = _productsBox.get(_catalogueKey);
    if (raw == null || raw.isEmpty) return const <ProductModel>[];

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) return const <ProductModel>[];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList(growable: false);
    } catch (_) {
      _productsBox.delete(_catalogueKey);
      return const <ProductModel>[];
    }
  }

  Future<void> saveCachedProducts(List<ProductModel> products) {
    final String raw = jsonEncode(
      products.map((ProductModel p) => p.toJson()).toList(growable: false),
    );
    return _productsBox.put(_catalogueKey, raw);
  }

  /// Ids of plans waiting to be POSTed, oldest first.
  List<String> pendingPlanIds() {
    final List<MapEntry<String, String>> entries = _pendingBox
        .toMap()
        .entries
        .map(
          (MapEntry<dynamic, String> e) =>
              MapEntry<String, String>(e.key.toString(), e.value),
        )
        .toList();

    entries.sort(
      (MapEntry<String, String> a, MapEntry<String, String> b) =>
          a.value.compareTo(b.value),
    );

    return entries
        .map((MapEntry<String, String> e) => e.key)
        .toList(growable: false);
  }

  bool get hasPendingPlans => _pendingBox.isNotEmpty;

  int get pendingPlanCount => _pendingBox.length;

  Future<void> queuePlan(String id) =>
      _pendingBox.put(id, DateTime.now().toIso8601String());

  Future<void> dequeuePlan(String id) => _pendingBox.delete(id);
}
