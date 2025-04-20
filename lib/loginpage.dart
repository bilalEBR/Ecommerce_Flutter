// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/gestures.dart';
// import 'package:ecommerce_local/sellerhomepage.dart';
// import 'package:ecommerce_local/adminpage.dart';
// import 'package:provider/provider.dart';
// import 'package:ecommerce_local/client-state.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   String _email = '';
//   String _password = '';
//   String _message = '';



//  Future<void> _login() async {
//   if (_formKey.currentState!.validate()) {
//     _formKey.currentState!.save();

//     final url = Uri.parse('http://localhost:3000/login');
//     try {
//       print('Sending login request to: $url');
//       print('Request body: ${jsonEncode({'email': _email, 'password': _password})}');

//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': _email, 'password': _password}),
//       );

//       print('Response status code: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.headers['content-type']?.contains('application/json') ?? false) {
//         final responseData = jsonDecode(response.body);

//         setState(() {
//           if (response.statusCode == 200) {
//             final userId = responseData['userId']?.toString();
//             final token = responseData['token'];
//             final role = responseData['role']?.trim();

//             if (userId == null || token == null || role == null) {
//               _message = 'Invalid login response: missing userId, token, or role';
//               print('Login response missing data: $responseData');
//               return;
//             }

//             final clientState = Provider.of<ClientState>(context, listen: false);
//             clientState.updateUserId(userId);
//             clientState.updateToken(token);
//             print('After login - userId: ${clientState.userId}, token: ${clientState.token}, role: $role');

//             if (role == 'client') {
//               Navigator.pushReplacementNamed(context, '/clientpage');
//             } else if (role == 'seller') {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SellerHomePage(
//                     sellerId: userId,
//                     token: token,
//                   ),
//                 ),
//               );
//             } else if (role == 'admin') {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => AdminPage(adminId: userId),
//                 ),
//               );
//             } else {
//               _message = 'Unknown role: ${responseData['role']}';
//             }
//           } else if (response.statusCode == 401) {
//             _message = 'Invalid email or password';
//           } else {
//             _message = responseData['error'] ?? 'Unknown error';
//           }
//         });
//       } else {
//         setState(() {
//           _message = 'Unexpected response format (not JSON): ${response.body.substring(0, 50)}...';
//         });
//       }
//     } catch (error) {
//       print('Error during login: $error');
//       setState(() {
//         _message = 'Error: $error';
//       });
//     }
//   }
// }

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
//                       Color(0xFFAB47BC),
//                       Color.fromARGB(255, 218, 111, 237),
//                     ],
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
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [
//                       Color.fromARGB(255, 202, 101, 220),
//                       Color.fromARGB(255, 218, 111, 237),
//                     ],
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
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [
//                       Color.fromARGB(255, 230, 102, 252),
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
//                 'Log In',
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
//                       const SizedBox(height: 120),
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
//                       const SizedBox(height: 32),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _login,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             elevation: 8,
//                             backgroundColor: Color(0xFFAB47BC),
//                           ),
//                           child: Text(
//                             'Log In',
//                             textAlign: TextAlign.center,
//                             style: GoogleFonts.poppins(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       SizedBox(
//                         child: Center(
//                           child: RichText(
//                             text: TextSpan(
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.black,
//                               ),
//                               children: <TextSpan>[
//                                 TextSpan(text: "Don't have an account? "),
//                                 TextSpan(
//                                   text: "Sign Up",
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFFAB47BC),
//                                   ),
//                                   recognizer: TapGestureRecognizer()..onTap = () {
//                                     Navigator.pushNamed(context, '/signup');
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       if (_message.isNotEmpty)
//                         Center(
//                           child: Text(
//                             _message,
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
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



// version admin route 

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:ecommerce_local/sellerhomepage.dart';
import 'package:ecommerce_local/adminpage.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_local/client-state.dart';
import 'clienthomepage.dart';

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



Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    final url = Uri.parse('http://localhost:3000/login');
    try {
      print('Sending login request to: $url');
      print('Request body: ${jsonEncode({'email': _email, 'password': _password})}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _email, 'password': _password}),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.headers['content-type']?.contains('application/json') ?? false) {
        final responseData = jsonDecode(response.body);

        setState(() {
          if (response.statusCode == 200) {
            final userId = responseData['userId']?.toString();
            final token = responseData['token'];
            final role = responseData['role']?.trim();

            print('Raw role from response: ${responseData['role']}'); // Debug
            print('Trimmed role: $role'); // Debug

            if (userId == null || token == null || role == null) {
              _message = 'Invalid login response: missing userId, token, or role';
              print('Login response missing data: $responseData');
              return;
            }

            final clientState = Provider.of<ClientState>(context, listen: false);
            clientState.updateUserId(userId);
            clientState.updateToken(token);
            print('After login - userId: ${clientState.userId}, token: ${clientState.token}, role: $role');

            if (role == 'client') {
              print('Navigating to ClientPage'); // Debug
              // Navigator.pushReplacementNamed(context, '/clientpage');
                Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ClientHomePage(),
                ),
              );
            } else if (role == 'seller') {
              print('Navigating to SellerHomePage'); // Debug
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SellerHomePage(
                    sellerId: userId,
                    token: token,
                  ),
                ),
              );
            } else if (role == 'admin') {
              print('Navigating to AdminPage'); // Debug
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminPage(adminId: userId),
                ),
              );
            } else {
              _message = 'Unknown role: ${responseData['role']}';
              print('Unknown role detected'); // Debug
            }
          } else if (response.statusCode == 401) {
            _message = 'Invalid email or password';
            print('Login failed: Invalid credentials'); // Debug
          } else {
            _message = responseData['error'] ?? 'Unknown error';
            print('Login failed: ${responseData['error']}'); // Debug
          }
        });
      } else {
        setState(() {
          _message = 'Unexpected response format (not JSON): ${response.body.substring(0, 50)}...';
          print('Unexpected response format'); // Debug
        });
      }
    } catch (error) {
      print('Error during login: $error');
      setState(() {
        _message = 'Error: $error';
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
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFAB47BC),
                      Color.fromARGB(255, 218, 111, 237),
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 202, 101, 220),
                      Color.fromARGB(255, 218, 111, 237),
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 230, 102, 252),
                      Color.fromARGB(255, 218, 111, 237),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'email@test.com',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFE0E0E0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFFAB47BC), width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return 'Enter your email';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                        onSaved: (value) => _email = value!,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFE0E0E0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFFAB47BC), width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                        ),
                        obscureText: true,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter your password' : null,
                        onSaved: (value) => _password = value!,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            backgroundColor: Color(0xFFAB47BC),
                          ),
                          child: Text(
                            'Log In',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: "Sign Up",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFAB47BC),
                                  ),
                                  recognizer: TapGestureRecognizer()..onTap = () {
                                    Navigator.pushNamed(context, '/signup');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_message.isNotEmpty)
                        Center(
                          child: Text(
                            _message,
                            style: TextStyle(
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
