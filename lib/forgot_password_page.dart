// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'otp_verification_page.dart';
// import 'baseurl.dart';

// class ForgotPasswordPage extends StatefulWidget {
//   const ForgotPasswordPage({super.key});

//   @override
//   _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
// }

// class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;

//   final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);
//   final Color accentColor = const Color(0xFFFFD700);

//   Future<void> _sendOTP() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/forgot-password/forgot-password'),
//         headers: {'Content-Type': 'application/json'},  
//         body: jsonEncode({'email': _emailController.text}),
//       ).timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OTPVerificationPage(email: _emailController.text),
//           ),
//         );
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'OTP sent to ${_emailController.text}',
//               style: GoogleFonts.poppins(fontSize: 14),
//             ),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 4),
//           ),
//         );
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to send OTP: ${jsonDecode(response.body)['error'] ?? 'Unknown error'}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Connection error: $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             // Background circles (matching LoginPage)
//             Positioned(
//               top: -100,
//               left: -100,
//               child: Container(
//                 width: 300,
//                 height: 300,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [primaryColor, primaryColor.withOpacity(0.9)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               top: -100,
//               left: -100,
//               child: Container(
//                 width: 600,
//                 height: 200,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [primaryColor.withOpacity(1), primaryColor.withOpacity(1)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               top: -100,
//               left: -100,
//               child: Container(
//                 width: 850,
//                 height: 150,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [primaryColor.withOpacity(1), primaryColor.withOpacity(1)],
//                     begin: Alignment.topRight,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//               ),
//             ),
//             // Content
//             Positioned(
//               top: 50,
//               left: 30,
//               child: Text(
//                 'Forgot Password',
//                 style: GoogleFonts.poppins(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   shadows: [
//                     const Shadow(
//                       color: Colors.black26,
//                       offset: Offset(2, 2),
//                       blurRadius: 4,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//               child: Form(
//                 key: _formKey,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 150),
//                       Text(
//                         'Enter your email to receive a one-time password (OTP).',
//                         style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _emailController,
//                         decoration: InputDecoration(
//                           labelText: 'Email',
//                           labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                           hintText: 'email@test.com',
//                           hintStyle: const TextStyle(color: Colors.white),
//                           filled: true,
//                           fillColor: Colors.grey[100],
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide.none,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(color: primaryColor, width: 1),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(color: primaryColor, width: 1.5),
//                           ),
//                           errorBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide(color: Colors.red, width: 2),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                         ),
//                         style: GoogleFonts.poppins(fontSize: 14),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) return 'Enter your email';
//                           if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                             return 'Enter a valid email';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       if (_errorMessage != null)
//                         Center(
//                           child: Text(
//                             _errorMessage!,
//                             style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
//                           ),
//                         ),
//                       const SizedBox(height: 16),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _isLoading ? null : _sendOTP,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             elevation: 8,
//                             backgroundColor: primaryColor,
//                           ),
//                           child: _isLoading
//                               ? const CircularProgressIndicator(color: Colors.white)
//                               : Text(
//                                   'Send',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// ui
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'otp_verification_page.dart';
import 'baseurl.dart';
import 'loginpage.dart'; // Make sure this import exists

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);
  final Color accentColor = const Color(0xFFFFD700);

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationPage(email: _emailController.text),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'OTP sent to ${_emailController.text}',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to send OTP: ${jsonDecode(response.body)['error'] ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        // _errorMessage = 'Connection error: $e';
         _errorMessage = 'Connection error ';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
                    colors: [primaryColor.withOpacity(1), primaryColor.withOpacity(1)],
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
                    colors: [primaryColor.withOpacity(1), primaryColor.withOpacity(1)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Back Button
            // Positioned(
            //   top: 20,
            //   left: 20,
            //   child: IconButton(
            //     icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
            //     onPressed: () => Navigator.of(context).pop(),
            //   ),
            // ),

            // Title (shifted up slightly)
            Positioned(
              top: 50,
              left: 30,
              child: Text(
                'Forgot Password',
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

            // Form Container (shifted up)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.18, // Adjusted upward
              left: 0,
              right: 0,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.98),
                        ],
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reset Password',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your email to receive a one-time password (OTP)',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              hintText: 'example@test.com',
                              prefixIcon: Icon(
                                Icons.email,
                                color: primaryColor,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: primaryColor,
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                            ),
                            style: GoogleFonts.poppins(fontSize: 14),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Error Message
                          if (_errorMessage != null)
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          const SizedBox(height: 24),

                          // Send Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _sendOTP,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: primaryColor,
                                elevation: 5,
                                shadowColor: primaryColor.withOpacity(0.3),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      'Send OTP',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Back to Login Text Button
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Back to Login',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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