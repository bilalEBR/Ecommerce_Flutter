
// version to add change password 

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'client-state.dart';
// import 'loginpage.dart';
// import 'clientaddress.dart';
// import 'clientorderhistory.dart';
// import 'changepassword.dart'; // Import the new ChangePasswordPage
// import 'baseurl.dart';

// class ClientProfilePage extends StatefulWidget {
//   const ClientProfilePage({super.key});

//   @override
//   _ClientProfilePageState createState() => _ClientProfilePageState();
// }

// class _ClientProfilePageState extends State<ClientProfilePage> {
//   String? _firstName;
//   String? _lastName;
//   String? _email;
//   String? _profilePicture;
//   // final String baseUrl = 'http://localhost:3000';
//   bool _isLoading = true;
//   bool _isEditing = false;

//   final _formKey = GlobalKey<FormState>();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   PlatformFile? _selectedProfilePicture;

//   @override
//   void initState() {
//     super.initState();
//     _fetchClientProfile();
//   }

//   Future<void> _fetchClientProfile() async {
//     setState(() {
//       _isLoading = true;
//     });

//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final userId = clientState.userId;
//     final token = clientState.token;

//     print('Fetching profile for userId: $userId, token: $token');

//     if (userId == null || token == null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/client/profile/$userId'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );
//       print('Response status: ${response.statusCode}, body: ${response.body}');
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _firstName = data['firstName'] ?? '';
//           _lastName = data['lastName'] ?? '';
//           _email = data['email'] ?? '';
//           _profilePicture = data['profilePicture'];
//           _isLoading = false;
//           _firstNameController.text = _firstName ?? '';
//           _lastNameController.text = _lastName ?? '';
//           _emailController.text = _email ?? '';
//         });
//       } else {
//         setState(() {
//           _firstName = '';
//           _lastName = '';
//           _email = '';
//           _profilePicture = null;
//           _isLoading = false;
//           _firstNameController.text = '';
//           _lastNameController.text = '';
//           _emailController.text = '';
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load profile: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _firstName = '';
//         _lastName = '';
//         _email = '';
//         _profilePicture = null;
//         _isLoading = false;
//         _firstNameController.text = '';
//         _lastNameController.text = '';
//         _emailController.text = '';
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching profile: $e')),
//       );
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       final clientState = Provider.of<ClientState>(context, listen: false);
//       final token = clientState.token;
//       final userId = clientState.userId;

//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/client/profile/$userId'),
//         );
//         request.headers['Authorization'] = 'Bearer $token';
//         request.fields['firstName'] = _firstNameController.text;
//         request.fields['lastName'] = _lastNameController.text;
//         request.fields['email'] = _emailController.text;

//         if (_selectedProfilePicture != null) {
//           final bytes = <int>[];
//           if (_selectedProfilePicture!.readStream != null) {
//             await for (var chunk in _selectedProfilePicture!.readStream!) {
//               bytes.addAll(chunk);
//             }
//           } else if (_selectedProfilePicture!.bytes != null) {
//             bytes.addAll(_selectedProfilePicture!.bytes!);
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('File data is unavailable')),
//             );
//             return;
//           }

//           request.files.add(
//             http.MultipartFile.fromBytes(
//               'profilePicture',
//               bytes,
//               filename: _selectedProfilePicture!.name,
//               contentType: MediaType('image', _selectedProfilePicture!.extension ?? 'jpeg'),
//             ),
//           );
//         }

