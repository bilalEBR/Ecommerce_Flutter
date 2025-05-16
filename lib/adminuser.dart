

// // adminuser.dart
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_fonts/google_fonts.dart';
// import 'baseurl.dart';

// class UsersPage extends StatefulWidget {
//   const UsersPage({super.key});

//   @override
//   _UsersPageState createState() => _UsersPageState();
// }

// class _UsersPageState extends State<UsersPage> {
//   List<dynamic> _users = [];
//   List<dynamic> _filteredUsers = [];
//   bool _isLoading = true;
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchUsers();
//   }

//   Future<void> _fetchUsers() async {
//     setState(() => _isLoading = true);
//     try {
//       final response = await http.get(
//         // Uri.parse('http://localhost:3000/admin/users/users'),
//         Uri.parse('$baseUrl/admin/users/users'),
//       );
//       print('Fetch Users Response: ${response.statusCode} - ${response.body}');
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _users = data;
//           _filteredUsers = data;
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to load users: ${response.statusCode} - ${response.body}'),
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching users: $e')),
//       );
//     }
//   }

//   void _filterUsers(String query) {
//     setState(() {
//       _searchQuery = query;
//       _filteredUsers = _users.where((user) {
//         final name = user['firstName']?.toString().toLowerCase() ?? '';
//         final email = user['email']?.toString().toLowerCase() ?? '';
//         final searchLower = query.toLowerCase();
//         return name.contains(searchLower) || email.contains(searchLower);
//       }).toList();
//     });
//   }

