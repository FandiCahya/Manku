import 'package:equatable/equatable.dart';
import '../../domain/auth_models.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final String message;
  const AuthLoading({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthOtpSent extends AuthState {
  final String email;
  const AuthOtpSent({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthFailure extends AuthState {
  final String error;
  const AuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
