import 'dart:convert';

/// savings product the user can open a plan against.
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.interestRate,
    required this.duration,
    required this.minimumDeposit,
    required this.description,
  });

  final String id;
  final String name;

  /// Annual interest rate as a percentage, for example `12` meaning 12%.
  final double interestRate;

  /// Human readable term, for example `12 Months` or `Flexible`.
  final String duration;

  final double minimumDeposit;
  final String description;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0,
      duration: json['duration'] as String? ?? 'Flexible',
      minimumDeposit: (json['minimumDeposit'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'interestRate': interestRate,
    'duration': duration,
    'minimumDeposit': minimumDeposit,
    'description': description,
  };

  factory ProductModel.fromRaw(String raw) =>
      ProductModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  String toRaw() => jsonEncode(toJson());

  /// Case-insensitive match used by the products search field.
  bool matches(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q) ||
        duration.toLowerCase().contains(q);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProductModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ProductModel(id: $id, name: $name)';
}
