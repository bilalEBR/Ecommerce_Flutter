
// // seller_page.dart
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'baseurl.dart';

// class SellerPage extends StatefulWidget {
//   const SellerPage({super.key});

//   @override
//   _SellerPageState createState() => _SellerPageState();
// }

// class _SellerPageState extends State<SellerPage> {
//   List<dynamic> _sellers = [];
//   List<dynamic> _filteredSellers = [];
//   bool _isLoading = true;
//   String _searchQuery = '';
//   // final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchSellers();
//   }

//   Future<void> _fetchSellers() async {
//     setState(() => _isLoading = true);
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/sellers'),
//       );
//       print('Fetch Sellers Response: ${response.statusCode} - ${response.body}');
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _sellers = data;
//           _filteredSellers = data;
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to load sellers: ${response.statusCode} - ${response.body}'),
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching sellers: $e')),
//       );
//     }
//   }

//   void _filterSellers(String query) {
//     setState(() {
//       _searchQuery = query;
//       _filteredSellers = _sellers.where((seller) {
//         final firstName = seller['firstName']?.toString().toLowerCase() ?? '';
//         final lastName = seller['lastName']?.toString().toLowerCase() ?? '';
//         final email = seller['email']?.toString().toLowerCase() ?? '';
//         final searchLower = query.toLowerCase();
//         return firstName.contains(searchLower) ||
//             lastName.contains(searchLower) ||
//             email.contains(searchLower);
//       }).toList();
//     });
//   }