//   Future<void> _deleteUser(String userId, Map<String, dynamic> user) async {
//     try {
//       final url = 'http://localhost:3000/admin/users/users/$userId';
//       print('Deleting user with URL: $url');
//       final response = await http.delete(Uri.parse(url));
//       print('Delete User Response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         setState(() {
//           _users.removeWhere((u) => u['_id'] == userId);
//           _filteredUsers.removeWhere((u) => u['_id'] == userId);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('User deleted successfully')),
//         );
//       } else if (response.statusCode == 403) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Cannot delete admin users')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to delete user: ${response.statusCode} - ${response.body}'),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting user: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: TextField(
//             onChanged: _filterUsers,
//             decoration: InputDecoration(
//               prefixIcon: const Icon(Icons.search, color: Color(0xFFAB47BC)),
//               hintText: 'Search by name or email',
//               hintStyle: const TextStyle(color: Colors.grey),
//               filled: true,
//               fillColor: const Color(0xFFE0E0E0),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: const BorderSide(color: Colors.green, width: 2),
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           child: _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : ListView.builder(
//                   itemCount: _filteredUsers.length,
//                   itemBuilder: (context, index) {
//                     final user = _filteredUsers[index];
//                     final firstLetter =
//                         user['firstName']?.toString().substring(0, 1) ?? 'U';
//                     return ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor: _getColorForLetter(firstLetter),
//                         child: Text(
//                           firstLetter,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       title: Text(
//                         '${user['firstName'] ?? 'Unknown'} ${user['lastName'] ?? ''}',
//                         style: GoogleFonts.poppins(fontSize: 16),
//                       ),
//                       subtitle: Text(
//                         user['email'] ?? 'No email',
//                         style: const TextStyle(color: Colors.grey),
//                       ),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: const Icon(
//                               Icons.delete,
//                               color: Color(0xFFAB47BC),
//                             ),
//                             onPressed: () async {
//                               if (user['role'] == 'admin') {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Cannot delete admin users'),
//                                   ),
//                                 );
//                                 return;
//                               }
//                               final confirm = await showDialog<bool>(
//                                 context: context,
//                                 builder: (context) => AlertDialog(
//                                   title: const Text('Confirm Delete'),
//                                   content: const Text(
//                                     'Are you sure you want to delete this user?',
//                                   ),
//                                   actions: [
//                                     TextButton(
//                                       onPressed: () =>
//                                           Navigator.pop(context, false),
//                                       child: const Text('Cancel'),
//                                     ),
//                                     TextButton(
//                                       onPressed: () =>
//                                           Navigator.pop(context, true),
//                                       child: const Text('Delete'),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                               if (confirm == true) {
//                                 await _deleteUser(user['_id'], user);
//                               }
//                             },
//                           ),
//                           IconButton(
//                             icon: const Icon(
//                               Icons.edit,
//                               color: Color(0xFFAB47BC),
//                             ),
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => EditUserPage(
//                                     user: user,
//                                     onUserUpdated: () {
//                                       _fetchUsers(); // Refresh the user list after update
//                                     },
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   Color _getColorForLetter(String letter) {
//     switch (letter.toUpperCase()) {
//       case 'W':
//         return const Color(0xFF8BC34A);
//       case 'F':
//         return const Color(0xFF2196F3);
//       case 'M':
//         return const Color(0xFF4CAF50);
//       case 'L':
//         return const Color(0xFF9C27B0);
//       case 'N':
//         return const Color(0xFF673AB7);
//       case 'J':
//         return const Color(0xFF03A9F4);
//       default:
//         return const Color(0xFFF44336);
//     }
//   }
// }

// class EditUserPage extends StatefulWidget {
//   final Map<String, dynamic> user;
//   final VoidCallback onUserUpdated;

//   const EditUserPage({super.key, required this.user, required this.onUserUpdated});

//   @override
//   _EditUserPageState createState() => _EditUserPageState();
// }

// class _EditUserPageState extends State<EditUserPage> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _firstNameController;
//   late TextEditingController _lastNameController;
//   late TextEditingController _emailController;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _firstNameController = TextEditingController(text: widget.user['firstName'] ?? '');
//     _lastNameController = TextEditingController(text: widget.user['lastName'] ?? '');
//     _emailController = TextEditingController(text: widget.user['email'] ?? '');
//   }

//   Future<void> _updateUser() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         final url = 'http://localhost:3000/admin/users/users/${widget.user['_id']}';
//         print('Updating user with URL: $url');
//         final response = await http.put(
//           Uri.parse(url),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'firstName': _firstNameController.text,
//             'lastName': _lastNameController.text,
//             'email': _emailController.text,
//           }),
//         );
//         print('Update User Response: ${response.statusCode} - ${response.body}');

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('User updated successfully')),
//           );
//           widget.onUserUpdated(); // Refresh the user list
//           Navigator.pop(context); // Go back to UsersPage
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to update user: ${response.statusCode} - ${response.body}'),
//             ),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating user: $e')),
//         );
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
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
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 129, 48, 143),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Text(
//           'Edit User',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Edit User Details',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _firstNameController,
//                   decoration: InputDecoration(
//                     labelText: 'First Name',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter first name' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _lastNameController,
//                   decoration: InputDecoration(
//                     labelText: 'Last Name',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter last name' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) => value!.isEmpty ? 'Enter email' : null,
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _updateUser,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: _isLoading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : Text(
//                             'Update User',
//                             style: GoogleFonts.poppins(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
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
import 'baseurl.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  // Color scheme from checkout.dart
  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users/users'),
      );
      print('Fetch Users Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _users = data;
          _filteredUsers = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load users: ${response.statusCode} - ${response.body}'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e')),
      );
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      _filteredUsers = _users.where((user) {
        final name = user['firstName']?.toString().toLowerCase() ?? '';
        final email = user['email']?.toString().toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) || email.contains(searchLower);
      }).toList();
    });
  }

  Future<void> _deleteUser(String userId, Map<String, dynamic> user) async {
    try {
      final url = 'http://localhost:3000/admin/users/users/$userId';
      print('Deleting user with URL: $url');
      final response = await http.delete(Uri.parse(url));
      print('Delete User Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _users.removeWhere((u) => u['_id'] == userId);
          _filteredUsers.removeWhere((u) => u['_id'] == userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot delete admin users')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete user: ${response.statusCode} - ${response.body}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: _filterUsers,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: primaryColor),
              hintText: 'Search by name or email',
              hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
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
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    final firstLetter = user['firstName']?.toString().substring(0, 1) ?? 'U';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        leading: CircleAvatar(
                          backgroundColor: _getColorForLetter(firstLetter),
                          child: Text(
                            firstLetter,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          '${user['firstName'] ?? 'Unknown'} ${user['lastName'] ?? ''}',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
                        ),
                        subtitle: Text(
                          user['email'] ?? 'No email',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: primaryColor),
                              onPressed: () async {
                                if (user['role'] == 'admin') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Cannot delete admin users'),
                                    ),
                                  );
                                  return;
                                }
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Confirm Delete',
                                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete this user?',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: Text(
                                          'Cancel',
                                          style: GoogleFonts.poppins(fontSize: 14, color: primaryColor),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: Text(
                                          'Delete',
                                          style: GoogleFonts.poppins(fontSize: 14, color: primaryColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _deleteUser(user['_id'], user);
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: primaryColor),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditUserPage(
                                      user: user,
                                      onUserUpdated: () {
                                        _fetchUsers(); // Refresh the user list after update
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getColorForLetter(String letter) {
    switch (letter.toUpperCase()) {
      case 'W':
        return const Color(0xFF8BC34A);
      case 'F':
        return const Color(0xFF2196F3);
      case 'M':
        return const Color(0xFF4CAF50);
      case 'L':
        return const Color(0xFF9C27B0);
      case 'N':
        return const Color(0xFF673AB7);
      case 'J':
        return const Color(0xFF03A9F4);
      default:
        return const Color(0xFFF44336);
    }
  }
}

class EditUserPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onUserUpdated;

  const EditUserPage({super.key, required this.user, required this.onUserUpdated});

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  // Color scheme from checkout.dart
  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user['firstName'] ?? '');
    _lastNameController = TextEditingController(text: widget.user['lastName'] ?? '');
    _emailController = TextEditingController(text: widget.user['email'] ?? '');
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final url = 'http://localhost:3000/admin/users/users/${widget.user['_id']}';
        print('Updating user with URL: $url');
        final response = await http.put(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'email': _emailController.text,
          }),
        );
        print('Update User Response: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User updated successfully')),
          );
          widget.onUserUpdated(); // Refresh the user list
          Navigator.pop(context); // Go back to UsersPage
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update user: ${response.statusCode} - ${response.body}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit User',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit User Details',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
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
                  validator: (value) => value!.isEmpty ? 'Enter first name' : null,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 16),
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
                  validator: (value) => value!.isEmpty ? 'Enter last name' : null,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 16),
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
                  validator: (value) => value!.isEmpty ? 'Enter email' : null,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateUser,
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
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Update User',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// version to update profile





// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_fonts/google_fonts.dart';
// import 'baseurl.dart';

// class UsersPage extends StatefulWidget {
//   const UsersPage({super.key});

//   @override
//   _UsersPageState createState() => _UsersPageState();
// }

// class _UsersPageState extends State<UsersPage> {
//   List<dynamic> _users = [];
//   List<dynamic> _filteredUsers = [];
//   bool _isLoading = true;
//   String _searchQuery = '';

//   // Color scheme from checkout.dart
//   final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

//   @override
//   void initState() {
//     super.initState();
//     _fetchUsers();
//   }

//   Future<void> _fetchUsers() async {
//     setState(() => _isLoading = true);
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/users/users'),
//       );
//       print('Fetch Users Response: ${response.statusCode} - ${response.body}');
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         // Fetch profile data for each user
//         List<dynamic> usersWithProfiles = [];
//         for (var user in data) {
//           try {
//             final profileResponse = await http.get(
//               Uri.parse('$baseUrl/admin/profiles/${user['_id']}'),
//               headers: {
//                 'Content-Type': 'application/json',
//               },
//             );
//             print('Fetch Profile Response for ${user['_id']}: ${profileResponse.statusCode} - ${profileResponse.body}');
//             if (profileResponse.statusCode == 200) {
//               final profileData = jsonDecode(profileResponse.body);
//               usersWithProfiles.add({
//                 ...user,
//                 'profilePicture': profileData['profilePicture'],
//               });
//             } else {
//               print('Failed to fetch profile for ${user['_id']}: ${profileResponse.statusCode} - ${profileResponse.body}');
//               usersWithProfiles.add({
//                 ...user,
//                 'profilePicture': null,
//               });
//             }
//           } catch (e) {
//             print('Error fetching profile for ${user['_id']}: $e');
//             usersWithProfiles.add({
//               ...user,
//               'profilePicture': null,
//             });
//           }
//         }
//         setState(() {
//           _users = usersWithProfiles;
//           _filteredUsers = usersWithProfiles;
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to load users: ${response.statusCode} - ${response.body}'),
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching users: $e')),
//       );
//     }
//   }

