// lib/features/admin/data/auth_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  static final _supabase = Supabase.instance.client;

  // Iniciar sesión
  static Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Correo o contraseña incorrectos.');
    }
  }

  // Cerrar sesión
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Verificar si hay sesión activa
  static bool get isUserLoggedIn {
    return _supabase.auth.currentUser != null;
  }
}