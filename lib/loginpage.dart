



import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_local/client-state.dart';
import 'package:ecommerce_local/clienthomepage.dart';
import 'package:ecommerce_local/sellerhomepage.dart';
import 'package:ecommerce_local/adminpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'baseurl.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _message = '';
  bool _isLoggingIn = false;
  bool _obscurePassword = true;

  // Color scheme
  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);
  final Color accentColor = const Color(0xFFFFD700);

  Future<void> _saveAuthData(
    String userId,
    String token,
    String role,
    String? firstName,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
      await prefs.setString('token', token);
      await prefs.setString('role', role);
      if (firstName != null) {
        await prefs.setString('firstName', firstName);
      } else {
        await prefs.remove('firstName');
      }
      print(
        'Saved to SharedPreferences - userId: $userId, role: $role, firstName: $firstName',
      );
    } catch (e) {
      print('Error saving auth data: $e');
    }
  }

  Future<void> _login() async {
    if (_isLoggingIn) return;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoggingIn = true;
        _message = '';
      });

      final url = Uri.parse('$baseUrl/login');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': _email, 'password': _password}),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          final userId = responseData['userId']?.toString();
          final token = responseData['token'];
          final role = responseData['role']?.toString().toLowerCase().trim();
          final firstName = responseData['firstName'] as String?;

          if (userId == null || token == null || role == null) {
            setState(() {
              _message = 'Invalid login response';
              _isLoggingIn = false;
            });
            return;
          }

          // Save auth data for all roles
          await _saveAuthData(userId, token, role, firstName);

          // Update ClientState only for client role
          if (role == 'client') {
            final clientState = Provider.of<ClientState>(
              context,
              listen: false,
            );
            await clientState.updateAuthData(userId, token, role);
          }

          if (!mounted) return;

          // Navigate based on role
          switch (role) {
            case 'client':
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => ClientHomePage()),
                (route) => false,
              );
              break;
            case 'seller':
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => SellerHomePage(sellerId: userId, token: token),
                ),
                (route) => false,
              );
              break;
            case 'admin':
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminPage(adminId: userId, token: token),
                ),
                (route) => false,
              );
              break;
            default:
              setState(() {
                _message = 'Unknown role: $role';
                _isLoggingIn = false;
              });
          }
        } else {
          setState(() {
            _message = responseData['error'] ?? 'Login failed';
            _isLoggingIn = false;
          });
        }
      } catch (error) {
        setState(() {
          _message = 'Connection error';
          _isLoggingIn = false;
        });
      }
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: Stack(
        children: [
          // Background circles
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 600,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(1),
                    primaryColor.withOpacity(1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 850,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(1),
                    primaryColor.withOpacity(1),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Content
          Positioned(
            top: 50,
            left: 30,
            child: Text(
              'Log In',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  const Shadow(
                    color: Colors.black26,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 120),
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        hintText: 'email@test.com',
                        hintStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      style: GoogleFonts.poppins(fontSize: 14),
                      validator: (value) {
                        if (value!.isEmpty) return 'Enter your email';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                      onSaved: (value) => _email = value!,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        hintText: '••••••••',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      style: GoogleFonts.poppins(fontSize: 14),
                      obscureText: _obscurePassword,
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Enter your password' : null,
                      onSaved: (value) => _password = value!,
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoggingIn ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          backgroundColor: primaryColor,
                        ),
                        child:
                            _isLoggingIn
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'Log In',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        
                         const SizedBox(width: 3),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                text: "Forgot Password?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 18,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(context, '/forgot-password');
                                  },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                            children: <TextSpan>[
                              // const TextSpan(text: "Create new account? "),
                              TextSpan(
                                text: "Create new account",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                   fontSize: 18,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(context, '/signup');
                                  },
                              ),
                            ],
                          ),
                        ),
                        
                         const SizedBox(width: 3),
                      
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_message.isNotEmpty)
                      Center(
                        child: Text(
                          _message,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
}