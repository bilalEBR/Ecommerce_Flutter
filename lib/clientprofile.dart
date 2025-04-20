// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'client-state.dart';
// import 'loginpage.dart';

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
//   final String baseUrl = 'http://localhost:3000';
//   bool _isLoading = true; // Track loading state explicitly
//   bool _isEditing = false; // Track if we're in editing mode

//   // Form controllers for editing
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

// Future<void> _fetchClientProfile() async {
//   setState(() {
//     _isLoading = true;
//   });

//   final clientState = Provider.of<ClientState>(context, listen: false);
//   final userId = clientState.userId;
//   final token = clientState.token;

//   print('Fetching profile for userId: $userId, token: $token'); // Debug log

//   if (userId == null || token == null) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const LoginPage()),
//     );
//     return;
//   }

//   try {
//     final response = await http.get(
//       Uri.parse('$baseUrl/client/profile/$userId'),
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     );
//     print('Response status: ${response.statusCode}, body: ${response.body}'); // Debug log
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       setState(() {
//         _firstName = data['firstName'] ?? '';
//         _lastName = data['lastName'] ?? '';
//         _email = data['email'] ?? '';
//         _profilePicture = data['profilePicture'];
//         _isLoading = false;
//         _firstNameController.text = _firstName ?? '';
//         _lastNameController.text = _lastName ?? '';
//         _emailController.text = _email ?? '';
//       });
//     } else {
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
//         SnackBar(content: Text('Failed to load profile: ${response.body}')),
//       );
//     }
//   } catch (e) {
//     setState(() {
//       _firstName = '';
//       _lastName = '';
//       _email = '';
//       _profilePicture = null;
//       _isLoading = false;
//       _firstNameController.text = '';
//       _lastNameController.text = '';
//       _emailController.text = '';
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error fetching profile: $e')),
//     );
//   }
// }

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
//           // Refresh profile data after update
//           await _fetchClientProfile();
//           setState(() {
//             _isEditing = false;
//             _selectedProfilePicture = null; // Clear selected picture after update
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
//           'My Profile',
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
//                   // Profile Header
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
//                                   'P', // Display "P" as default
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
//                               backgroundColor: Colors.blue,
//                               minimumSize: const Size(double.infinity, 48),
//                             ),
//                             child: Text(
//                               'Edit Profile',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),

//                   // Editing Form (shown when _isEditing is true)
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

//                   // Other sections (only shown when not editing)
//                   if (!_isEditing) ...[
//                     const SizedBox(height: 24),
//                     // Order History Section (Placeholder)
//                     Text(
//                       'Order History',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Card(
//                       elevation: 2,
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           children: [
//                             Text(
//                               'No orders yet.',
//                               style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
//                             ),
//                             const SizedBox(height: 8),
//                             ElevatedButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(builder: (context) => const ClientProfilePage()),
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.black,
//                                 minimumSize: const Size(double.infinity, 48),
//                               ),
//                               child: Text(
//                                 'Start Shopping',
//                                 style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // Settings Section (Placeholder)
//                     Text(
//                       'Settings',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Card(
//                       elevation: 2,
//                       child: ListTile(
//                         title: Text(
//                           'Notification Preferences',
//                           style: GoogleFonts.poppins(fontSize: 16),
//                         ),
//                         trailing: const Icon(Icons.arrow_forward_ios),
//                         onTap: () {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('Notification settings coming soon!')),
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // Logout Button
//                     ElevatedButton(
//                       onPressed: () {
//                         clientState.clearAuthData();
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (context) => const LoginPage()),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         minimumSize: const Size(double.infinity, 48),
//                       ),
//                       child: Text(
//                         'Logout',
//                         style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'client-state.dart';
import 'loginpage.dart';

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
  final String baseUrl = 'http://localhost:3000';
  bool _isLoading = true; // Track loading state explicitly
  bool _isEditing = false; // Track if we're in editing mode

  // Form controllers for editing
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  PlatformFile? _selectedProfilePicture;

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

    print('Fetching profile for userId: $userId, token: $token'); // Debug log

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
      print('Response status: ${response.statusCode}, body: ${response.body}'); // Debug log
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
          // Refresh profile data after update
          await _fetchClientProfile();
          setState(() {
            _isEditing = false;
            _selectedProfilePicture = null; // Clear selected picture after update
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
      appBar: AppBar(
        title: Text(
          'My Account', // Updated title to match the image
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header (unchanged)
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _profilePicture != null
                              ? NetworkImage('$baseUrl$_profilePicture')
                              : null,
                          backgroundColor: Colors.grey[300],
                          child: _profilePicture == null
                              ? Text(
                                  'P', // Display "P" as default
                                  style: GoogleFonts.poppins(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        if (!_isEditing) ...[
                          Text(
                            '${_firstName ?? ''} ${_lastName ?? ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _email ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent[100], // Updated to match the image
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: Text(
                              'Edit Profile',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black, // Black text for better contrast
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Editing Form (shown when _isEditing is true)
                  if (_isEditing) ...[
                    const SizedBox(height: 16),
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
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
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
                            child: Text(
                              _selectedProfilePicture == null
                                  ? 'Select Profile Picture'
                                  : 'Image Selected: ${_selectedProfilePicture!.name}',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Enter first name' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Enter last name' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Enter email' : null,
                          ),
                          const SizedBox(height: 16),
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
                                    backgroundColor: Colors.grey,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Update Profile',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
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

                  // Options List (shown when not editing)
                  if (!_isEditing) ...[
                    const SizedBox(height: 24),
                    ListTile(
                      leading: const Icon(Icons.shopping_bag, color: Colors.black),
                      title: Text(
                        'My Orders',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to Orders page (placeholder)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('My Orders page coming soon!')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.black),
                      title: Text(
                        'Shipping Address',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to Shipping Address page (placeholder)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Shipping Address page coming soon!')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.help, color: Colors.black),
                      title: Text(
                        'Help Center',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to Help Center page (placeholder)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Help Center page coming soon!')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.black),
                      title: Text(
                        'Logout',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        clientState.clearAuthData();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}