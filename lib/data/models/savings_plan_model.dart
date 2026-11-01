import 'dart:convert';

/// savings plan owned by the user, either seeded or created in-app.
class SavingsPlanModel {
  const SavingsPlanModel({
    required this.id,
    required this.name,
    required this.productType,
    required this.amount,
    required this.targetAmount,
    required this.monthlyContribution,
    required this.frequency,
    required this.duration,
    required this.createdAt,
    this.isSynced = true,
  });

  final String id;
  final String name;

  /// Name of the [ProductModel] this plan was opened against.
  final String productType;

  /// Amount saved so far.
  final double amount;

  final double targetAmount;
  final double monthlyContribution;

  /// `Monthly`, `Weekly` or `Daily`.
  final String frequency;

  /// Human readable term, for example `12 Months`.
  final String duration;

  final DateTime createdAt;

  /// False while the plan exists locally but has not reached the server.
  ///
  /// Plans created offline are stored immediately and queued in the outbox.
  /// The sync service flips this to true once the POST succeeds. Anything
  /// loaded from the server is synced by definition, so this defaults to true.
  final bool isSynced;

  /// Progress towards [targetAmount], clamped to 0..1 so the progress bar is
  /// always safe to render.
  double get progress {
    if (targetAmount <= 0) return 0;
    return (amount / targetAmount).clamp(0.0, 1.0);
  }

  factory SavingsPlanModel.fromJson(Map<String, dynamic> json) {
    return SavingsPlanModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      productType: json['productType'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
      monthlyContribution:
          (json['monthlyContribution'] as num?)?.toDouble() ?? 0,
      frequency: json['frequency'] as String? ?? 'Monthly',
      duration: json['duration'] as String? ?? 'Flexible',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'productType': productType,
    'amount': amount,
    'targetAmount': targetAmount,
    'monthlyContribution': monthlyContribution,
    'frequency': frequency,
    'duration': duration,
    'createdAt': createdAt.toIso8601String(),
    'isSynced': isSynced,
  };

  /// Body sent to the server on create. The local sync flag is not part of
  /// the API contract, so it is stripped here.
  Map<String, dynamic> toCreateRequest() {
    final Map<String, dynamic> json = toJson();
    json.remove('isSynced');
    return json;
  }

  factory SavingsPlanModel.fromRaw(String raw) =>
      SavingsPlanModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  String toRaw() => jsonEncode(toJson());

  SavingsPlanModel copyWith({
    String? id,
    String? name,
    String? productType,
    double? amount,
    double? targetAmount,
    double? monthlyContribution,
    String? frequency,
    String? duration,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return SavingsPlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      productType: productType ?? this.productType,
      amount: amount ?? this.amount,
      targetAmount: targetAmount ?? this.targetAmount,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SavingsPlanModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SavingsPlanModel(id: $id, name: $name)';
}
