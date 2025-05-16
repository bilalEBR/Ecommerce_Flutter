
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/gestures.dart';
// import 'baseurl.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   _SignupPageState createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final _formKey = GlobalKey<FormState>();
//   String _firstName = '';
//   String _lastName = '';
//   String _email = '';
//   String _password = '';
//   String _confirmPassword = '';
//   // ignore: prefer_final_fields
//   String _role ='client';
//   String _message = '';
//   bool _isLoading = false;

//   // Dynamic base URL (adjust for emulator or production)
//   // static const String baseUrl = 'http://localhost:3000';

//   Future<void> _signup() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();

//       if (_password != _confirmPassword) {
//         setState(() {
//           _message = 'Passwords do not match';
//         });
//         return;
//       }

//       setState(() => _isLoading = true);
//       final url = Uri.parse('$baseUrl/signup');
//       try {
//         final response = await http.post(
//           url,
//           headers: {'Content-Type': 'application/json'},

//           body: jsonEncode({
//             'firstName': _firstName,
//             'lastName': _lastName,
//             'email': _email,
//             'password': _password,
//             'role': _role,
//           }),

          
//         );

//         final responseData = jsonDecode(response.body);
//         setState(() {
//           if (response.statusCode == 201) {
//             showDialog(
//               context: context,
//               barrierDismissible: false,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   title: const Text(
//                     'Signup Successful!',
//                     style: TextStyle(
//                       color: Color(0xFFAB47BC),
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   actions: [
//                     Center(
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                           Navigator.pushNamed(context, '/login');
//                         },
//                         child: const Text(
//                           'OK',
//                           style: TextStyle(
//                             color: Color(0xFFAB47BC),
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             );
//             _message = ''; // Clear message on success
//           } else {
//             _message = responseData['error'] ?? 'Signup failed';
//           }
//         });



        
//       } catch (error) {
//         setState(() {
//           _message = 'Error: $error';
//         });
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Positioned(
//               top: -100,
//               left: -100,
//               child: Container(
//                 width: 300,
//                 height: 300,
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [
//                       // Color(0xFF4CAF50),
//                       // Color(0xFF81C784),
//                        Color.fromARGB(255, 162, 82, 176),
//                       Color.fromARGB(255, 218, 111, 237),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//               ),
//             ),

// Positioned(
//               top: -100,
//               left: -100,
//               child: Container(
//                 width: 600,
//                 height: 200,
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [
//                       // Color(0xFF4CAF50),
//                       // Color(0xFF81C784),
//                        Color.fromARGB(255, 202, 101, 220),
//                       Color.fromARGB(255, 218, 111, 237),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//               ),
//             ),


// Positioned(
//               top: -100,
//               left: -100,
//               child: Container(
//                 width: 850,
//                 height: 150,
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [
//                       // Color(0xFF4CAF50),
//                       // Color(0xFF81C784),
//                        Color.fromARGB(255, 230, 102, 252),
//                       Color.fromARGB(255, 218, 111, 237),
//                     ],
//                     begin: Alignment.topRight,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 50,
//               left: 30,
//               child: Text(
//                 'Create Account',
//                 style: GoogleFonts.poppins(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: const Color.fromARGB(255, 249, 239, 239),
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
//                       const SizedBox(height: 120),
//                       const Text(
//                         'First Name',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         decoration: InputDecoration(
//                           hintText: 'Enter your first name',
//                           hintStyle: const TextStyle(color: Colors.grey),
//                           filled: true,
//                           fillColor: const Color(0xFFE0E0E0),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Color(0xFFAB47BC), width: 2),
//                           ),
//                           errorBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.red, width: 2),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                             vertical: 16,
//                             horizontal: 20,
//                           ),
//                         ),
//                         validator: (value) =>
//                             value!.isEmpty ? 'Enter your first name' : null,
//                         onSaved: (value) => _firstName = value!,
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Last Name',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         decoration: InputDecoration(
//                           hintText: 'Enter your last name',
//                           hintStyle: const TextStyle(color: Colors.grey),
//                           filled: true,
//                           fillColor: const Color(0xFFE0E0E0),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Color(0xFFAB47BC), width: 2),
//                           ),
//                           errorBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.red, width: 2),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                             vertical: 16,
//                             horizontal: 20,
//                           ),
//                         ),
//                         validator: (value) =>
//                             value!.isEmpty ? 'Enter your last name' : null,
//                         onSaved: (value) => _lastName = value!,
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Email',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         decoration: InputDecoration(
//                           hintText: 'email@test.com',
//                           hintStyle: const TextStyle(color: Colors.grey),
//                           filled: true,
//                           fillColor: const Color(0xFFE0E0E0),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Color(0xFFAB47BC), width: 2),
//                           ),
//                           errorBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.red, width: 2),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                             vertical: 16,
//                             horizontal: 20,
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value!.isEmpty) return 'Enter your email';
//                           if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                             return 'Enter a valid email';
//                           }
//                           return null;
//                         },
//                         onSaved: (value) => _email = value!,
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Password',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         decoration: InputDecoration(
//                           hintText: '••••••••',
//                           hintStyle: const TextStyle(color: Colors.grey),
//                           filled: true,
//                           fillColor: const Color(0xFFE0E0E0),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Color(0xFFAB47BC), width: 2),
//                           ),
//                           errorBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.red, width: 2),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                             vertical: 16,
//                             horizontal: 20,
//                           ),
//                         ),
//                         obscureText: true,
//                         validator: (value) =>
//                             value!.isEmpty ? 'Enter your password' : null,
//                         onSaved: (value) => _password = value!,
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'RePassword',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         decoration: InputDecoration(
//                           hintText: '••••••••',
//                           hintStyle: const TextStyle(color: Colors.grey),
//                           filled: true,
//                           fillColor: const Color(0xFFE0E0E0),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Color(0xFFAB47BC), width: 2),
//                           ),
//                           errorBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.red, width: 2),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                             vertical: 16,
//                             horizontal: 20,
//                           ),
//                         ),
//                         obscureText: true,
//                         validator: (value) =>
//                             value!.isEmpty ? 'Confirm your password' : null,
//                         onSaved: (value) => _confirmPassword = value!,
//                       ),
//                       const SizedBox(height: 32),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _isLoading ? null : _signup,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             elevation: 8,
//                             backgroundColor: Color(0xFFAB47BC),
//                           ),
//                           child: _isLoading
//                               ? const CircularProgressIndicator(color: Colors.white)
//                               : Text(
//                                   'SignUp',
//                                   textAlign: TextAlign.center,
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Center(
//                         child: RichText(
//                           text: TextSpan(
//                             style: const TextStyle(
//                               fontSize: 16,
//                               color: Colors.black,
//                             ),
//                             children: <TextSpan>[
//                               const TextSpan(text: "Already have an account? "),
//                               TextSpan(
//                                 text: "Login",
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFFAB47BC),
//                                 ),
//                                 recognizer: TapGestureRecognizer()
//                                   ..onTap = () {
//                                     Navigator.pushNamed(context, '/login');
//                                   },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       if (_message.isNotEmpty)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 16.0),
//                           child: Text(
//                             _message,
//                             style: TextStyle(
//                               color: _message.contains('successful')
//                                   ? Color(0xFFAB47BC)
//                                   : Colors.red,
//                               fontSize: 14,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
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

// version ui

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'baseurl.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _role = 'client';
  String _message = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Color scheme
  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);
  final Color accentColor = const Color(0xFFFFD700);

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_password != _confirmPassword) {
        setState(() {
          _message = 'Passwords do not match';
        });
        return;
      }

      setState(() => _isLoading = true);
      final url = Uri.parse('$baseUrl/signup');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'firstName': _firstName,
            'lastName': _lastName,
            'email': _email,
            'password': _password,
            'role': _role,
          }),
        );

        final responseData = jsonDecode(response.body);
        setState(() {
          if (response.statusCode == 201) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    'Signup Successful!',
                    style: GoogleFonts.poppins(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          'OK',
                          style: GoogleFonts.poppins(
                            color: primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
            _message = '';
          } else {
            _message = responseData['error'] ?? 'Signup failed';
          }
        });
      } catch (error) {
        setState(() {
          _message = 'Error: $error';
        });
      } finally {
        setState(() => _isLoading = false);
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
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.9),
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
                'Create Account',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 249, 239, 239),
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 120),
                      const Text(
                        'First Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                          hintText: 'Enter your first name',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryColor, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
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
                        validator: (value) =>
                            value!.isEmpty ? 'Enter your first name' : null,
                        onSaved: (value) => _firstName = value!,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Last Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                          hintText: 'Enter your last name',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryColor, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
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
                        validator: (value) =>
                            value!.isEmpty ? 'Enter your last name' : null,
                        onSaved: (value) => _lastName = value!,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                          hintText: 'email@test.com',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryColor, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
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
                          labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
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
                            borderSide: BorderSide(color: primaryColor, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
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
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
                        validator: (value) =>
                            value!.isEmpty ? 'Enter your password' : null,
                        onSaved: (value) => _password = value!,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'RePassword',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
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
                            borderSide: BorderSide(color: primaryColor, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
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
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              color: primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        style: GoogleFonts.poppins(fontSize: 14),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) =>
                            value!.isEmpty ? 'Confirm your password' : null,
                        onSaved: (value) => _confirmPassword = value!,
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            backgroundColor: primaryColor,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'SignUp',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              const TextSpan(text: "Already have an account? "),
                              TextSpan(
                                text: "Login",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(context, '/login');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_message.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _message,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
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