//         final response = await request.send();
//         final responseBody = await http.Response.fromStream(response);

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Profile updated successfully')),
//           );
//           await _fetchClientProfile();
//           setState(() {
//             _isEditing = false;
//             _selectedProfilePicture = null;
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to update profile: ${responseBody.body}')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating profile: $e')),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final clientState = Provider.of<ClientState>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'My Account',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Column(
//                       children: [
//                         CircleAvatar(
//                           radius: 50,
//                           backgroundImage: _profilePicture != null
//                               ? NetworkImage('$baseUrl$_profilePicture')
//                               : null,
//                           backgroundColor: Colors.grey[300],
//                           child: _profilePicture == null
//                               ? Text(
//                                   'P',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 40,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 )
//                               : null,
//                         ),
//                         const SizedBox(height: 8),
//                         if (!_isEditing) ...[
//                           Text(
//                             '${_firstName ?? ''} ${_lastName ?? ''}',
//                             style: GoogleFonts.poppins(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             _email ?? '',
//                             style: GoogleFonts.poppins(
//                               fontSize: 16,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 _isEditing = true;
//                               });
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.orangeAccent[100],
//                               minimumSize: const Size(double.infinity, 48),
//                             ),
//                             child: Text(
//                               'Edit Profile',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                   if (_isEditing) ...[
//                     const SizedBox(height: 16),
//                     Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Edit Profile',
//                             style: GoogleFonts.poppins(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           ElevatedButton(
//                             onPressed: () async {
//                               try {
//                                 FilePickerResult? result = await FilePicker.platform.pickFiles(
//                                   type: FileType.image,
//                                   allowMultiple: false,
//                                 );
//                                 if (result != null && result.files.isNotEmpty) {
//                                   setState(() {
//                                     _selectedProfilePicture = result.files.first;
//                                   });
//                                 } else {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(content: Text('No file selected')),
//                                   );
//                                 }
//                               } catch (e) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text('Error selecting image: $e')),
//                                 );
//                               }
//                             },
//                             child: Text(
//                               _selectedProfilePicture == null
//                                   ? 'Select Profile Picture'
//                                   : 'Image Selected: ${_selectedProfilePicture!.name}',
//                               style: GoogleFonts.poppins(),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           TextFormField(
//                             controller: _firstNameController,
//                             decoration: InputDecoration(
//                               labelText: 'First Name',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             validator: (value) =>
//                                 value!.isEmpty ? 'Enter first name' : null,
//                           ),
//                           const SizedBox(height: 16),
//                           TextFormField(
//                             controller: _lastNameController,
//                             decoration: InputDecoration(
//                               labelText: 'Last Name',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             validator: (value) =>
//                                 value!.isEmpty ? 'Enter last name' : null,
//                           ),
//                           const SizedBox(height: 16),
//                           TextFormField(
//                             controller: _emailController,
//                             decoration: InputDecoration(
//                               labelText: 'Email',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             validator: (value) =>
//                                 value!.isEmpty ? 'Enter email' : null,
//                           ),
//                           const SizedBox(height: 16),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       _isEditing = false;
//                                       _selectedProfilePicture = null;
//                                     });
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.grey,
//                                     padding: const EdgeInsets.symmetric(vertical: 16),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     'Cancel',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: ElevatedButton(
//                                   onPressed: _updateProfile,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.purple,
//                                     padding: const EdgeInsets.symmetric(vertical: 16),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     'Update Profile',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                   if (!_isEditing) ...[
//                     const SizedBox(height: 24),
//                     ListTile(
//                       leading: const Icon(Icons.shopping_bag, color: Colors.black),
//                       title: Text(
//                         'My Orders',
//                         style: GoogleFonts.poppins(fontSize: 16),
//                       ),
//                       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const ClientOrdersPage(),
//                           ),
//                         );
//                       },
//                     ),
//                     ListTile(
//                       leading: const Icon(Icons.location_on, color: Colors.black),
//                       title: Text(
//                         'Shipping Address',
//                         style: GoogleFonts.poppins(fontSize: 16),
//                       ),
//                       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ClientAddressPage(
//                               fullName: '${_firstName ?? ''} ${_lastName ?? ''}'.trim(),
//                               email: _email ?? '',
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     ListTile(
//                       leading: const Icon(Icons.lock, color: Colors.black),
//                       title: Text(
//                         'Change Password',
//                         style: GoogleFonts.poppins(fontSize: 16),
//                       ),
//                       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ChangePasswordPage(
//                               token: clientState.token ?? '',
//                               userId: clientState.userId ?? '',
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     ListTile(
//                       leading: const Icon(Icons.logout, color: Colors.black),
//                       title: Text(
//                         'Logout',
//                         style: GoogleFonts.poppins(fontSize: 16),
//                       ),
//                       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                       onTap: () {
//                         clientState.clearAuthData();
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (context) => const LoginPage()),
//                         );
//                       },
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//     );
//   }
// }

// version ui

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'client-state.dart';
// import 'loginpage.dart';
// import 'clientaddress.dart';
// import 'clientorderhistory.dart';
// import 'changepassword.dart';
// import 'baseurl.dart';

// class ClientProfilePage extends StatefulWidget {
//   const ClientProfilePage({super.key});

//   @override
//   _ClientProfilePageState createState() => _ClientProfilePageState();
// }

// class _ClientProfilePageState extends State<ClientProfilePage> {
//   String? _firstName;
//   String? _lastName;
//   String? _email;
//   String? _profilePicture;
//   bool _isLoading = true;
//   bool _isEditing = false;

//   final _formKey = GlobalKey<FormState>();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   PlatformFile? _selectedProfilePicture;

//   // Color scheme
//   final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);
//   final Color accentColor = const Color(0xFFFFD700);

//   @override
//   void initState() {
//     super.initState();
//     _fetchClientProfile();
//   }

//   Future<void> _fetchClientProfile() async {
//     setState(() {
//       _isLoading = true;
//     });

//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final userId = clientState.userId;
//     final token = clientState.token;

//     print('Fetching profile for userId: $userId, token: $token');

//     if (userId == null || token == null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/client/profile/$userId'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );
//       print('Response status: ${response.statusCode}, body: ${response.body}');
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _firstName = data['firstName'] ?? '';
//           _lastName = data['lastName'] ?? '';
//           _email = data['email'] ?? '';
//           _profilePicture = data['profilePicture'];
//           _isLoading = false;
//           _firstNameController.text = _firstName ?? '';
//           _lastNameController.text = _lastName ?? '';
//           _emailController.text = _email ?? '';
//         });
//       } else {
//         setState(() {
//           _firstName = '';
//           _lastName = '';
//           _email = '';
//           _profilePicture = null;
//           _isLoading = false;
//           _firstNameController.text = '';
//           _lastNameController.text = '';
//           _emailController.text = '';
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load profile: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _firstName = '';
//         _lastName = '';
//         _email = '';
//         _profilePicture = null;
//         _isLoading = false;
//         _firstNameController.text = '';
//         _lastNameController.text = '';
//         _emailController.text = '';
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching profile: $e')),
//       );
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       final clientState = Provider.of<ClientState>(context, listen: false);
//       final token = clientState.token;
//       final userId = clientState.userId;

//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/client/profile/$userId'),
//         );
//         request.headers['Authorization'] = 'Bearer $token';
//         request.fields['firstName'] = _firstNameController.text;
//         request.fields['lastName'] = _lastNameController.text;
//         request.fields['email'] = _emailController.text;

//         if (_selectedProfilePicture != null) {
//           final bytes = <int>[];
//           if (_selectedProfilePicture!.readStream != null) {
//             await for (var chunk in _selectedProfilePicture!.readStream!) {
//               bytes.addAll(chunk);
//             }
//           } else if (_selectedProfilePicture!.bytes != null) {
//             bytes.addAll(_selectedProfilePicture!.bytes!);
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('File data is unavailable')),
//             );
//             return;
//           }

//           request.files.add(
//             http.MultipartFile.fromBytes(
//               'profilePicture',
//               bytes,
//               filename: _selectedProfilePicture!.name,
//               contentType: MediaType('image', _selectedProfilePicture!.extension ?? 'jpeg'),
//             ),
//           );
//         }

//         final response = await request.send();
//         final responseBody = await http.Response.fromStream(response);

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Profile updated successfully')),
//           );
//           await _fetchClientProfile();
//           setState(() {
//             _isEditing = false;
//             _selectedProfilePicture = null;
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to update profile: ${responseBody.body}')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating profile: $e')),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final clientState = Provider.of<ClientState>(context);

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         // backgroundColor: primaryColor,
//         title: Text(
//           'My Account',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         foregroundColor: Colors.white,
//         elevation: 2,
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Column(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(color: primaryColor, width: 2),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.3),
//                                 spreadRadius: 2,
//                                 blurRadius: 5,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: CircleAvatar(
//                             radius: 50,
//                             backgroundImage: _profilePicture != null
//                                 ? NetworkImage('$baseUrl$_profilePicture')
//                                 : null,
//                             backgroundColor: Colors.grey[300],
//                             child: _profilePicture == null
//                                 ? Text(
//                                     _firstName != null && _firstName!.isNotEmpty ? _firstName![0] : 'P',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 40,
//                                       fontWeight: FontWeight.bold,
//                                       color: primaryColor,
//                                     ),
//                                   )
//                                 : null,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         if (!_isEditing) ...[
//                           Text(
//                             '${_firstName ?? ''} ${_lastName ?? ''}'.trim(),
//                             style: GoogleFonts.poppins(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: primaryColor,
//                             ),
//                           ),
//                           Text(
//                             _email ?? '',
//                             style: GoogleFonts.poppins(
//                               fontSize: 16,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 setState(() {
//                                   _isEditing = true;
//                                 });
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: primaryColor,
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(vertical: 12),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 elevation: 3,
//                                 shadowColor: Colors.grey.withOpacity(0.5),
//                               ),
//                               child: Text(
//                                 'Edit Profile',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                   if (_isEditing) ...[
//                     const SizedBox(height: 24),
//                     Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Edit Profile',
//                             style: GoogleFonts.poppins(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: primaryColor,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: () async {
//                                 try {
//                                   FilePickerResult? result = await FilePicker.platform.pickFiles(
//                                     type: FileType.image,
//                                     allowMultiple: false,
//                                   );
//                                   if (result != null && result.files.isNotEmpty) {
//                                     setState(() {
//                                       _selectedProfilePicture = result.files.first;
//                                     });
//                                   } else {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(content: Text('No file selected')),
//                                     );
//                                   }
//                                 } catch (e) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(content: Text('Error selecting image: $e')),
//                                   );
//                                 }
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.grey[200],
//                                 foregroundColor: primaryColor,
//                                 padding: const EdgeInsets.symmetric(vertical: 12),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 elevation: 2,
//                               ),
//                               child: Text(
//                                 _selectedProfilePicture == null
//                                     ? 'Select Profile Picture'
//                                     : 'Image Selected: ${_selectedProfilePicture!.name}',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14,
//                                   color: primaryColor,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             'First Name',
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: primaryColor,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           TextFormField(
//                             controller: _firstNameController,
//                             decoration: InputDecoration(
//                               labelText: 'First Name',
//                               labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                               filled: true,
//                               fillColor: Colors.grey[100],
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(color: primaryColor, width: 1),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(color: primaryColor, width: 1),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(color: primaryColor, width: 1.5),
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                             ),
//                             style: GoogleFonts.poppins(fontSize: 14),
//                             validator: (value) => value!.isEmpty ? 'Enter first name' : null,
//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             'Last Name',
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: primaryColor,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           TextFormField(
//                             controller: _lastNameController,
//                             decoration: InputDecoration(
//                               labelText: 'Last Name',
//                               labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                               filled: true,
//                               fillColor: Colors.grey[100],
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(color: primaryColor, width: 1),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(color: primaryColor, width: 1),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(color: primaryColor, width: 1.5),
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                             ),
//                             style: GoogleFonts.poppins(fontSize: 14),
//                             validator: (value) => value!.isEmpty ? 'Enter last name' : null,
//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             'Email',
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: primaryColor,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           TextFormField(
//                             controller: _emailController,
//                             decoration: InputDecoration(
//                               labelText: 'Email',
//                               labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                               filled: true,
//                               fillColor: Colors.grey[100],
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(color: primaryColor, width: 1),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(color: primaryColor, width: 1),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(color: primaryColor, width: 1.5),
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                             ),
//                             style: GoogleFonts.poppins(fontSize: 14),
//                             validator: (value) => value!.isEmpty ? 'Enter email' : null,
//                           ),
//                           const SizedBox(height: 24),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       _isEditing = false;
//                                       _selectedProfilePicture = null;
//                                     });
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.grey[600],
//                                     foregroundColor: Colors.white,
//                                     padding: const EdgeInsets.symmetric(vertical: 12),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     elevation: 3,
//                                     shadowColor: Colors.grey.withOpacity(0.5),
//                                   ),
//                                   child: Text(
//                                     'Cancel',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: ElevatedButton(
//                                   onPressed: _updateProfile,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: primaryColor,
//                                     foregroundColor: Colors.white,
//                                     padding: const EdgeInsets.symmetric(vertical: 12),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     elevation: 3,
//                                     shadowColor: Colors.grey.withOpacity(0.5),
//                                   ),
//                                   child: Text(
//                                     'Update Profile',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                   if (!_isEditing) ...[
//                     const SizedBox(height: 24),
//                     Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         side: BorderSide(color: Colors.grey[200]!, width: 1),
//                       ),
//                       child: ListTile(
//                         leading: Icon(Icons.shopping_bag, color: primaryColor),
//                         title: Text(
//                           'My Orders',
//                           style: GoogleFonts.poppins(fontSize: 16, color: primaryColor),
//                         ),
//                         trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const ClientOrdersPage(),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         side: BorderSide(color: Colors.grey[200]!, width: 1),
//                       ),
//                       child: ListTile(
//                         leading: Icon(Icons.location_on, color: primaryColor),
//                         title: Text(
//                           'Shipping Address',
//                           style: GoogleFonts.poppins(fontSize: 16, color: primaryColor),
//                         ),
//                         trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ClientAddressPage(
//                                 fullName: '${_firstName ?? ''} ${_lastName ?? ''}'.trim(),
//                                 email: _email ?? '',
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         side: BorderSide(color: Colors.grey[200]!, width: 1),
//                       ),
//                       child: ListTile(
//                         leading: Icon(Icons.lock, color: primaryColor),
//                         title: Text(
//                           'Change Password',
//                           style: GoogleFonts.poppins(fontSize: 16, color: primaryColor),
//                         ),
//                         trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ChangePasswordPage(
//                                 token: clientState.token ?? '',
//                                 userId: clientState.userId ?? '',
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         side: BorderSide(color: Colors.grey[200]!, width: 1),
//                       ),
//                       child: ListTile(
//                         leading: Icon(Icons.logout, color: primaryColor),
//                         title: Text(
//                           'Logout',
//                           style: GoogleFonts.poppins(fontSize: 16, color: primaryColor),
//                         ),
//                         trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
//                         onTap: () {
//                           clientState.clearAuthData();
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(builder: (context) => const LoginPage()),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//     );
//   }
// }

