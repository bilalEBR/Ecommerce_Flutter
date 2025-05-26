// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'baseurl.dart';
// import 'loginpage.dart';

// class OTPVerificationPage extends StatefulWidget {
//   final String email;

//   const OTPVerificationPage({super.key, required this.email});

//   @override
//   _OTPVerificationPageState createState() => _OTPVerificationPageState();
// }

// class _OTPVerificationPageState extends State<OTPVerificationPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _otpController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;

//   final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);
//   final Color accentColor = const Color(0xFFFFD700);

//   Future<void> _verifyOTP() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/verify-otp/verify-otp/'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email': widget.email,
//           'otp': _otpController.text,
//         }),
//       ).timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final newPassword = data['newPassword'];
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => AlertDialog(
//             title: Text(
//               'Password Reset Successful',
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: primaryColor,
//               ),
//             ),
//             content: Text(
//               'Your new password is: $newPassword\nPlease use it to log in.',
//               style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
//             ),
//             actions: [
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Close dialog
//                   Navigator.of(context).pushAndRemoveUntil(
//                     MaterialPageRoute(builder: (context) => const LoginPage()),
//                     (route) => false,
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryColor,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   'OK',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       } else {
//         setState(() {
//           _errorMessage = 'Invalid OTP: ${jsonDecode(response.body)['error'] ?? 'Unknown error'}';
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
//     _otpController.dispose();
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
//                 'Verify OTP',
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
//                       const SizedBox(height: 200),
//                       Text(
//                         'Enter the 6-digit OTP sent to ${widget.email}.',
//                         style: GoogleFonts.poppins(fontSize: 14, color: const Color.fromARGB(255, 172, 241, 24)),
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _otpController,
//                         decoration: InputDecoration(
//                           labelText: 'OTP',
//                           labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                           hintText: '123456',
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
//                         keyboardType: TextInputType.number,
//                         style: GoogleFonts.poppins(fontSize: 14),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) return 'Enter the OTP';
//                           if (!RegExp(r'^\d{6}$').hasMatch(value)) {
//                             return 'Enter a valid 6-digit OTP';
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
//                           onPressed: _isLoading ? null : _verifyOTP,
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
//                                   'Verify',
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
import 'baseurl.dart';
import 'loginpage.dart';

class OTPVerificationPage extends StatefulWidget {
  final String email;

  const OTPVerificationPage({super.key, required this.email});

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);
  final Color accentColor = const Color(0xFFFFD700);

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp/verify-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'otp': _otpController.text,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newPassword = data['newPassword'];
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(
              'Password Reset Successful',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            content: Text(
              'Your new password is: $newPassword\nPlease use it to log in.',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
            ),
            actions: [
  ElevatedButton(
    onPressed: () {
      Navigator.of(context).pop(); // Close dialog
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ), // Added missing parenthesis
    ),
    child: Text(
      'OK',
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
],
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid OTP: ${jsonDecode(response.body)['error'] ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
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

            // Title
            Positioned(
              top: 50,
              left: 30,
              child: Text(
                'Verify OTP',
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

            // Form Container
            Positioned(
              top: MediaQuery.of(context).size.height * 0.18,
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
                            'OTP Verification',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter the 6-digit OTP sent to ${widget.email}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // OTP Field
                          TextFormField(
                            controller: _otpController,
                            decoration: InputDecoration(
                              labelText: 'OTP Code',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              hintText: '123456',
                              prefixIcon: Icon(
                                Icons.lock_outline,
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
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(fontSize: 14),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter OTP';
                              }
                              if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                                return 'Enter a valid 6-digit OTP';
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

                          // Verify Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _verifyOTP,
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
                                      'Verify OTP',
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