import 'dart:convert';

/// The signed-in user.
///
/// [fromJson]/[toJson] double as the Hive storage format: we persist the
/// encoded JSON string rather than generating a TypeAdapter, which keeps the
/// project free of build_runner and codegen.
class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl = '',
    this.totalSavings = 0,
  });

  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;

  /// Remote profile picture. Empty means fall back to initials.
  final String avatarUrl;

  final double totalSavings;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      totalSavings: (json['totalSavings'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'avatarUrl': avatarUrl,
        'totalSavings': totalSavings,
      };

  /// Decodes the string shape stored in Hive.
  factory UserModel.fromRaw(String raw) =>
      UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  /// Encodes to the string shape stored in Hive.
  String toRaw() => jsonEncode(toJson());

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    double? totalSavings,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalSavings: totalSavings ?? this.totalSavings,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          other.id == id &&
          other.fullName == fullName &&
          other.email == email &&
          other.phoneNumber == phoneNumber &&
          other.avatarUrl == avatarUrl &&
          other.totalSavings == totalSavings;

  @override
  int get hashCode =>
      Object.hash(id, fullName, email, phoneNumber, avatarUrl, totalSavings);

  @override
  String toString() => 'UserModel(id: $id, email: $email)';
}
