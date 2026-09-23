import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;

  String get initials {
    final names = name.trim().split(RegExp(r'\s+'));
    if (names.isEmpty || names.first.isEmpty) return '?';
    if (names.length == 1) return names.first[0].toUpperCase();
    return (names.first[0] + names.last[0]).toUpperCase();
  }

  @override
  List<Object?> get props => [id, name, email];
}

class AuthSession extends Equatable {
  const AuthSession({required this.token, required this.user});

  final String token;
  final User user;

  @override
  List<Object?> get props => [token, user];
}