// version to add additional pages 

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'client-state.dart';
import 'loginpage.dart';
import 'clientaddress.dart';
import 'clientorderhistory.dart';
import 'changepassword.dart';
import 'clientaboutus.dart'; // New import
import 'clientcontact.dart'; // New import
import 'clientfaqs.dart'; // New import
import 'baseurl.dart';

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  _ClientProfilePageState createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _profilePicture;
  bool _isLoading = true;
  bool _isEditing = false;

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  PlatformFile? _selectedProfilePicture;

  // Color scheme
  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);
  final Color accentColor = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _fetchClientProfile();
  }

  Future<void> _fetchClientProfile() async {
    setState(() {
      _isLoading = true;
    });

    final clientState = Provider.of<ClientState>(context, listen: false);
    final userId = clientState.userId;
    final token = clientState.token;

    if (userId == null || token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/client/profile/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _firstName = data['firstName'] ?? '';
          _lastName = data['lastName'] ?? '';
          _email = data['email'] ?? '';
          _profilePicture = data['profilePicture'];
          _isLoading = false;
          _firstNameController.text = _firstName ?? '';
          _lastNameController.text = _lastName ?? '';
          _emailController.text = _email ?? '';
        });
      } else {
        setState(() {
          _firstName = '';
          _lastName = '';
          _email = '';
          _profilePicture = null;
          _isLoading = false;
          _firstNameController.text = '';
          _lastNameController.text = '';
          _emailController.text = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() {
        _firstName = '';
        _lastName = '';
        _email = '';
        _profilePicture = null;
        _isLoading = false;
        _firstNameController.text = '';
        _lastNameController.text = '';
        _emailController.text = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile: $e')),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final clientState = Provider.of<ClientState>(context, listen: false);
      final token = clientState.token;
      final userId = clientState.userId;

      try {
        final request = http.MultipartRequest(
          'PUT',
          Uri.parse('$baseUrl/client/profile/$userId'),
        );
        request.headers['Authorization'] = 'Bearer $token';
        request.fields['firstName'] = _firstNameController.text;
        request.fields['lastName'] = _lastNameController.text;
        request.fields['email'] = _emailController.text;

        if (_selectedProfilePicture != null) {
          final bytes = <int>[];
          if (_selectedProfilePicture!.readStream != null) {
            await for (var chunk in _selectedProfilePicture!.readStream!) {
              bytes.addAll(chunk);
            }
          } else if (_selectedProfilePicture!.bytes != null) {
            bytes.addAll(_selectedProfilePicture!.bytes!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File data is unavailable')),
            );
            return;
          }

          request.files.add(
            http.MultipartFile.fromBytes(
              'profilePicture',
              bytes,
              filename: _selectedProfilePicture!.name,
              contentType: MediaType('image', _selectedProfilePicture!.extension ?? 'jpeg'),
            ),
          );
        }

        final response = await request.send();
        final responseBody = await http.Response.fromStream(response);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          await _fetchClientProfile();
          setState(() {
            _isEditing = false;
            _selectedProfilePicture = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: ${responseBody.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientState = Provider.of<ClientState>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'My Account',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _profilePicture != null
                                ? NetworkImage('$baseUrl$_profilePicture')
                                : null,
                            backgroundColor: Colors.grey[300],
                            child: _profilePicture == null
                                ? Text(
                                    _firstName != null && _firstName!.isNotEmpty ? _firstName![0] : 'P',
                                    style: GoogleFonts.poppins(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (!_isEditing) ...[
                          Text(
                            '${_firstName ?? ''} ${_lastName ?? ''}'.trim(),
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            _email ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 3,
                                shadowColor: Colors.grey.withOpacity(0.5),
                              ),
                              child: Text(
                                'Edit Profile',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Profile',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                                    type: FileType.image,
                                    allowMultiple: false,
                                  );
                                  if (result != null && result.files.isNotEmpty) {
                                    setState(() {
                                      _selectedProfilePicture = result.files.first;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No file selected')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error selecting image: $e')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                _selectedProfilePicture == null
                                    ? 'Select Profile Picture'
                                    : 'Image Selected: ${_selectedProfilePicture!.name}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'First Name',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: primaryColor, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: primaryColor, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: primaryColor, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                            style: GoogleFonts.poppins(fontSize: 14),
                            validator: (value) => value!.isEmpty ? 'Enter first name' : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Last Name',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: primaryColor, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: primaryColor, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: primaryColor, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                            style: GoogleFonts.poppins(fontSize: 14),
                            validator: (value) => value!.isEmpty ? 'Enter last name' : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Email',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: primaryColor, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: primaryColor, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: primaryColor, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                            style: GoogleFonts.poppins(fontSize: 14),
                            validator: (value) => value!.isEmpty ? 'Enter email' : null,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = false;
                                      _selectedProfilePicture = null;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[600],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 3,
                                    shadowColor: Colors.grey.withOpacity(0.5),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 3,
                                    shadowColor: Colors.grey.withOpacity(0.5),
                                  ),
                                  child: Text(
                                    'Update Profile',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (!_isEditing) ...[
                    const SizedBox(height: 24),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.shopping_bag, color: primaryColor),
                        title: Text(
                          'My Orders',
                          style: GoogleFonts.poppins(fontSize: 16, color: primaryColor),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ClientOrdersPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.location_on, color: primaryColor),
                        title: Text(
                          'Shipping Address',
                          style: GoogleFonts.poppins(fontSize: 16, color: primaryColor),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClientAddressPage(
                                fullName: '${_firstName ?? ''} ${_lastName ?? ''}'.trim(),
                                email: _email ?? '',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.lock, color: primaryColor),
                        title: Text(
                          'Change Password',
                          style: GoogleFonts.poppins(fontSize: 16, color: primaryColor),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangePasswordPage(
                                token: clientState.token ?? '',
                                userId: clientState.userId ?? '',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.info, color: primaryColor),
                        title: Text(
                          'About Us',
                          style: GoogleFonts.poppins(fontSize: 16, color: primaryColor),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ClientAboutUsPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.contact_mail, color: primaryColor),
                        title: Text(
                          'Contact',
                          style: GoogleFonts.poppins(fontSize: 16, color: primaryColor),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  ClientContactPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.question_answer, color: primaryColor),
                        title: Text(
                          'FAQs',
                          style: GoogleFonts.poppins(fontSize: 16, color: primaryColor),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ClientFAQsPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.logout, color: primaryColor),
                        title: Text(
                          'Logout',
                          style: GoogleFonts.poppins(fontSize: 16, color: primaryColor),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
                        onTap: () {
                          clientState.clearAuthData();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}