//   Future<void> _deleteSeller(String sellerId) async {
//     try {
//       print('Attempting to delete seller with ID: $sellerId');
//       final url = '$baseUrl/admin/sellers/$sellerId';
//       print('DELETE request URL: $url');
//       final response = await http.delete(Uri.parse(url));
//       print('Delete Seller Response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         setState(() {
//           _sellers.removeWhere((s) => s['_id'] == sellerId);
//           _filteredSellers.removeWhere((s) => s['_id'] == sellerId);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Seller deleted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to delete seller: ${response.statusCode} - ${response.body}'),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Exception during DELETE request: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting seller: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   onChanged: _filterSellers,
//                   decoration: InputDecoration(
//                     prefixIcon: const Icon(Icons.search, color: Color(0xFFAB47BC)),
//                     hintText: 'Search by name or email',
//                     hintStyle: const TextStyle(color: Colors.grey),
//                     filled: true,
//                     fillColor: const Color(0xFFE0E0E0),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Colors.green, width: 2),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               IconButton(
//                 icon: const Icon(Icons.add, color: Color(0xFFAB47BC)),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => AddSellerPage(
//                         onSellerAdded: () {
//                           _fetchSellers(); // Refresh the seller list after adding
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : ListView.builder(
//                   itemCount: _filteredSellers.length,
//                   itemBuilder: (context, index) {
//                     final seller = _filteredSellers[index];
//                     final firstLetter = seller['firstName']?.toString().substring(0, 1) ?? 'S';
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
//                         '${seller['firstName'] ?? 'Unknown'} ${seller['lastName'] ?? ''}',
//                         style: GoogleFonts.poppins(fontSize: 16),
//                       ),
//                       subtitle: Text(
//                         seller['email'] ?? 'No email',
//                         style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
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
//                               final confirm = await showDialog<bool>(
//                                 context: context,
//                                 builder: (context) => AlertDialog(
//                                   title: const Text('Confirm Delete'),
//                                   content: Text(
//                                     'Are you sure you want to delete the seller "${seller['firstName']} ${seller['lastName']}"?',
//                                   ),
//                                   actions: [
//                                     TextButton(
//                                       onPressed: () => Navigator.pop(context, false),
//                                       child: const Text('Cancel'),
//                                     ),
//                                     TextButton(
//                                       onPressed: () => Navigator.pop(context, true),
//                                       child: const Text('Delete'),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                               if (confirm == true) {
//                                 await _deleteSeller(seller['_id']);
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
//                                   builder: (context) => EditSellerPage(
//                                     seller: seller,
//                                     onSellerUpdated: () {
//                                       _fetchSellers(); // Refresh the seller list after updating
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
//       case 'S':
//         return const Color(0xFF8BC34A);
//       case 'D':
//         return const Color(0xFF2196F3);
//       case 'W':
//         return const Color(0xFF4CAF50);
//       case 'M':
//         return const Color(0xFF9C27B0);
//       case 'J':
//         return const Color(0xFF03A9F4);
//       case 'F':
//         return const Color(0xFFF44336);
//       default:
//         return const Color(0xFFF44336);
//     }
//   }
// }

// class AddSellerPage extends StatefulWidget {
//   final VoidCallback onSellerAdded;

//   const AddSellerPage({super.key, required this.onSellerAdded});

//   @override
//   _AddSellerPageState createState() => _AddSellerPageState();
// }

// class _AddSellerPageState extends State<AddSellerPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _isLoading = false;
//   final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';

//   Future<void> _addSeller() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();

//       // Check if passwords match
//       if (_passwordController.text != _confirmPasswordController.text) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Passwords do not match')),
//         );
//         return;
//       }

//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         final response = await http.post(
//           Uri.parse('$baseUrl/admin/sellers'),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'firstName': _firstNameController.text,
//             'lastName': _lastNameController.text,
//             'email': _emailController.text,
//             'password': _passwordController.text,
//             'role': 'seller', // Add role: "seller" to the request body
//           }),
//         );
//         print('Add Seller Response: ${response.statusCode} - ${response.body}');

//         if (response.statusCode == 201) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Seller added successfully')),
//           );
//           widget.onSellerAdded();
//           Navigator.pop(context);
//         } else {
//           final responseData = jsonDecode(response.body);
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to add seller: ${responseData['error'] ?? response.body}'),
//             ),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error adding seller: $e')),
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
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
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
//           'Add Seller',
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
//                   'Add New Seller',
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
//                   validator: (value) => value!.isEmpty ? 'Enter first name' : null,
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
//                   validator: (value) => value!.isEmpty ? 'Enter last name' : null,
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
//                   validator: (value) {
//                     if (value!.isEmpty) return 'Enter email';
//                     if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                       return 'Enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _passwordController,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   obscureText: true,
//                   validator: (value) => value!.isEmpty ? 'Enter password' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _confirmPasswordController,
//                   decoration: InputDecoration(
//                     labelText: 'Re-enter Password',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   obscureText: true,
//                   validator: (value) => value!.isEmpty ? 'Confirm your password' : null,
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _addSeller,
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
//                             'Add Seller',
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

// class EditSellerPage extends StatefulWidget {
//   final Map<String, dynamic> seller;
//   final VoidCallback onSellerUpdated;

//   const EditSellerPage({super.key, required this.seller, required this.onSellerUpdated});

//   @override
//   _EditSellerPageState createState() => _EditSellerPageState();
// }

// class _EditSellerPageState extends State<EditSellerPage> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _firstNameController;
//   late TextEditingController _lastNameController;
//   late TextEditingController _emailController;
//   bool _isLoading = false;
//   final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';

//   @override
//   void initState() {
//     super.initState();
//     _firstNameController = TextEditingController(text: widget.seller['firstName'] ?? '');
//     _lastNameController = TextEditingController(text: widget.seller['lastName'] ?? '');
//     _emailController = TextEditingController(text: widget.seller['email'] ?? '');
//   }

//   Future<void> _updateSeller() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         print('Updating seller with ID: ${widget.seller['_id']}');
//         print('Request data: firstName=${_firstNameController.text}, lastName=${_lastNameController.text}, email=${_emailController.text}');

//         final response = await http.put(
//           Uri.parse('$baseUrl/admin/sellers/${widget.seller['_id']}'),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'firstName': _firstNameController.text,
//             'lastName': _lastNameController.text,
//             'email': _emailController.text,
//           }),
//         );
//         print('Update Seller Response: ${response.statusCode} - ${response.body}');

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Seller updated successfully')),
//           );
//           widget.onSellerUpdated();
//           Navigator.pop(context);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to update seller: ${response.statusCode} - ${response.body}'),
//             ),
//           );
//         }
//       } catch (e) {
//         print('Exception during PUT request: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating seller: $e')),
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
//           'Edit Seller',
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
//                   'Edit Seller Details',
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
//                   validator: (value) => value!.isEmpty ? 'Enter first name' : null,
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
//                   validator: (value) => value!.isEmpty ? 'Enter last name' : null,
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
//                   validator: (value) {
//                     if (value!.isEmpty) return 'Enter email';
//                     if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                       return 'Enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _updateSeller,
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
//                             'Update Seller',
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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'baseurl.dart';

class SellerPage extends StatefulWidget {
  const SellerPage({super.key});

  @override
  _SellerPageState createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  List<dynamic> _sellers = [];
  List<dynamic> _filteredSellers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  // Color scheme from checkout.dart
  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

  @override
  void initState() {
    super.initState();
    _fetchSellers();
  }

  Future<void> _fetchSellers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/sellers'),
      );
      print('Fetch Sellers Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _sellers = data;
          _filteredSellers = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load sellers: ${response.statusCode} - ${response.body}'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching sellers: $e')),
      );
    }
  }

  void _filterSellers(String query) {
    setState(() {
      _searchQuery = query;
      _filteredSellers = _sellers.where((seller) {
        final firstName = seller['firstName']?.toString().toLowerCase() ?? '';
        final lastName = seller['lastName']?.toString().toLowerCase() ?? '';
        final email = seller['email']?.toString().toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return firstName.contains(searchLower) ||
            lastName.contains(searchLower) ||
            email.contains(searchLower);
      }).toList();
    });
  }

  Future<void> _deleteSeller(String sellerId) async {
    try {
      print('Attempting to delete seller with ID: $sellerId');
      final url = '$baseUrl/admin/sellers/$sellerId';
      print('DELETE request URL: $url');
      final response = await http.delete(Uri.parse(url));
      print('Delete Seller Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _sellers.removeWhere((s) => s['_id'] == sellerId);
          _filteredSellers.removeWhere((s) => s['_id'] == sellerId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seller deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete seller: ${response.statusCode} - ${response.body}'),
          ),
        );
      }
    } catch (e) {
      print('Exception during DELETE request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting seller: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: _filterSellers,
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
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.add, color: primaryColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddSellerPage(
                        onSellerAdded: () {
                          _fetchSellers(); // Refresh the seller list after adding
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  itemCount: _filteredSellers.length,
                  itemBuilder: (context, index) {
                    final seller = _filteredSellers[index];
                    final firstLetter = seller['firstName']?.toString().substring(0, 1) ?? 'S';
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
                          '${seller['firstName'] ?? 'Unknown'} ${seller['lastName'] ?? ''}',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
                        ),
                        subtitle: Text(
                          seller['email'] ?? 'No email',
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: primaryColor),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Confirm Delete',
                                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete the seller "${seller['firstName']} ${seller['lastName']}"?',
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
                                  await _deleteSeller(seller['_id']);
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: primaryColor),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditSellerPage(
                                      seller: seller,
                                      onSellerUpdated: () {
                                        _fetchSellers(); // Refresh the seller list after updating
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
      case 'S':
        return const Color(0xFF8BC34A);
      case 'D':
        return const Color(0xFF2196F3);
      case 'W':
        return const Color(0xFF4CAF50);
      case 'M':
        return const Color(0xFF9C27B0);
      case 'J':
        return const Color(0xFF03A9F4);
      case 'F':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFFF44336);
    }
  }
}

class AddSellerPage extends StatefulWidget {
  final VoidCallback onSellerAdded;

  const AddSellerPage({super.key, required this.onSellerAdded});

  @override
  _AddSellerPageState createState() => _AddSellerPageState();
}

class _AddSellerPageState extends State<AddSellerPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // Color scheme from checkout.dart
  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

  Future<void> _addSeller() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Check if passwords match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/admin/sellers'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'role': 'seller', // Add role: "seller" to the request body
          }),
        );
        print('Add Seller Response: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Seller added successfully')),
          );
          widget.onSellerAdded();
          Navigator.pop(context);
        } else {
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add seller: ${responseData['error'] ?? response.body}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding seller: $e')),
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          'Add Seller',
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
                  validator: (value) {
                    if (value!.isEmpty) return 'Enter email';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Enter password' : null,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Re-enter Password',
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
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Confirm your password' : null,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addSeller,
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
                            'Add Seller',
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

class EditSellerPage extends StatefulWidget {
  final Map<String, dynamic> seller;
  final VoidCallback onSellerUpdated;

  const EditSellerPage({super.key, required this.seller, required this.onSellerUpdated});

  @override
  _EditSellerPageState createState() => _EditSellerPageState();
}

class _EditSellerPageState extends State<EditSellerPage> {
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
    _firstNameController = TextEditingController(text: widget.seller['firstName'] ?? '');
    _lastNameController = TextEditingController(text: widget.seller['lastName'] ?? '');
    _emailController = TextEditingController(text: widget.seller['email'] ?? '');
  }

  Future<void> _updateSeller() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        print('Updating seller with ID: ${widget.seller['_id']}');
        print('Request data: firstName=${_firstNameController.text}, lastName=${_lastNameController.text}, email=${_emailController.text}');

        final response = await http.put(
          Uri.parse('$baseUrl/admin/sellers/${widget.seller['_id']}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'email': _emailController.text,
          }),
        );
        print('Update Seller Response: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Seller updated successfully')),
          );
          widget.onSellerUpdated();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update seller: ${response.statusCode} - ${response.body}'),
            ),
          );
        }
      } catch (e) {
        print('Exception during PUT request: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating seller: $e')),
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
          'Edit Seller',
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
                  validator: (value) {
                    if (value!.isEmpty) return 'Enter email';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateSeller,
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
                            'Update Seller',
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