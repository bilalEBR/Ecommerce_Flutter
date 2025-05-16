// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

// class AuthService {
//   static Future<void> clearAuthData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('userId');
//       await prefs.remove('token');
//       await prefs.remove('role');
//       await prefs.remove('firstName');
//     } catch (e) {
//       debugPrint('Error clearing auth data: $e');
//     }
//   }

//   static Future<void> logout(BuildContext context, String token) async {
//     // Optional: Call backend logout endpoint
//     try {
//       final response = await http.post(
//         Uri.parse('http://localhost:3000/auth/logout'),
//         headers: {'Authorization': 'Bearer $token'},
//       );
//       print('Logout API Response: ${response.statusCode} - ${response.body}');
//     } catch (e) {
//       print('Error calling logout endpoint: $e');
//     }

//     await clearAuthData();
//     Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//   }
// }



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