//   void _filterUsers(String query) {
//     setState(() {
//       _searchQuery = query;
//       _filteredUsers = _users.where((user) {
//         final name = user['firstName']?.toString().toLowerCase() ?? '';
//         final email = user['email']?.toString().toLowerCase() ?? '';
//         final searchLower = query.toLowerCase();
//         return name.contains(searchLower) || email.contains(searchLower);
//       }).toList();
//     });
//   }

//   Future<void> _deleteUser(String userId, Map<String, dynamic> user) async {
//     try {
//       final url = 'http://localhost:3000/admin/users/users/$userId';
//       print('Deleting user with URL: $url');
//       final response = await http.delete(Uri.parse(url));
//       print('Delete User Response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         setState(() {
//           _users.removeWhere((u) => u['_id'] == userId);
//           _filteredUsers.removeWhere((u) => u['_id'] == userId);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('User deleted successfully')),
//         );
//       } else if (response.statusCode == 403) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Cannot delete admin users')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to delete user: ${response.statusCode} - ${response.body}'),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting user: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: TextField(
//             onChanged: _filterUsers,
//             decoration: InputDecoration(
//               prefixIcon: Icon(Icons.search, color: primaryColor),
//               hintText: 'Search by name or email',
//               hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//               filled: true,
//               fillColor: Colors.grey[100],
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: primaryColor, width: 1),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: primaryColor, width: 1),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: primaryColor, width: 1.5),
//               ),
//               contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//             ),
//             style: GoogleFonts.poppins(fontSize: 14),
//           ),
//         ),
//         Expanded(
//           child: _isLoading
//               ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
//               : ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
//                   itemCount: _filteredUsers.length,
//                   itemBuilder: (context, index) {
//                     final user = _filteredUsers[index];
//                     final firstLetter = user['firstName']?.toString().substring(0, 1) ?? 'U';
//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 12.0),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(10),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.2),
//                             spreadRadius: 1,
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: ListTile(
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                         leading: CircleAvatar(
//                           backgroundColor: _getColorForLetter(firstLetter),
//                           child: user['profilePicture'] != null && user['profilePicture'].isNotEmpty
//                               ? ClipOval(
//                                   child: Image.network(
//                                     '$baseUrl${user['profilePicture']}',
//                                     fit: BoxFit.cover,
//                                     width: 40,
//                                     height: 40,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       print('Image load failed for ${user['_id']}: $error');
//                                       return Text(
//                                         firstLetter,
//                                         style: GoogleFonts.poppins(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 )
//                               : Text(
//                                   firstLetter,
//                                   style: GoogleFonts.poppins(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                         ),
//                         title: Text(
//                           '${user['firstName'] ?? 'Unknown'} ${user['lastName'] ?? ''}',
//                           style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
//                         ),
//                         subtitle: Text(
//                           user['email'] ?? 'No email',
//                           style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                         ),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: Icon(Icons.delete, color: primaryColor),
//                               onPressed: () async {
//                                 if (user['role'] == 'admin') {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text('Cannot delete admin users'),
//                                     ),
//                                   );
//                                   return;
//                                 }
//                                 final confirm = await showDialog<bool>(
//                                   context: context,
//                                   builder: (context) => AlertDialog(
//                                     title: Text(
//                                       'Confirm Delete',
//                                       style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
//                                     ),
//                                     content: Text(
//                                       'Are you sure you want to delete this user?',
//                                       style: GoogleFonts.poppins(fontSize: 14),
//                                     ),
//                                     actions: [
//                                       TextButton(
//                                         onPressed: () => Navigator.pop(context, false),
//                                         child: Text(
//                                           'Cancel',
//                                           style: GoogleFonts.poppins(fontSize: 14, color: primaryColor),
//                                         ),
//                                       ),
//                                       TextButton(
//                                         onPressed: () => Navigator.pop(context, true),
//                                         child: Text(
//                                           'Delete',
//                                           style: GoogleFonts.poppins(fontSize: 14, color: primaryColor),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                                 if (confirm == true) {
//                                   await _deleteUser(user['_id'], user);
//                                 }
//                               },
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.edit, color: primaryColor),
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => EditUserPage(
//                                       user: user,
//                                       onUserUpdated: () {
//                                         _fetchUsers(); // Refresh the user list after update
//                                       },
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   Color _getColorForLetter(String letter) {
//     switch (letter.toUpperCase()) {
//       case 'W':
//         return const Color(0xFF8BC34A);
//       case 'F':
//         return const Color(0xFF2196F3);
//       case 'M':
//         return const Color(0xFF4CAF50);
//       case 'L':
//         return const Color(0xFF9C27B0);
//       case 'N':
//         return const Color(0xFF673AB7);
//       case 'J':
//         return const Color(0xFF03A9F4);
//       default:
//         return const Color(0xFFF44336);
//     }
//   }
// }

// class EditUserPage extends StatefulWidget {
//   final Map<String, dynamic> user;
//   final VoidCallback onUserUpdated;

//   const EditUserPage({super.key, required this.user, required this.onUserUpdated});

//   @override
//   _EditUserPageState createState() => _EditUserPageState();
// }

// class _EditUserPageState extends State<EditUserPage> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _firstNameController;
//   late TextEditingController _lastNameController;
//   late TextEditingController _emailController;
//   bool _isLoading = false;

//   // Color scheme from checkout.dart
//   final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

//   @override
//   void initState() {
//     super.initState();
//     _firstNameController = TextEditingController(text: widget.user['firstName'] ?? '');
//     _lastNameController = TextEditingController(text: widget.user['lastName'] ?? '');
//     _emailController = TextEditingController(text: widget.user['email'] ?? '');
//   }

//   Future<void> _updateUser() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         final url = 'http://localhost:3000/admin/users/users/${widget.user['_id']}';
//         print('Updating user with URL: $url');
//         final response = await http.put(
//           Uri.parse(url),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'firstName': _firstNameController.text,
//             'lastName': _lastNameController.text,
//             'email': _emailController.text,
//           }),
//         );
//         print('Update User Response: ${response.statusCode} - ${response.body}');

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('User updated successfully')),
//           );
//           widget.onUserUpdated(); // Refresh the user list
//           Navigator.pop(context); // Go back to UsersPage
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to update user: ${response.statusCode} - ${response.body}'),
//             ),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating user: $e')),
//         );
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
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
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Text(
//           'Edit User',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Edit User Details',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: primaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _firstNameController,
//                   decoration: InputDecoration(
//                     labelText: 'First Name',
//                     labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                     filled: true,
//                     fillColor: Colors.grey[100],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: primaryColor, width: 1),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: primaryColor, width: 1),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: primaryColor, width: 1.5),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                   ),
//                   validator: (value) => value!.isEmpty ? 'Enter first name' : null,
//                   style: GoogleFonts.poppins(fontSize: 14),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _lastNameController,
//                   decoration: InputDecoration(
//                     labelText: 'Last Name',
//                     labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                     filled: true,
//                     fillColor: Colors.grey[100],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: primaryColor, width: 1),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: primaryColor, width: 1),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: primaryColor, width: 1.5),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                   ),
//                   validator: (value) => value!.isEmpty ? 'Enter last name' : null,
//                   style: GoogleFonts.poppins(fontSize: 14),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                     filled: true,
//                     fillColor: Colors.grey[100],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: primaryColor, width: 1),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: primaryColor, width: 1),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide(color: primaryColor, width: 1.5),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                   ),
//                   validator: (value) => value!.isEmpty ? 'Enter email' : null,
//                   style: GoogleFonts.poppins(fontSize: 14),
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _updateUser,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryColor,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       elevation: 3,
//                       shadowColor: Colors.grey.withOpacity(0.5),
//                     ),
//                     child: _isLoading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : Text(
//                             'Update User',
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }