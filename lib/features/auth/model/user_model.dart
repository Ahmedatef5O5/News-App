import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String email;
  final String? phone;
  final bool emailConfirmed;
  final DateTime? lastSignIn;

  const UserModel({
    required this.id,
    required this.email,
    this.phone,
    this.emailConfirmed = false,
    this.lastSignIn,
  });

  factory UserModel.fromSupabaseUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      phone: user.phone,
      emailConfirmed: user.emailConfirmedAt != null,
      lastSignIn: user.lastSignInAt != null
          ? DateTime.tryParse(user.lastSignInAt!)
          : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    bool? emailConfirmed,
    DateTime? lastSignIn,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      emailConfirmed: emailConfirmed ?? this.emailConfirmed,
      lastSignIn: lastSignIn ?? this.lastSignIn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserModel(id: $id, email: $email)';
}
