


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('token');
      await prefs.remove('role');
      await prefs.remove('firstName');
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
    }
  }

  static Future<void> logout(BuildContext context, String token) async {
    await clearAuthData();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}