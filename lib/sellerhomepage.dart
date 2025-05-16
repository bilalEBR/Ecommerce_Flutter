


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// // import 'chatpage.dart';
// import 'sellerchat.dart';

// class SellerHomePage extends StatefulWidget {
//   final String sellerId;
//   final String token; // Make token non-nullable

//   const SellerHomePage({super.key, required this.sellerId, required this.token});

//   @override
//   _SellerHomePageState createState() => _SellerHomePageState();
// }

// class _SellerHomePageState extends State<SellerHomePage> {
//   int _selectedIndex = 0;
//   String _sellerName = "John Doe";
//   String? _profilePicture;
//   final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchSellerProfile();
//   }

//   Future<void> _fetchSellerProfile() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _sellerName = '${data['firstName']} ${data['lastName']}';
//           _profilePicture = data['profilePicture'];
//         });
//       } else {
//         print('Failed to load seller profile: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching seller profile: $e');
//     }
//   }

//   late final List<Widget> _pages;

//  @override
// void didChangeDependencies() {
//   super.didChangeDependencies();
//   _pages = [
//     AddProductPage(sellerId: widget.sellerId, token: widget.token),
//     const OrdersPage(),
//     SellerChatListPage(token: widget.token, sellerId: widget.sellerId), // Pass sellerId
//     const DeliveryPage(),
//   ];
// }

//   void _onItemTapped(int index) {
//     if (index == 4) {
//       print('Navigating to Set Profile Page');
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SetProfilePage(
//             sellerId: widget.sellerId,
//             token: widget.token,
//           ),
//         ),
//       ).then((_) {
//         print('Returned from Set Profile Page');
//         _fetchSellerProfile();
//       });
//     } else if (index == 5) {
//       print('Logging out');
//       Navigator.pushReplacementNamed(context, '/login');
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Seller Panel',
//           style: GoogleFonts.poppins(),
//         ),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserAccountsDrawerHeader(
//               accountName: Text(
//                 _sellerName,
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               accountEmail: Text(
//                 'Welcome, $_sellerName',
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   color: Colors.white70,
//                 ),
//               ),
//               currentAccountPicture: _profilePicture != null
//                   ? CircleAvatar(
//                       backgroundImage: NetworkImage('$baseUrl$_profilePicture'),
//                       onBackgroundImageError: (exception, stackTrace) {
//                         print('Error loading profile picture: $exception');
//                       },
//                     )
//                   : CircleAvatar(
//                       backgroundColor: Colors.purple,
//                       child: Text(
//                         'P',
//                         style: GoogleFonts.poppins(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//               decoration: const BoxDecoration(
//                 color: Colors.purple,
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.inventory),
//               title: Text(
//                 'Products',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 0,
//               onTap: () {
//                 _onItemTapped(0);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.shopping_cart),
//               title: Text(
//                 'Orders',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 1,
//               onTap: () {
//                 _onItemTapped(1);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.chat),
//               title: Text(
//                 'Chat',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 2,
//               onTap: () {
//                 _onItemTapped(2);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.local_shipping),
//               title: Text(
//                 'Delivery',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 3,
//               onTap: () {
//                 _onItemTapped(3);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: Text(
//                 'Set Profile',
//                 style: GoogleFonts.poppins(),
//               ),
//               onTap: () {
//                 _onItemTapped(4);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: Text(
//                 'Logout',
//                 style: GoogleFonts.poppins(),
//               ),
//               onTap: () {
//                 _onItemTapped(5);
//               },
//             ),
//           ],
//         ),
//       ),
//       body: _pages[_selectedIndex],
//     );
//   }
// }



// // Set Profile Page
// class SetProfilePage extends StatefulWidget {
//   final String sellerId;
//   final String? token; // Add optional token parameter

//   const SetProfilePage({super.key, required this.sellerId, this.token});

//   @override
//   _SetProfilePageState createState() => _SetProfilePageState();
// }

// class _SetProfilePageState extends State<SetProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   PlatformFile? _selectedProfilePicture;
//   final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchSellerProfile();
//   }

//   Future<void> _fetchSellerProfile() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _firstNameController.text = data['firstName'] ?? '';
//           _lastNameController.text = data['lastName'] ?? '';
//           _emailController.text = data['email'] ?? '';
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load profile: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching profile: $e')),
//       );
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
//         );
//         if (widget.token != null) {
//           request.headers['Authorization'] = 'Bearer ${widget.token}';
//         }
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
//           Navigator.pop(context);
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
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Set Profile',
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
//                   'Set Profile',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(
//                         type: FileType.image,
//                         allowMultiple: false,
//                       );
//                       if (result != null && result.files.isNotEmpty) {
//                         setState(() {
//                           _selectedProfilePicture = result.files.first;
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No file selected')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error selecting image: $e')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     _selectedProfilePicture == null
//                         ? 'Select Profile Picture'
//                         : 'Image Selected: ${_selectedProfilePicture!.name}',
//                     style: GoogleFonts.poppins(),
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
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter email' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _passwordController,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     suffixIcon: TextButton(
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Change Password feature coming soon')),
//                         );
//                       },
//                       child: const Text('Change Password'),
//                     ),
//                   ),
//                   obscureText: true,
//                   enabled: false,
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _updateProfile,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: Text(
//                       'Update Profile',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
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

// // Product List Page
// class AddProductPage extends StatefulWidget {
//   final String sellerId;
//   final String? token; // Add optional token parameter

//   const AddProductPage({super.key, required this.sellerId, this.token});

//   @override
//   _AddProductPageState createState() => _AddProductPageState();
// }

// class _AddProductPageState extends State<AddProductPage> {
//   List<dynamic> _products = [];
//   List<dynamic> _filteredProducts = [];
//   bool _isLoading = true;
//   String _searchQuery = '';
//   final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchProducts();
//   }

//   Future<void> _fetchProducts() async {
//     setState(() => _isLoading = true);
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/seller/products/${widget.sellerId}'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _products = data;
//           _filteredProducts = data;
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load products: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching products: $e')),
//       );
//     }
//   }

//   Future<void> _deleteProduct(String productId) async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.delete(
//         Uri.parse('$baseUrl/seller/products/$productId'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           _products.removeWhere((p) => p['_id'] == productId);
//           _filteredProducts.removeWhere((p) => p['_id'] == productId);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Product deleted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete product: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting product: $e')),
//       );
//     }
//   }

//   void _filterProducts(String query) {
//     setState(() {
//       _searchQuery = query;
//       _filteredProducts = _products.where((product) {
//         final title = product['title']?.toString().toLowerCase() ?? '';
//         final searchLower = query.toLowerCase();
//         return title.contains(searchLower);
//       }).toList();
//     });
//   }

//   void _showDeleteConfirmationDialog(BuildContext context, String productId, String productTitle) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: Text(
//             'Delete Product',
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.red,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete the product "$productTitle"?',
//             style: GoogleFonts.poppins(fontSize: 16),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Cancel',
//                 style: GoogleFonts.poppins(color: Colors.red),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 _deleteProduct(productId);
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Delete',
//                 style: GoogleFonts.poppins(color: Colors.red),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Row(
//           children: [
//             Text(
//               'Products (${_filteredProducts.length})',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const Spacer(),
//             IconButton(
//               icon: const Icon(Icons.add, color: Colors.white),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => AddProductFormPage(
//                       sellerId: widget.sellerId,
//                       token: widget.token,
//                     ),
//                   ),
//                 ).then((_) => _fetchProducts());
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               onChanged: _filterProducts,
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.search, color: Colors.purple),
//                 hintText: 'Search by product name',
//                 hintStyle: const TextStyle(color: Colors.grey),
//                 filled: true,
//                 fillColor: const Color(0xFFE0E0E0),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: Colors.purple, width: 2),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//                     itemCount: _filteredProducts.length,
//                     itemBuilder: (context, index) {
//                       final product = _filteredProducts[index];
//                       final imageUrl = product['image'] != null
//                           ? '$baseUrl${product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
//                           : null;
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12.0),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.3),
//                                 spreadRadius: 2,
//                                 blurRadius: 5,
//                                 offset: const Offset(0, 3),
//                               ),
//                             ],
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                           ),
//                           child: ListTile(
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                             leading: imageUrl != null
//                                 ? CircleAvatar(
//                                     radius: 30,
//                                     backgroundImage: NetworkImage(imageUrl),
//                                     backgroundColor: Colors.grey[300],
//                                     onBackgroundImageError: (exception, stackTrace) {
//                                       print('Error loading product image: $exception');
//                                     },
//                                   )
//                                 : CircleAvatar(
//                                     radius: 30,
//                                     backgroundColor: Colors.grey[300],
//                                     child: const Text('No Image'),
//                                   ),
//                             title: Text(
//                               product['title'] ?? 'Unknown Product',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             trailing: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.edit, color: Colors.purple),
//                                   onPressed: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => EditProductFormPage(
//                                           product: product,
//                                           sellerId: widget.sellerId,
//                                           token: widget.token,
//                                         ),
//                                       ),
//                                     ).then((_) => _fetchProducts());
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.purple),
//                                   onPressed: () {
//                                     _showDeleteConfirmationDialog(
//                                       context,
//                                       product['_id'].toString(),
//                                       product['title'] ?? 'Unknown Product',
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Add Product Form Page
// class AddProductFormPage extends StatefulWidget {
//   final String sellerId;
//   final String? token; // Add optional token parameter

//   const AddProductFormPage({super.key, required this.sellerId, this.token});

//   @override
//   _AddProductFormPageState createState() => _AddProductFormPageState();
// }

// class _AddProductFormPageState extends State<AddProductFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _quantityController = TextEditingController();
//   String? _selectedCategoryId;
//   PlatformFile? _selectedImageFile;
//   List<dynamic> _categories = [];
//   final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchCategories();
//   }

//   Future<void> _fetchCategories() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/categories'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print('Fetched categories for dropdown: $data');
//         setState(() {
//           _categories = data;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load categories: ${response.statusCode} - ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching categories: $e')),
//       );
//     }
//   }

//   Future<void> _addProduct(String title, String price, String description, String categoryId, PlatformFile? imageFile, String quantity) async {
//     if (imageFile == null || categoryId.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an image and a category')),
//       );
//       return;
//     }

//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/seller/products'),
//       );
//       if (widget.token != null) {
//         request.headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       request.fields['title'] = title;
//       request.fields['price'] = price;
//       request.fields['description'] = description;
//       request.fields['categoryId'] = categoryId;
//       request.fields['sellerId'] = widget.sellerId;
//       request.fields['quantity'] = quantity;

//       final bytes = <int>[];
//       if (imageFile.readStream != null) {
//         await for (var chunk in imageFile.readStream!) {
//           bytes.addAll(chunk);
//         }
//       } else if (imageFile.bytes != null) {
//         bytes.addAll(imageFile.bytes!);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('File data is unavailable')),
//         );
//         return;
//       }

//       print('Uploading file with ${bytes.length} bytes');
//       request.files.add(
//         http.MultipartFile.fromBytes(
//           'image',
//           bytes,
//           filename: imageFile.name,
//           contentType: MediaType('image', imageFile.extension ?? 'jpeg'),
//         ),
//       );

//       final response = await request.send();
//       final responseBody = await http.Response.fromStream(response);

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Product added successfully')),
//         );
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to add product: ${responseBody.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error in _addProduct: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error adding product: $e')),
//       );
//     }
//   }

//   void _clearForm() {
//     _titleController.clear();
//     _priceController.clear();
//     _descriptionController.clear();
//     _quantityController.clear();
//     _selectedCategoryId = null;
//     _selectedImageFile = null;
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     _quantityController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Add Product',
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
//                   'Add Product',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product title' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _priceController,
//                   decoration: InputDecoration(
//                     labelText: 'Price',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product price' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   maxLines: 3,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product description' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _quantityController,
//                   decoration: InputDecoration(
//                     labelText: 'Quantity',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product quantity' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: 'Category',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   value: _selectedCategoryId,
//                   hint: const Text('Select Category'),
//                   items: _categories.map((category) {
//                     return DropdownMenuItem<String>(
//                       value: category['_id'].toString(),
//                       child: Text(category['name']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCategoryId = value;
//                     });
//                   },
//                   validator: (value) =>
//                       value == null ? 'Please select a category' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(
//                         type: FileType.image,
//                         allowMultiple: false,
//                       );
//                       if (result != null && result.files.isNotEmpty) {
//                         setState(() {
//                           _selectedImageFile = result.files.first;
//                           print('Selected file: ${_selectedImageFile?.name}');
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No file selected')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error selecting image: $e')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     _selectedImageFile == null
//                         ? 'Select Product Image'
//                         : 'Image Selected: ${_selectedImageFile!.name}',
//                     style: GoogleFonts.poppins(),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         _addProduct(
//                           _titleController.text,
//                           _priceController.text,
//                           _descriptionController.text,
//                           _selectedCategoryId!,
//                           _selectedImageFile,
//                           _quantityController.text,
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: Text(
//                       'Add Product',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
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

// // Edit Product Form Page
// class EditProductFormPage extends StatefulWidget {
//   final Map<String, dynamic> product;
//   final String sellerId;
//   final String? token; // Add optional token parameter

//   const EditProductFormPage({super.key, required this.product, required this.sellerId, this.token});

//   @override
//   _EditProductFormPageState createState() => _EditProductFormPageState();
// }

// class _EditProductFormPageState extends State<EditProductFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _quantityController = TextEditingController();
//   String? _selectedCategoryId;
//   PlatformFile? _selectedImageFile;
//   String? _currentImageUrl;
//   List<dynamic> _categories = [];
//   final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _titleController.text = widget.product['title'] ?? '';
//     _priceController.text = widget.product['price']?.toString() ?? '';
//     _descriptionController.text = widget.product['description'] ?? '';
//     _quantityController.text = widget.product['quantity']?.toString() ?? '';
//     _selectedCategoryId = widget.product['categoryId']?.toString();
//     _currentImageUrl = widget.product['image'];
//     _fetchCategories();
//   }

//   Future<void> _fetchCategories() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/categories'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _categories = data;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load categories: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching categories: $e')),
//       );
//     }
//   }

//   Future<void> _updateProduct() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/seller/products/${widget.product['_id']}'),
//         );
//         if (widget.token != null) {
//           request.headers['Authorization'] = 'Bearer ${widget.token}';
//         }
//         request.fields['title'] = _titleController.text;
//         request.fields['price'] = _priceController.text;
//         request.fields['description'] = _descriptionController.text;
//         request.fields['quantity'] = _quantityController.text;
//         request.fields['categoryId'] = _selectedCategoryId!;
//         request.fields['sellerId'] = widget.sellerId;

//         if (_selectedImageFile != null) {
//           final bytes = <int>[];
//           if (_selectedImageFile!.readStream != null) {
//             await for (var chunk in _selectedImageFile!.readStream!) {
//               bytes.addAll(chunk);
//             }
//           } else if (_selectedImageFile!.bytes != null) {
//             bytes.addAll(_selectedImageFile!.bytes!);
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('File data is unavailable')),
//             );
//             return;
//           }

//           request.files.add(
//             http.MultipartFile.fromBytes(
//               'image',
//               bytes,
//               filename: _selectedImageFile!.name,
//               contentType: MediaType('image', _selectedImageFile!.extension ?? 'jpeg'),
//             ),
//           );
//         } else {
//           request.fields['image'] = _currentImageUrl ?? '';
//         }

//         print('Updating product with fields: ${request.fields}');
//         print('Files: ${request.files.map((file) => file.filename).toList()}');

//         final response = await request.send();
//         final responseBody = await http.Response.fromStream(response);

//         print('Response status: ${response.statusCode}');
//         print('Response body: ${responseBody.body}');

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Product updated successfully')),
//           );
//           Navigator.pop(context);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to update product: ${responseBody.body}')),
//           );
//         }
//       } catch (error) {
//         print('Error updating product: $error');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating product: $error')),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     _quantityController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Edit Product',
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
//                   'Edit Product',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product title' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _priceController,
//                   decoration: InputDecoration(
//                     labelText: 'Price',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product price' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   maxLines: 3,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product description' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _quantityController,
//                   decoration: InputDecoration(
//                     labelText: 'Quantity',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product quantity' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: 'Category',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   value: _selectedCategoryId,
//                   hint: const Text('Select Category'),
//                   items: _categories.map((category) {
//                     return DropdownMenuItem<String>(
//                       value: category['_id'].toString(),
//                       child: Text(category['name']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCategoryId = value;
//                     });
//                   },
//                   validator: (value) =>
//                       value == null ? 'Please select a category' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 _currentImageUrl != null
//                     ? Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Current Image:',
//                             style: GoogleFonts.poppins(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Image.network(
//                             '$baseUrl$_currentImageUrl',
//                             height: 100,
//                             width: 100,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return const Text('Error loading image');
//                             },
//                           ),
//                         ],
//                       )
//                     : const SizedBox.shrink(),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(
//                         type: FileType.image,
//                         allowMultiple: false,
//                       );
//                       if (result != null && result.files.isNotEmpty) {
//                         setState(() {
//                           _selectedImageFile = result.files.first;
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No file selected')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error selecting image: $e')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     _selectedImageFile == null
//                         ? 'Select New Product Image'
//                         : 'Image Selected: ${_selectedImageFile!.name}',
//                     style: GoogleFonts.poppins(),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _updateProduct,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: Text(
//                       'Update Product',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
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

// // Placeholder Pages
// class OrdersPage extends StatelessWidget {
//   const OrdersPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Orders Page - Under Development',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

// // class ChatPage extends StatelessWidget {
// //   const ChatPage({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Text(
// //         'Chat Page - Under Development',
// //         style: GoogleFonts.poppins(
// //           fontSize: 20,
// //           fontWeight: FontWeight.bold,
// //         ),
// //       ),
// //     );
// //   }
// // }

// class DeliveryPage extends StatelessWidget {
//   const DeliveryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Delivery Page - Under Development',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }






// class SellerChatListPage extends StatefulWidget {
//   final String token;
//   final String sellerId; // Add sellerId

//   const SellerChatListPage({
//     super.key,
//     required this.token,
//     required this.sellerId,
//   });

//   @override
//   _SellerChatListPageState createState() => _SellerChatListPageState();
// }

// class _SellerChatListPageState extends State<SellerChatListPage> {
//   List<dynamic> _chats = [];
//   bool _isLoading = true;
//   final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchChats();
//   }

//   Future<void> _fetchChats() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/chat/seller'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _chats = data;
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load chats: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching chats: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Chats',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _chats.isEmpty
//               ? const Center(
//                   child: Text(
//                     'No chats available',
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                   ),
//                 )
//               : ListView.builder(
//                   padding: const EdgeInsets.all(16.0),
//                   itemCount: _chats.length,
//                   itemBuilder: (context, index) {
//                     final chat = _chats[index];
//                     return Card(
//                       margin: const EdgeInsets.symmetric(vertical: 8.0),
//                       child: ListTile(
//                         title: Text(
//                           'Product: ${chat['productName']}',
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Client: ${chat['clientName']}',
//                               style: GoogleFonts.poppins(fontSize: 14),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               chat['latestMessage'],
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14,
//                                 color: Colors.grey,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                         trailing: Text(
//                           _formatDateTime(chat['latestMessageTime']),
//                           style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
//                         ),


//                         onTap: () {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => SellerChatPage(
//         chatId: chat['_id'].toString(),
//         productName: chat['productName'],
//         sellerId: widget.sellerId,
//         token: widget.token, // Pass the token
//       ),
//     ),
//   );
// },

//                       ),
//                     );
//                   },
//                 ),
//     );
//   }

//   String _formatDateTime(String dateTime) {
//     final date = DateTime.parse(dateTime);
//     final now = DateTime.now();
//     final difference = now.difference(date);
//     if (difference.inDays > 0) {
//       return '${difference.inDays}d ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes}m ago';
//     } else {
//       return 'Just now';
//     }
//   }
// }


// new version to add product status 


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'sellerchat.dart';
// import 'sellerchangepassword.dart';
// // import 'auth-service.dart';
// import 'baseurl.dart';

// class SellerHomePage extends StatefulWidget {
//   final String sellerId;
//   final String token;

//   const SellerHomePage({super.key, required this.sellerId, required this.token});

//   @override
//   _SellerHomePageState createState() => _SellerHomePageState();
// }

// class _SellerHomePageState extends State<SellerHomePage> {
//   int _selectedIndex = 0;
//   String _sellerName = "John Doe";
//   String? _profilePicture;
//   // final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchSellerProfile();
//   }

//   Future<void> _fetchSellerProfile() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _sellerName = '${data['firstName']} ${data['lastName']}';
//           _profilePicture = data['profilePicture'];
//         });
//       } else {
//         print('Failed to load seller profile: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching seller profile: $e');
//     }
//   }

//   late final List<Widget> _pages;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _pages = [
//       AddProductPage(sellerId: widget.sellerId, token: widget.token),
//       const OrdersPage(),
//       SellerChatListPage(token: widget.token, sellerId: widget.sellerId),
//       const DeliveryPage(),
//     ];
//   }
// void _onItemTapped(int index) {
//   if (index == 4) {
//     print('Navigating to Set Profile Page');
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SetProfilePage(
//           sellerId: widget.sellerId,
//           token: widget.token,
//         ),
//       ),
//     ).then((_) {
//       print('Returned from Set Profile Page');
//       _fetchSellerProfile();
//     });
//   } else if (index == 5) {
//     print('Navigating to Change Password Page');
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SellerChangePasswordPage(
//           sellerId: widget.sellerId,
//           token: widget.token,
//         ),
//       ),
//     );
//   } else if (index == 6) {
//     print('Logging out');
//     Navigator.pushReplacementNamed(context, '/login');
//   }

// //   }else if (index == 6) {
// //   debugPrint('Seller logging out');
// //   await AuthService.logout(context);
// // }
//    else {
//     setState(() {
//       _selectedIndex = index;
//     });
//     Navigator.pop(context);
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Seller Panel',
//           style: GoogleFonts.poppins(),
//         ),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserAccountsDrawerHeader(
//               accountName: Text(
//                 _sellerName,
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               accountEmail: Text(
//                 'Welcome, $_sellerName',
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   color: Colors.white70,
//                 ),
//               ),
//               currentAccountPicture: _profilePicture != null
//                   ? CircleAvatar(
//                       backgroundImage: NetworkImage('$baseUrl$_profilePicture'),
//                       onBackgroundImageError: (exception, stackTrace) {
//                         print('Error loading profile picture: $exception');
//                       },
//                     )
//                   : CircleAvatar(
//                       backgroundColor: Colors.purple,
//                       child: Text(
//                         'P',
//                         style: GoogleFonts.poppins(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//               decoration: const BoxDecoration(
//                 color: Colors.purple,
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.inventory),
//               title: Text(
//                 'Products',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 0,
//               onTap: () {
//                 _onItemTapped(0);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.shopping_cart),
//               title: Text(
//                 'Orders',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 1,
//               onTap: () {
//                 _onItemTapped(1);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.chat),
//               title: Text(
//                 'Chat',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 2,
//               onTap: () {
//                 _onItemTapped(2);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.local_shipping),
//               title: Text(
//                 'Delivery',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 3,
//               onTap: () {
//                 _onItemTapped(3);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: Text(
//                 'Set Profile',
//                 style: GoogleFonts.poppins(),
//               ),
//               onTap: () {
//                 _onItemTapped(4);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: Text(
//                 'change password',
//                 style: GoogleFonts.poppins(),
//               ),
//               onTap: () {
//                 _onItemTapped(5);
//               },
//             ),
//              ListTile(
//               leading: const Icon(Icons.logout),
//               title: Text(
//                 'Logout',
//                 style: GoogleFonts.poppins(),
//               ),
//               onTap: () {
//                 _onItemTapped(6);
//               },
//             ),
            
//           ],
//         ),
//       ),
//       body: _pages[_selectedIndex],
//     );
//   }
// }

// class SetProfilePage extends StatefulWidget {
//   final String sellerId;
//   final String? token;

//   const SetProfilePage({super.key, required this.sellerId, this.token});

//   @override
//   _SetProfilePageState createState() => _SetProfilePageState();
// }

// class _SetProfilePageState extends State<SetProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   PlatformFile? _selectedProfilePicture;
//   // final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchSellerProfile();
//   }

//   Future<void> _fetchSellerProfile() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _firstNameController.text = data['firstName'] ?? '';
//           _lastNameController.text = data['lastName'] ?? '';
//           _emailController.text = data['email'] ?? '';
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load profile: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching profile: $e')),
//       );
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
//         );
//         if (widget.token != null) {
//           request.headers['Authorization'] = 'Bearer ${widget.token}';
//         }
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
//           Navigator.pop(context);
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
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Set Profile',
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
//                   'Set Profile',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(
//                         type: FileType.image,
//                         allowMultiple: false,
//                       );
//                       if (result != null && result.files.isNotEmpty) {
//                         setState(() {
//                           _selectedProfilePicture = result.files.first;
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No file selected')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error selecting image: $e')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     _selectedProfilePicture == null
//                         ? 'Select Profile Picture'
//                         : 'Image Selected: ${_selectedProfilePicture!.name}',
//                     style: GoogleFonts.poppins(),
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
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter email' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _passwordController,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     suffixIcon: TextButton(
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Change Password feature coming soon')),
//                         );
//                       },
//                       child: const Text('Change Password'),
//                     ),
//                   ),
//                   obscureText: true,
//                   enabled: false,
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _updateProfile,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: Text(
//                       'Update Profile',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
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

// class AddProductPage extends StatefulWidget {
//   final String sellerId;
//   final String? token;

//   const AddProductPage({super.key, required this.sellerId, this.token});

//   @override
//   _AddProductPageState createState() => _AddProductPageState();
// }

// class _AddProductPageState extends State<AddProductPage> {
//   List<dynamic> _products = [];
//   List<dynamic> _filteredProducts = [];
//   bool _isLoading = true;
//   String _searchQuery = '';
//   // final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchProducts();
//   }

//   Future<void> _fetchProducts() async {
//     setState(() => _isLoading = true);
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/seller/products/${widget.sellerId}'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _products = data;
//           _filteredProducts = data;
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load products: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching products: $e')),
//       );
//     }
//   }

//   Future<void> _deleteProduct(String productId) async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.delete(
//         Uri.parse('$baseUrl/seller/products/$productId'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           _products.removeWhere((p) => p['_id'] == productId);
//           _filteredProducts.removeWhere((p) => p['_id'] == productId);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Product deleted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete product: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting product: $e')),
//       );
//     }
//   }

//   void _filterProducts(String query) {
//     setState(() {
//       _searchQuery = query;
//       _filteredProducts = _products.where((product) {
//         final title = product['title']?.toString().toLowerCase() ?? '';
//         final searchLower = query.toLowerCase();
//         return title.contains(searchLower);
//       }).toList();
//     });
//   }

//   void _showDeleteConfirmationDialog(BuildContext context, String productId, String productTitle) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: Text(
//             'Delete Product',
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.red,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete the product "$productTitle"?',
//             style: GoogleFonts.poppins(fontSize: 16),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Cancel',
//                 style: GoogleFonts.poppins(color: Colors.red),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 _deleteProduct(productId);
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Delete',
//                 style: GoogleFonts.poppins(color: Colors.red),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Row(
//           children: [
//             Text(
//               'Products (${_filteredProducts.length})',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const Spacer(),
//             IconButton(
//               icon: const Icon(Icons.add, color: Colors.white),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => AddProductFormPage(
//                       sellerId: widget.sellerId,
//                       token: widget.token,
//                     ),
//                   ),
//                 ).then((_) => _fetchProducts());
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               onChanged: _filterProducts,
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.search, color: Colors.purple),
//                 hintText: 'Search by product name',
//                 hintStyle: const TextStyle(color: Colors.grey),
//                 filled: true,
//                 fillColor: const Color(0xFFE0E0E0),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: Colors.purple, width: 2),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//                     itemCount: _filteredProducts.length,
//                     itemBuilder: (context, index) {
//                       final product = _filteredProducts[index];
//                       final imageUrl = product['image'] != null
//                           ? '$baseUrl${product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
//                           : null;
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12.0),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.3),
//                                 spreadRadius: 2,
//                                 blurRadius: 5,
//                                 offset: const Offset(0, 3),
//                               ),
//                             ],
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                           ),
//                           child: ListTile(
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                             leading: imageUrl != null
//                                 ? CircleAvatar(
//                                     radius: 30,
//                                     backgroundImage: NetworkImage(imageUrl),
//                                     backgroundColor: Colors.grey[300],
//                                     onBackgroundImageError: (exception, stackTrace) {
//                                       print('Error loading product image: $exception');
//                                     },
//                                   )
//                                 : CircleAvatar(
//                                     radius: 30,
//                                     backgroundColor: Colors.grey[300],
//                                     child: const Text('No Image'),
//                                   ),
//                             title: Text(
//                               product['title'] ?? 'Unknown Product',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             trailing: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.edit, color: Colors.purple),
//                                   onPressed: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => EditProductFormPage(
//                                           product: product,
//                                           sellerId: widget.sellerId,
//                                           token: widget.token,
//                                         ),
//                                       ),
//                                     ).then((_) => _fetchProducts());
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.purple),
//                                   onPressed: () {
//                                     _showDeleteConfirmationDialog(
//                                       context,
//                                       product['_id'].toString(),
//                                       product['title'] ?? 'Unknown Product',
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AddProductFormPage extends StatefulWidget {
//   final String sellerId;
//   final String? token;

//   const AddProductFormPage({super.key, required this.sellerId, this.token});

//   @override
//   _AddProductFormPageState createState() => _AddProductFormPageState();
// }

// class _AddProductFormPageState extends State<AddProductFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _quantityController = TextEditingController();
//   String? _selectedCategoryId;
//   PlatformFile? _selectedImageFile;
//   List<dynamic> _categories = [];
//   // final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchCategories();
//   }

//   Future<void> _fetchCategories() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/categories'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print('Fetched categories for dropdown: $data');
//         setState(() {
//           _categories = data;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load categories: ${response.statusCode} - ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching categories: $e')),
//       );
//     }
//   }

//   Future<void> _addProduct(String title, String price, String description, String categoryId, PlatformFile? imageFile, String quantity) async {
//     if (imageFile == null || categoryId.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an image and a category')),
//       );
//       return;
//     }

//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/seller/products'),
//       );
//       if (widget.token != null) {
//         request.headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       request.fields['title'] = title;
//       request.fields['price'] = price;
//       request.fields['description'] = description;
//       request.fields['categoryId'] = categoryId;
//       request.fields['sellerId'] = widget.sellerId;
//       request.fields['quantity'] = quantity;
//       request.fields['productStatus'] = 'available'; // Default productStatus

//       final bytes = <int>[];
//       if (imageFile.readStream != null) {
//         await for (var chunk in imageFile.readStream!) {
//           bytes.addAll(chunk);
//         }
//       } else if (imageFile.bytes != null) {
//         bytes.addAll(imageFile.bytes!);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('File data is unavailable')),
//         );
//         return;
//       }

//       print('Uploading file with ${bytes.length} bytes');
//       request.files.add(
//         http.MultipartFile.fromBytes(
//           'image',
//           bytes,
//           filename: imageFile.name,
//           contentType: MediaType('image', imageFile.extension ?? 'jpeg'),
//         ),
//       );

//       final response = await request.send();
//       final responseBody = await http.Response.fromStream(response);

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Product added successfully')),
//         );
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to add product: ${responseBody.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error in _addProduct: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error adding product: $e')),
//       );
//     }
//   }

//   void _clearForm() {
//     _titleController.clear();
//     _priceController.clear();
//     _descriptionController.clear();
//     _quantityController.clear();
//     _selectedCategoryId = null;
//     _selectedImageFile = null;
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     _quantityController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Add Product',
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
//                   'Add Product',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product title' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _priceController,
//                   decoration: InputDecoration(
//                     labelText: 'Price',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product price' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   maxLines: 3,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product description' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _quantityController,
//                   decoration: InputDecoration(
//                     labelText: 'Quantity',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product quantity' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: 'Category',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   value: _selectedCategoryId,
//                   hint: const Text('Select Category'),
//                   items: _categories.map((category) {
//                     return DropdownMenuItem<String>(
//                       value: category['_id'].toString(),
//                       child: Text(category['name']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCategoryId = value;
//                     });
//                   },
//                   validator: (value) =>
//                       value == null ? 'Please select a category' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(
//                         type: FileType.image,
//                         allowMultiple: false,
//                       );
//                       if (result != null && result.files.isNotEmpty) {
//                         setState(() {
//                           _selectedImageFile = result.files.first;
//                           print('Selected file: ${_selectedImageFile?.name}');
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No file selected')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error selecting image: $e')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     _selectedImageFile == null
//                         ? 'Select Product Image'
//                         : 'Image Selected: ${_selectedImageFile!.name}',
//                     style: GoogleFonts.poppins(),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         _addProduct(
//                           _titleController.text,
//                           _priceController.text,
//                           _descriptionController.text,
//                           _selectedCategoryId!,
//                           _selectedImageFile,
//                           _quantityController.text,
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: Text(
//                       'Add Product',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
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

// class EditProductFormPage extends StatefulWidget {
//   final Map<String, dynamic> product;
//   final String sellerId;
//   final String? token;

//   const EditProductFormPage({super.key, required this.product, required this.sellerId, this.token});

//   @override
//   _EditProductFormPageState createState() => _EditProductFormPageState();
// }

// class _EditProductFormPageState extends State<EditProductFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _quantityController = TextEditingController();
//   String? _selectedCategoryId;
//   String? _selectedProductStatus;
//   PlatformFile? _selectedImageFile;
//   String? _currentImageUrl;
//   List<dynamic> _categories = [];
//   // final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _titleController.text = widget.product['title'] ?? '';
//     _priceController.text = widget.product['price']?.toString() ?? '';
//     _descriptionController.text = widget.product['description'] ?? '';
//     _quantityController.text = widget.product['quantity']?.toString() ?? '';
//     _selectedCategoryId = widget.product['categoryId']?.toString();
//     _selectedProductStatus = widget.product['productStatus'] ?? 'available';
//     _currentImageUrl = widget.product['image'];
//     _fetchCategories();
//   }

//   Future<void> _fetchCategories() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/categories'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _categories = data;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load categories: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching categories: $e')),
//       );
//     }
//   }

//   Future<void> _updateProduct() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/seller/products/${widget.product['_id']}'),
//         );
//         if (widget.token != null) {
//           request.headers['Authorization'] = 'Bearer ${widget.token}';
//         }
//         request.fields['title'] = _titleController.text;
//         request.fields['price'] = _priceController.text;
//         request.fields['description'] = _descriptionController.text;
//         request.fields['quantity'] = _quantityController.text;
//         request.fields['categoryId'] = _selectedCategoryId!;
//         request.fields['sellerId'] = widget.sellerId;
//         request.fields['productStatus'] = _selectedProductStatus!;

//         if (_selectedImageFile != null) {
//           final bytes = <int>[];
//           if (_selectedImageFile!.readStream != null) {
//             await for (var chunk in _selectedImageFile!.readStream!) {
//               bytes.addAll(chunk);
//             }
//           } else if (_selectedImageFile!.bytes != null) {
//             bytes.addAll(_selectedImageFile!.bytes!);
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('File data is unavailable')),
//             );
//             return;
//           }

//           request.files.add(
//             http.MultipartFile.fromBytes(
//               'image',
//               bytes,
//               filename: _selectedImageFile!.name,
//               contentType: MediaType('image', _selectedImageFile!.extension ?? 'jpeg'),
//             ),
//           );
//         } else {
//           request.fields['image'] = _currentImageUrl ?? '';
//         }

//         print('Updating product with fields: ${request.fields}');
//         print('Files: ${request.files.map((file) => file.filename).toList()}');

//         final response = await request.send();
//         final responseBody = await http.Response.fromStream(response);

//         print('Response status: ${response.statusCode}');
//         print('Response body: ${responseBody.body}');

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Product updated successfully')),
//           );
//           Navigator.pop(context);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to update product: ${responseBody.body}')),
//           );
//         }
//       } catch (error) {
//         print('Error updating product: $error');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating product: $error')),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     _quantityController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Edit Product',
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
//                   'Edit Product',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product title' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _priceController,
//                   decoration: InputDecoration(
//                     labelText: 'Price',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product price' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   maxLines: 3,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product description' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _quantityController,
//                   decoration: InputDecoration(
//                     labelText: 'Quantity',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product quantity' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: 'Category',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   value: _selectedCategoryId,
//                   hint: const Text('Select Category'),
//                   items: _categories.map((category) {
//                     return DropdownMenuItem<String>(
//                       value: category['_id'].toString(),
//                       child: Text(category['name']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCategoryId = value;
//                     });
//                   },
//                   validator: (value) =>
//                       value == null ? 'Please select a category' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: 'Product Status',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   value: _selectedProductStatus,
//                   hint: const Text('Select Product Status'),
//                   items: const [
//                     DropdownMenuItem<String>(
//                       value: 'available',
//                       child: Text('Available'),
//                     ),
//                     DropdownMenuItem<String>(
//                       value: 'sold',
//                       child: Text('Sold'),
//                     ),
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedProductStatus = value;
//                     });
//                   },
//                   validator: (value) =>
//                       value == null ? 'Please select a product status' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 _currentImageUrl != null
//                     ? Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Current Image:',
//                             style: GoogleFonts.poppins(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Image.network(
//                             '$baseUrl$_currentImageUrl',
//                             height: 100,
//                             width: 100,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return const Text('Error loading image');
//                             },
//                           ),
//                         ],
//                       )
//                     : const SizedBox.shrink(),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(
//                         type: FileType.image,
//                         allowMultiple: false,
//                       );
//                       if (result != null && result.files.isNotEmpty) {
//                         setState(() {
//                           _selectedImageFile = result.files.first;
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No file selected')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error selecting image: $e')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     _selectedImageFile == null
//                         ? 'Select New Product Image'
//                         : 'Image Selected: ${_selectedImageFile!.name}',
//                     style: GoogleFonts.poppins(),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _updateProduct,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: Text(
//                       'Update Product',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
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

// class OrdersPage extends StatelessWidget {
//   const OrdersPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Orders Page - Under Development',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

// class DeliveryPage extends StatelessWidget {
//   const DeliveryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Delivery Page - Under Development',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

// class SellerChatListPage extends StatefulWidget {
//   final String token;
//   final String sellerId;

//   const SellerChatListPage({
//     super.key,
//     required this.token,
//     required this.sellerId,
//   });

//   @override
//   _SellerChatListPageState createState() => _SellerChatListPageState();
// }

// class _SellerChatListPageState extends State<SellerChatListPage> {
//   List<dynamic> _chats = [];
//   bool _isLoading = true;
//   // final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchChats();
//   }

//   Future<void> _fetchChats() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/chat/seller'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _chats = data;
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load chats: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching chats: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Chats',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _chats.isEmpty
//               ? const Center(
//                   child: Text(
//                     'No chats available',
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                   ),
//                 )
//               : ListView.builder(
//                   padding: const EdgeInsets.all(16.0),
//                   itemCount: _chats.length,
//                   itemBuilder: (context, index) {
//                     final chat = _chats[index];
//                     return Card(
//                       margin: const EdgeInsets.symmetric(vertical: 8.0),
//                       child: ListTile(
//                         title: Text(
//                           'Product: ${chat['productName']}',
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Client: ${chat['clientName']}',
//                               style: GoogleFonts.poppins(fontSize: 14),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               chat['latestMessage'],
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14,
//                                 color: Colors.grey,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                         trailing: Text(
//                           _formatDateTime(chat['latestMessageTime']),
//                           style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
//                         ),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => SellerChatPage(
//                                 chatId: chat['_id'].toString(),
//                                 productName: chat['productName'],
//                                 sellerId: widget.sellerId,
//                                 token: widget.token,
//                               ),
//                             ),

// //                             MaterialPageRoute(
// //   builder: (context) => ChatPage(
// //     chatId: chat['_id']?.toString() ?? '', // Null-safe chatId
// //     productName: chat['productName']?.toString() ?? 'Unknown Product', // Null-safe productName
// //     token: widget.token ?? '', // Null-safe token
// //   ),
// // )

// // MaterialPageRoute(
// //   builder: (context) => SellerChatPage(
// //     chatId: chat['_id']?.toString() ?? '',
// //     productName: chat['productName']?.toString() ?? 'Unknown Product',
// //     sellerId: widget.sellerId ?? '',
// //     token: widget.token ?? '',
// //   ),
// // )
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }

//   String _formatDateTime(String dateTime) {
//     final date = DateTime.parse(dateTime);
//     final now = DateTime.now();
//     final difference = now.difference(date);
//     if (difference.inDays > 0) {
//       return '${difference.inDays}d ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes}m ago';
//     } else {
//       return 'Just now';
//     }
//   }
// }


// version for ui and delete chat

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'sellerchat.dart';
// import 'sellerchangepassword.dart';
// import 'baseurl.dart';

// class SellerHomePage extends StatefulWidget {
//   final String sellerId;
//   final String token;

//   const SellerHomePage({super.key, required this.sellerId, required this.token});

//   @override
//   _SellerHomePageState createState() => _SellerHomePageState();
// }

// class _SellerHomePageState extends State<SellerHomePage> {
//   int _selectedIndex = 0;
//   String _sellerName = "John Doe";
//   String? _profilePicture;
//   final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

//   @override
//   void initState() {
//     super.initState();
//     _fetchSellerProfile();
//   }

//   Future<void> _fetchSellerProfile() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _sellerName = '${data['firstName']} ${data['lastName']}';
//           _profilePicture = data['profilePicture'];
//         });
//       } else {
//         print('Failed to load seller profile: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching seller profile: $e');
//     }
//   }

//   late final List<Widget> _pages;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _pages = [
//       AddProductPage(sellerId: widget.sellerId, token: widget.token),
//       const OrdersPage(),
//       SellerChatListPage(token: widget.token, sellerId: widget.sellerId),
//       const DeliveryPage(),
//     ];
//   }

//   void _onItemTapped(int index) {
//     if (index == 4) {
//       print('Navigating to Set Profile Page');
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SetProfilePage(
//             sellerId: widget.sellerId,
//             token: widget.token,
//           ),
//         ),
//       ).then((_) {
//         print('Returned from Set Profile Page');
//         _fetchSellerProfile();
//       });
//     } else if (index == 5) {
//       print('Navigating to Change Password Page');
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SellerChangePasswordPage(
//             sellerId: widget.sellerId,
//             token: widget.token,
//           ),
//         ),
//       );
//     } else if (index == 6) {
//       print('Logging out');
//       Navigator.pushReplacementNamed(context, '/login');
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         title: Text(
//           'Seller Panel',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserAccountsDrawerHeader(
//               accountName: Text(
//                 _sellerName,
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               accountEmail: Text(
//                 'Welcome, $_sellerName',
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   color: Colors.white70,
//                 ),
//               ),
//               currentAccountPicture: _profilePicture != null
//                   ? CircleAvatar(
//                       backgroundImage: NetworkImage('$baseUrl$_profilePicture'),
//                       onBackgroundImageError: (exception, stackTrace) {
//                         print('Error loading profile picture: $exception');
//                       },
//                     )
//                   : CircleAvatar(
//                       backgroundColor: primaryColor,
//                       child: Text(
//                         _sellerName.isNotEmpty ? _sellerName[0].toUpperCase() : 'P',
//                         style: GoogleFonts.poppins(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//               decoration: BoxDecoration(
//                 color: primaryColor,
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.inventory, color: primaryColor),
//               title: Text(
//                 'Products',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               selected: _selectedIndex == 0,
//               onTap: () {
//                 _onItemTapped(0);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.receipt, color: primaryColor),
//               title: Text(
//                 'Orders',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               selected: _selectedIndex == 1,
//               onTap: () {
//                 _onItemTapped(1);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.chat, color: primaryColor),
//               title: Text(
//                 'Chat',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               selected: _selectedIndex == 2,
//               onTap: () {
//                 _onItemTapped(2);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.local_shipping, color: primaryColor),
//               title: Text(
//                 'Delivery',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               selected: _selectedIndex == 3,
//               onTap: () {
//                 _onItemTapped(3);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.person, color: primaryColor),
//               title: Text(
//                 'Set Profile',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               onTap: () {
//                 _onItemTapped(4);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.lock, color: primaryColor),
//               title: Text(
//                 'Change Password',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               onTap: () {
//                 _onItemTapped(5);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.logout, color: primaryColor),
//               title: Text(
//                 'Logout',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               onTap: () {
//                 _onItemTapped(6);
//               },
//             ),
//           ],
//         ),
//       ),
//       body: _pages[_selectedIndex],
//     );
//   }
// }

// class SetProfilePage extends StatefulWidget {
//   final String sellerId;
//   final String? token;

//   const SetProfilePage({super.key, required this.sellerId, this.token});

//   @override
//   _SetProfilePageState createState() => _SetProfilePageState();
// }

// class _SetProfilePageState extends State<SetProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   PlatformFile? _selectedProfilePicture;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSellerProfile();
//   }

//   Future<void> _fetchSellerProfile() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _firstNameController.text = data['firstName'] ?? '';
//           _lastNameController.text = data['lastName'] ?? '';
//           _emailController.text = data['email'] ?? '';
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load profile: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching profile: $e')),
//       );
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
//         );
//         if (widget.token != null) {
//           request.headers['Authorization'] = 'Bearer ${widget.token}';
//         }
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
//           Navigator.pop(context);
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
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Set Profile',
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
//                   'Set Profile',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(
//                         type: FileType.image,
//                         allowMultiple: false,
//                       );
//                       if (result != null && result.files.isNotEmpty) {
//                         setState(() {
//                           _selectedProfilePicture = result.files.first;
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No file selected')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error selecting image: $e')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     _selectedProfilePicture == null
//                         ? 'Select Profile Picture'
//                         : 'Image Selected: ${_selectedProfilePicture!.name}',
//                     style: GoogleFonts.poppins(),
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
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter email' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _passwordController,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     suffixIcon: TextButton(
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Change Password feature coming soon')),
//                         );
//                       },
//                       child: const Text('Change Password'),
//                     ),
//                   ),
//                   obscureText: true,
//                   enabled: false,
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _updateProfile,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: Text(
//                       'Update Profile',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
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

// class AddProductPage extends StatefulWidget {
//   final String sellerId;
//   final String? token;

//   const AddProductPage({super.key, required this.sellerId, this.token});

//   @override
//   _AddProductPageState createState() => _AddProductPageState();
// }

// class _AddProductPageState extends State<AddProductPage> {
//   List<dynamic> _products = [];
//   List<dynamic> _filteredProducts = [];
//   bool _isLoading = true;
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchProducts();
//   }

//   Future<void> _fetchProducts() async {
//     setState(() => _isLoading = true);
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/seller/products/${widget.sellerId}'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _products = data;
//           _filteredProducts = data;
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load products: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching products: $e')),
//       );
//     }
//   }

//   Future<void> _deleteProduct(String productId) async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.delete(
//         Uri.parse('$baseUrl/seller/products/$productId'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           _products.removeWhere((p) => p['_id'] == productId);
//           _filteredProducts.removeWhere((p) => p['_id'] == productId);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Product deleted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete product: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting product: $e')),
//       );
//     }
//   }

//   void _filterProducts(String query) {
//     setState(() {
//       _searchQuery = query;
//       _filteredProducts = _products.where((product) {
//         final title = product['title']?.toString().toLowerCase() ?? '';
//         final searchLower = query.toLowerCase();
//         return title.contains(searchLower);
//       }).toList();
//     });
//   }

//   void _showDeleteConfirmationDialog(BuildContext context, String productId, String productTitle) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: Text(
//             'Delete Product',
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.red,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete the product "$productTitle"?',
//             style: GoogleFonts.poppins(fontSize: 16),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Cancel',
//                 style: GoogleFonts.poppins(color: Colors.red),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 _deleteProduct(productId);
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Delete',
//                 style: GoogleFonts.poppins(color: Colors.red),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Row(
//           children: [
//             Text(
//               'Products (${_filteredProducts.length})',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const Spacer(),
//             IconButton(
//               icon: const Icon(Icons.add, color: Colors.white),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => AddProductFormPage(
//                       sellerId: widget.sellerId,
//                       token: widget.token,
//                     ),
//                   ),
//                 ).then((_) => _fetchProducts());
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               onChanged: _filterProducts,
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.search, color: Colors.purple),
//                 hintText: 'Search by product name',
//                 hintStyle: const TextStyle(color: Colors.grey),
//                 filled: true,
//                 fillColor: const Color(0xFFE0E0E0),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: Colors.purple, width: 2),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//                     itemCount: _filteredProducts.length,
//                     itemBuilder: (context, index) {
//                       final product = _filteredProducts[index];
//                       final imageUrl = product['image'] != null
//                           ? '$baseUrl${product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
//                           : null;
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12.0),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.3),
//                                 spreadRadius: 2,
//                                 blurRadius: 5,
//                                 offset: const Offset(0, 3),
//                               ),
//                             ],
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                           ),
//                           child: ListTile(
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                             leading: imageUrl != null
//                                 ? CircleAvatar(
//                                     radius: 30,
//                                     backgroundImage: NetworkImage(imageUrl),
//                                     backgroundColor: Colors.grey[300],
//                                     onBackgroundImageError: (exception, stackTrace) {
//                                       print('Error loading product image: $exception');
//                                     },
//                                   )
//                                 : CircleAvatar(
//                                     radius: 30,
//                                     backgroundColor: Colors.grey[300],
//                                     child: const Text('No Image'),
//                                   ),
//                             title: Text(
//                               product['title'] ?? 'Unknown Product',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             trailing: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.edit, color: Colors.purple),
//                                   onPressed: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => EditProductFormPage(
//                                           product: product,
//                                           sellerId: widget.sellerId,
//                                           token: widget.token,
//                                         ),
//                                       ),
//                                     ).then((_) => _fetchProducts());
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.purple),
//                                   onPressed: () {
//                                     _showDeleteConfirmationDialog(
//                                       context,
//                                       product['_id'].toString(),
//                                       product['title'] ?? 'Unknown Product',
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AddProductFormPage extends StatefulWidget {
//   final String sellerId;
//   final String? token;

//   const AddProductFormPage({super.key, required this.sellerId, this.token});

//   @override
//   _AddProductFormPageState createState() => _AddProductFormPageState();
// }

// class _AddProductFormPageState extends State<AddProductFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _quantityController = TextEditingController();
//   String? _selectedCategoryId;
//   PlatformFile? _selectedImageFile;
//   List<dynamic> _categories = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchCategories();
//   }

//   Future<void> _fetchCategories() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/categories'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print('Fetched categories for dropdown: $data');
//         setState(() {
//           _categories = data;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load categories: ${response.statusCode} - ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching categories: $e')),
//       );
//     }
//   }

//   Future<void> _addProduct(String title, String price, String description, String categoryId, PlatformFile? imageFile, String quantity) async {
//     if (imageFile == null || categoryId.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an image and a category')),
//       );
//       return;
//     }

//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/seller/products'),
//       );
//       if (widget.token != null) {
//         request.headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       request.fields['title'] = title;
//       request.fields['price'] = price;
//       request.fields['description'] = description;
//       request.fields['categoryId'] = categoryId;
//       request.fields['sellerId'] = widget.sellerId;
//       request.fields['quantity'] = quantity;
//       request.fields['productStatus'] = 'available';

//       final bytes = <int>[];
//       if (imageFile.readStream != null) {
//         await for (var chunk in imageFile.readStream!) {
//           bytes.addAll(chunk);
//         }
//       } else if (imageFile.bytes != null) {
//         bytes.addAll(imageFile.bytes!);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('File data is unavailable')),
//         );
//         return;
//       }

//       print('Uploading file with ${bytes.length} bytes');
//       request.files.add(
//         http.MultipartFile.fromBytes(
//           'image',
//           bytes,
//           filename: imageFile.name,
//           contentType: MediaType('image', imageFile.extension ?? 'jpeg'),
//         ),
//       );

//       final response = await request.send();
//       final responseBody = await http.Response.fromStream(response);

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Product added successfully')),
//         );
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to add product: ${responseBody.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error in _addProduct: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error adding product: $e')),
//       );
//     }
//   }

//   void _clearForm() {
//     _titleController.clear();
//     _priceController.clear();
//     _descriptionController.clear();
//     _quantityController.clear();
//     _selectedCategoryId = null;
//     _selectedImageFile = null;
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     _quantityController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Add Product',
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
//                   'Add Product',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product title' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _priceController,
//                   decoration: InputDecoration(
//                     labelText: 'Price',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product price' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   maxLines: 3,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product description' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _quantityController,
//                   decoration: InputDecoration(
//                     labelText: 'Quantity',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product quantity' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: 'Category',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   value: _selectedCategoryId,
//                   hint: const Text('Select Category'),
//                   items: _categories.map((category) {
//                     return DropdownMenuItem<String>(
//                       value: category['_id'].toString(),
//                       child: Text(category['name']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCategoryId = value;
//                     });
//                   },
//                   validator: (value) =>
//                       value == null ? 'Please select a category' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(
//                         type: FileType.image,
//                         allowMultiple: false,
//                       );
//                       if (result != null && result.files.isNotEmpty) {
//                         setState(() {
//                           _selectedImageFile = result.files.first;
//                           print('Selected file: ${_selectedImageFile?.name}');
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No file selected')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error selecting image: $e')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     _selectedImageFile == null
//                         ? 'Select Product Image'
//                         : 'Image Selected: ${_selectedImageFile!.name}',
//                     style: GoogleFonts.poppins(),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         _addProduct(
//                           _titleController.text,
//                           _priceController.text,
//                           _descriptionController.text,
//                           _selectedCategoryId!,
//                           _selectedImageFile,
//                           _quantityController.text,
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: Text(
//                       'Add Product',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
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

// class EditProductFormPage extends StatefulWidget {
//   final Map<String, dynamic> product;
//   final String sellerId;
//   final String? token;

//   const EditProductFormPage({super.key, required this.product, required this.sellerId, this.token});

//   @override
//   _EditProductFormPageState createState() => _EditProductFormPageState();
// }

// class _EditProductFormPageState extends State<EditProductFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _quantityController = TextEditingController();
//   String? _selectedCategoryId;
//   String? _selectedProductStatus;
//   PlatformFile? _selectedImageFile;
//   String? _currentImageUrl;
//   List<dynamic> _categories = [];

//   @override
//   void initState() {
//     super.initState();
//     _titleController.text = widget.product['title'] ?? '';
//     _priceController.text = widget.product['price']?.toString() ?? '';
//     _descriptionController.text = widget.product['description'] ?? '';
//     _quantityController.text = widget.product['quantity']?.toString() ?? '';
//     _selectedCategoryId = widget.product['categoryId']?.toString();
//     _selectedProductStatus = widget.product['productStatus'] ?? 'available';
//     _currentImageUrl = widget.product['image'];
//     _fetchCategories();
//   }

//   Future<void> _fetchCategories() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/categories'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _categories = data;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load categories: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching categories: $e')),
//       );
//     }
//   }

//   Future<void> _updateProduct() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/seller/products/${widget.product['_id']}'),
//         );
//         if (widget.token != null) {
//           request.headers['Authorization'] = 'Bearer ${widget.token}';
//         }
//         request.fields['title'] = _titleController.text;
//         request.fields['price'] = _priceController.text;
//         request.fields['description'] = _descriptionController.text;
//         request.fields['quantity'] = _quantityController.text;
//         request.fields['categoryId'] = _selectedCategoryId!;
//         request.fields['sellerId'] = widget.sellerId;
//         request.fields['productStatus'] = _selectedProductStatus!;

//         if (_selectedImageFile != null) {
//           final bytes = <int>[];
//           if (_selectedImageFile!.readStream != null) {
//             await for (var chunk in _selectedImageFile!.readStream!) {
//               bytes.addAll(chunk);
//             }
//           } else if (_selectedImageFile!.bytes != null) {
//             bytes.addAll(_selectedImageFile!.bytes!);
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('File data is unavailable')),
//             );
//             return;
//           }

//           request.files.add(
//             http.MultipartFile.fromBytes(
//               'image',
//               bytes,
//               filename: _selectedImageFile!.name,
//               contentType: MediaType('image', _selectedImageFile!.extension ?? 'jpeg'),
//             ),
//           );
//         } else {
//           request.fields['image'] = _currentImageUrl ?? '';
//         }

//         print('Updating product with fields: ${request.fields}');
//         print('Files: ${request.files.map((file) => file.filename).toList()}');

//         final response = await request.send();
//         final responseBody = await http.Response.fromStream(response);

//         print('Response status: ${response.statusCode}');
//         print('Response body: ${responseBody.body}');

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Product updated successfully')),
//           );
//           Navigator.pop(context);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to update product: ${responseBody.body}')),
//           );
//         }
//       } catch (error) {
//         print('Error updating product: $error');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating product: $error')),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     _quantityController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Edit Product',
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
//                   'Edit Product',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product title' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _priceController,
//                   decoration: InputDecoration(
//                     labelText: 'Price',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product price' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   maxLines: 3,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product description' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _quantityController,
//                   decoration: InputDecoration(
//                     labelText: 'Quantity',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product quantity' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: 'Category',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   value: _selectedCategoryId,
//                   hint: const Text('Select Category'),
//                   items: _categories.map((category) {
//                     return DropdownMenuItem<String>(
//                       value: category['_id'].toString(),
//                       child: Text(category['name']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCategoryId = value;
//                     });
//                   },
//                   validator: (value) =>
//                       value == null ? 'Please select a category' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: 'Product Status',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   value: _selectedProductStatus,
//                   hint: const Text('Select Product Status'),
//                   items: const [
//                     DropdownMenuItem<String>(
//                       value: 'available',
//                       child: Text('Available'),
//                     ),
//                     DropdownMenuItem<String>(
//                       value: 'sold',
//                       child: Text('Sold'),
//                     ),
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedProductStatus = value;
//                     });
//                   },
//                   validator: (value) =>
//                       value == null ? 'Please select a product status' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 _currentImageUrl != null
//                     ? Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Current Image:',
//                             style: GoogleFonts.poppins(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Image.network(
//                             '$baseUrl$_currentImageUrl',
//                             height: 100,
//                             width: 100,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return const Text('Error loading image');
//                             },
//                           ),
//                         ],
//                       )
//                     : const SizedBox.shrink(),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(
//                         type: FileType.image,
//                         allowMultiple: false,
//                       );
//                       if (result != null && result.files.isNotEmpty) {
//                         setState(() {
//                           _selectedImageFile = result.files.first;
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No file selected')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error selecting image: $e')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     _selectedImageFile == null
//                         ? 'Select New Product Image'
//                         : 'Image Selected: ${_selectedImageFile!.name}',
//                     style: GoogleFonts.poppins(),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _updateProduct,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: Text(
//                       'Update Product',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
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

// class OrdersPage extends StatelessWidget {
//   const OrdersPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Orders Page - Under Development',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

// class DeliveryPage extends StatelessWidget {
//   const DeliveryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Delivery Page - Under Development',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

// class SellerChatListPage extends StatefulWidget {
//   final String token;
//   final String sellerId;

//   const SellerChatListPage({
//     super.key,
//     required this.token,
//     required this.sellerId,
//   });

//   @override
//   _SellerChatListPageState createState() => _SellerChatListPageState();
// }

// class _SellerChatListPageState extends State<SellerChatListPage> {
//   List<dynamic> _chats = [];
//   List<dynamic> _filteredChats = [];
//   bool _isLoading = true;
//   String _searchQuery = '';
//   final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

//   @override
//   void initState() {
//     super.initState();
//     _fetchChats();
//   }

//   Future<void> _fetchChats() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/chat/seller'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _chats = data;
//           _filteredChats = data;
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load chats: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching chats: $e')),
//       );
//     }
//   }

//   Future<void> _deleteChat(String chatId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/chat/seller/$chatId'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _chats.removeWhere((chat) => chat['_id'] == chatId);
//           _filteredChats.removeWhere((chat) => chat['_id'] == chatId);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Chat deleted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete chat: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting chat: $e')),
//       );
//     }
//   }

//   void _filterChats(String query) {
//     setState(() {
//       _searchQuery = query;
//       _filteredChats = _chats.where((chat) {
//         final clientName = chat['clientName']?.toString().toLowerCase() ?? '';
//         final productName = chat['productName']?.toString().toLowerCase() ?? '';
//         final searchLower = query.toLowerCase();
//         return clientName.contains(searchLower) || productName.contains(searchLower);
//       }).toList();
//     });
//   }

//   void _showDeleteConfirmationDialog(BuildContext context, String chatId, String clientName, String productName) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: Text(
//             'Delete Chat',
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: primaryColor,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete the chat with $clientName about "$productName"?',
//             style: GoogleFonts.poppins(fontSize: 16),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Cancel',
//                 style: GoogleFonts.poppins(color: primaryColor),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 _deleteChat(chatId);
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Delete',
//                 style: GoogleFonts.poppins(color: primaryColor),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         title: Text(
//           'Chats',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               onChanged: _filterChats,
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.search, color: primaryColor),
//                 hintText: 'Search by client or product name',
//                 hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                 filled: true,
//                 fillColor: Colors.grey[100],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: primaryColor, width: 1),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: primaryColor, width: 1),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: primaryColor, width: 1.5),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               ),
//               style: GoogleFonts.poppins(fontSize: 14),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
//                 : _filteredChats.isEmpty
//                     ? Center(
//                         child: Text(
//                           'No chats available',
//                           style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
//                         ),
//                       )
//                     : ListView.builder(
//                         padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
//                         itemCount: _filteredChats.length,
//                         itemBuilder: (context, index) {
//                           final chat = _filteredChats[index];
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 12.0),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(10),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.2),
//                                   spreadRadius: 1,
//                                   blurRadius: 4,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: ListTile(
//                               contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
//                               title: Text(
//                                 'Product: ${chat['productName']}',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                   color: primaryColor,
//                                 ),
//                               ),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Client: ${chat['clientName']}',
//                                     style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     chat['latestMessage'] ?? '[Empty Message]',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 12,
//                                       color: Colors.grey[600],
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ],
//                               ),
//                               trailing: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(
//                                     _formatDateTime(chat['latestMessageTime']),
//                                     style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   IconButton(
//                                     icon: Icon(Icons.delete, color: primaryColor),
//                                     onPressed: () {
//                                       _showDeleteConfirmationDialog(
//                                         context,
//                                         chat['_id'].toString(),
//                                         chat['clientName'] ?? 'Unknown Client',
//                                         chat['productName'] ?? 'Unknown Product',
//                                       );
//                                     },
//                                   ),
//                                 ],
//                               ),
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => SellerChatPage(
//                                       chatId: chat['_id'].toString(),
//                                       productName: chat['productName'],
//                                       sellerId: widget.sellerId,
//                                       token: widget.token,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDateTime(String dateTime) {
//     final date = DateTime.parse(dateTime);
//     final now = DateTime.now();
//     final difference = now.difference(date);
//     if (difference.inDays > 0) {
//       return '${difference.inDays}d ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes}m ago';
//     } else {
//       return 'Just now';
//     }
//   }
// }


// version to group chats 

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'sellerchat.dart';
// import 'sellerchangepassword.dart';
// import 'baseurl.dart';

// class SellerHomePage extends StatefulWidget {
//   final String sellerId;
//   final String token;

//   const SellerHomePage({super.key, required this.sellerId, required this.token});

//   @override
//   _SellerHomePageState createState() => _SellerHomePageState();
// }

// class _SellerHomePageState extends State<SellerHomePage> {
//   int _selectedIndex = 0;
//   String _sellerName = "John Doe";
//   String? _profilePicture;
//   final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

//   @override
//   void initState() {
//     super.initState();
//     _fetchSellerProfile();
//   }

//   Future<void> _fetchSellerProfile() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _sellerName = '${data['firstName']} ${data['lastName']}';
//           _profilePicture = data['profilePicture'];
//         });
//       } else {
//         print('Failed to load seller profile: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching seller profile: $e');
//     }
//   }

//   late final List<Widget> _pages;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _pages = [
//       AddProductPage(sellerId: widget.sellerId, token: widget.token),
//       const OrdersPage(),
//       SellerChatListPage(token: widget.token, sellerId: widget.sellerId),
//       const DeliveryPage(),
//     ];
//   }

//   void _onItemTapped(int index) {
//     if (index == 4) {
//       print('Navigating to Set Profile Page');
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SetProfilePage(
//             sellerId: widget.sellerId,
//             token: widget.token,
//           ),
//         ),
//       ).then((_) {
//         print('Returned from Set Profile Page');
//         _fetchSellerProfile();
//       });
//     } else if (index == 5) {
//       print('Navigating to Change Password Page');
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SellerChangePasswordPage(
//             sellerId: widget.sellerId,
//             token: widget.token,
//           ),
//         ),
//       );
//     } else if (index == 6) {
//       print('Logging out');
//       Navigator.pushReplacementNamed(context, '/login');
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         title: Text(
//           'Seller Panel',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       drawer: Drawer(
//         width: 240,
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserAccountsDrawerHeader(
//               accountName: Text(
//                 _sellerName,
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               accountEmail: Text(
//                 'Welcome, $_sellerName',
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   color: Colors.white70,
//                 ),
//               ),
//               currentAccountPicture: _profilePicture != null
//                   ? CircleAvatar(
//                       backgroundImage: NetworkImage('$baseUrl$_profilePicture'),
//                       onBackgroundImageError: (exception, stackTrace) {
//                         print('Error loading profile picture: $exception');
//                       },
//                     )
//                   : CircleAvatar(
//                       backgroundColor: primaryColor,
//                       child: Text(
//                         _sellerName.isNotEmpty ? _sellerName[0].toUpperCase() : 'P',
//                         style: GoogleFonts.poppins(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//               decoration: BoxDecoration(
//                 color: primaryColor,
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.inventory, color: primaryColor),
//               title: Text(
//                 'Products',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               selected: _selectedIndex == 0,
//               onTap: () {
//                 _onItemTapped(0);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.receipt, color: primaryColor),
//               title: Text(
//                 'Orders',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               selected: _selectedIndex == 1,
//               onTap: () {
//                 _onItemTapped(1);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.chat, color: primaryColor),
//               title: Text(
//                 'Chat',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               selected: _selectedIndex == 2,
//               onTap: () {
//                 _onItemTapped(2);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.local_shipping, color: primaryColor),
//               title: Text(
//                 'Delivery',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               selected: _selectedIndex == 3,
//               onTap: () {
//                 _onItemTapped(3);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.person, color: primaryColor),
//               title: Text(
//                 'Set Profile',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               onTap: () {
//                 _onItemTapped(4);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.lock, color: primaryColor),
//               title: Text(
//                 'Change Password',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               onTap: () {
//                 _onItemTapped(5);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.logout, color: primaryColor),
//               title: Text(
//                 'Logout',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               onTap: () {
//                 _onItemTapped(6);
//               },
//             ),
//           ],
//         ),
//       ),
//       body: _pages[_selectedIndex],
//     );
//   }
// }

// class SetProfilePage extends StatefulWidget {
//   final String sellerId;
//   final String? token;

//   const SetProfilePage({super.key, required this.sellerId, this.token});

//   @override
//   _SetProfilePageState createState() => _SetProfilePageState();
// }

// class _SetProfilePageState extends State<SetProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   PlatformFile? _selectedProfilePicture;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSellerProfile();
//   }

//   Future<void> _fetchSellerProfile() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _firstNameController.text = data['firstName'] ?? '';
//           _lastNameController.text = data['lastName'] ?? '';
//           _emailController.text = data['email'] ?? '';
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load profile: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching profile: $e')),
//       );
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
//         );
//         if (widget.token != null) {
//           request.headers['Authorization'] = 'Bearer ${widget.token}';
//         }
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
//           Navigator.pop(context);
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
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Set Profile',
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
//                   'Set Profile',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(
//                         type: FileType.image,
//                         allowMultiple: false,
//                       );
//                       if (result != null && result.files.isNotEmpty) {
//                         setState(() {
//                           _selectedProfilePicture = result.files.first;
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No file selected')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error selecting image: $e')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     _selectedProfilePicture == null
//                         ? 'Select Profile Picture'
//                         : 'Image Selected: ${_selectedProfilePicture!.name}',
//                     style: GoogleFonts.poppins(),
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
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter email' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _passwordController,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     suffixIcon: TextButton(
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Change Password feature coming soon')),
//                         );
//                       },
//                       child: const Text('Change Password'),
//                     ),
//                   ),
//                   obscureText: true,
//                   enabled: false,
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _updateProfile,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: Text(
//                       'Update Profile',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
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

// class AddProductPage extends StatefulWidget {
//   final String sellerId;
//   final String? token;

//   const AddProductPage({super.key, required this.sellerId, this.token});

//   @override
//   _AddProductPageState createState() => _AddProductPageState();
// }

// class _AddProductPageState extends State<AddProductPage> {
//   List<dynamic> _products = [];
//   List<dynamic> _filteredProducts = [];
//   bool _isLoading = true;
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchProducts();
//   }

//   Future<void> _fetchProducts() async {
//     setState(() => _isLoading = true);
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/seller/products/${widget.sellerId}'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _products = data;
//           _filteredProducts = data;
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load products: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching products: $e')),
//       );
//     }
//   }

//   Future<void> _deleteProduct(String productId) async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.delete(
//         Uri.parse('$baseUrl/seller/products/$productId'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           _products.removeWhere((p) => p['_id'] == productId);
//           _filteredProducts.removeWhere((p) => p['_id'] == productId);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Product deleted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete product: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting product: $e')),
//       );
//     }
//   }

//   void _filterProducts(String query) {
//     setState(() {
//       _searchQuery = query;
//       _filteredProducts = _products.where((product) {
//         final title = product['title']?.toString().toLowerCase() ?? '';
//         final searchLower = query.toLowerCase();
//         return title.contains(searchLower);
//       }).toList();
//     });
//   }

//   void _showDeleteConfirmationDialog(BuildContext context, String productId, String productTitle) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: Text(
//             'Delete Product',
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.red,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete the product "$productTitle"?',
//             style: GoogleFonts.poppins(fontSize: 16),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Cancel',
//                 style: GoogleFonts.poppins(color: Colors.red),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 _deleteProduct(productId);
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Delete',
//                 style: GoogleFonts.poppins(color: Colors.red),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Row(
//           children: [
//             Text(
//               'Products (${_filteredProducts.length})',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const Spacer(),
//             IconButton(
//               icon: const Icon(Icons.add, color: Colors.white),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => AddProductFormPage(
//                       sellerId: widget.sellerId,
//                       token: widget.token,
//                     ),
//                   ),
//                 ).then((_) => _fetchProducts());
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               onChanged: _filterProducts,
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.search, color: Colors.purple),
//                 hintText: 'Search by product name',
//                 hintStyle: const TextStyle(color: Colors.grey),
//                 filled: true,
//                 fillColor: const Color(0xFFE0E0E0),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: Colors.purple, width: 2),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//                     itemCount: _filteredProducts.length,
//                     itemBuilder: (context, index) {
//                       final product = _filteredProducts[index];
//                       final imageUrl = product['image'] != null
//                           ? '$baseUrl${product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
//                           : null;
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12.0),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.3),
//                                 spreadRadius: 2,
//                                 blurRadius: 5,
//                                 offset: const Offset(0, 3),
//                               ),
//                             ],
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                           ),
//                           child: ListTile(
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                             leading: imageUrl != null
//                                 ? CircleAvatar(
//                                     radius: 30,
//                                     backgroundImage: NetworkImage(imageUrl),
//                                     backgroundColor: Colors.grey[300],
//                                     onBackgroundImageError: (exception, stackTrace) {
//                                       print('Error loading product image: $exception');
//                                     },
//                                   )
//                                 : CircleAvatar(
//                                     radius: 30,
//                                     backgroundColor: Colors.grey[300],
//                                     child: const Text('No Image'),
//                                   ),
//                             title: Text(
//                               product['title'] ?? 'Unknown Product',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             trailing: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.edit, color: Colors.purple),
//                                   onPressed: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => EditProductFormPage(
//                                           product: product,
//                                           sellerId: widget.sellerId,
//                                           token: widget.token,
//                                         ),
//                                       ),
//                                     ).then((_) => _fetchProducts());
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.purple),
//                                   onPressed: () {
//                                     _showDeleteConfirmationDialog(
//                                       context,
//                                       product['_id'].toString(),
//                                       product['title'] ?? 'Unknown Product',
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AddProductFormPage extends StatefulWidget {
//   final String sellerId;
//   final String? token;

//   const AddProductFormPage({super.key, required this.sellerId, this.token});

//   @override
//   _AddProductFormPageState createState() => _AddProductFormPageState();
// }

// class _AddProductFormPageState extends State<AddProductFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _quantityController = TextEditingController();
//   String? _selectedCategoryId;
//   PlatformFile? _selectedImageFile;
//   List<dynamic> _categories = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchCategories();
//   }

//   Future<void> _fetchCategories() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/categories'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print('Fetched categories for dropdown: $data');
//         setState(() {
//           _categories = data;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load categories: ${response.statusCode} - ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching categories: $e')),
//       );
//     }
//   }

//   Future<void> _addProduct(String title, String price, String description, String categoryId, PlatformFile? imageFile, String quantity) async {
//     if (imageFile == null || categoryId.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an image and a category')),
//       );
//       return;
//     }

//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/seller/products'),
//       );
//       if (widget.token != null) {
//         request.headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       request.fields['title'] = title;
//       request.fields['price'] = price;
//       request.fields['description'] = description;
//       request.fields['categoryId'] = categoryId;
//       request.fields['sellerId'] = widget.sellerId;
//       request.fields['quantity'] = quantity;
//       request.fields['productStatus'] = 'available';

//       final bytes = <int>[];
//       if (imageFile.readStream != null) {
//         await for (var chunk in imageFile.readStream!) {
//           bytes.addAll(chunk);
//         }
//       } else if (imageFile.bytes != null) {
//         bytes.addAll(imageFile.bytes!);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('File data is unavailable')),
//         );
//         return;
//       }

//       print('Uploading file with ${bytes.length} bytes');
//       request.files.add(
//         http.MultipartFile.fromBytes(
//           'image',
//           bytes,
//           filename: imageFile.name,
//           contentType: MediaType('image', imageFile.extension ?? 'jpeg'),
//         ),
//       );

//       final response = await request.send();
//       final responseBody = await http.Response.fromStream(response);

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Product added successfully')),
//         );
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to add product: ${responseBody.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error in _addProduct: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error adding product: $e')),
//       );
//     }
//   }

//   void _clearForm() {
//     _titleController.clear();
//     _priceController.clear();
//     _descriptionController.clear();
//     _quantityController.clear();
//     _selectedCategoryId = null;
//     _selectedImageFile = null;
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     _quantityController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Add Product',
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
//                   'Add Product',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product title' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _priceController,
//                   decoration: InputDecoration(
//                     labelText: 'Price',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product price' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   maxLines: 3,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product description' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _quantityController,
//                   decoration: InputDecoration(
//                     labelText: 'Quantity',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product quantity' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: 'Category',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   value: _selectedCategoryId,
//                   hint: const Text('Select Category'),
//                   items: _categories.map((category) {
//                     return DropdownMenuItem<String>(
//                       value: category['_id'].toString(),
//                       child: Text(category['name']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCategoryId = value;
//                     });
//                   },
//                   validator: (value) =>
//                       value == null ? 'Please select a category' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(
//                         type: FileType.image,
//                         allowMultiple: false,
//                       );
//                       if (result != null && result.files.isNotEmpty) {
//                         setState(() {
//                           _selectedImageFile = result.files.first;
//                           print('Selected file: ${_selectedImageFile?.name}');
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No file selected')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error selecting image: $e')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     _selectedImageFile == null
//                         ? 'Select Product Image'
//                         : 'Image Selected: ${_selectedImageFile!.name}',
//                     style: GoogleFonts.poppins(),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         _addProduct(
//                           _titleController.text,
//                           _priceController.text,
//                           _descriptionController.text,
//                           _selectedCategoryId!,
//                           _selectedImageFile,
//                           _quantityController.text,
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: Text(
//                       'Add Product',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
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

// class EditProductFormPage extends StatefulWidget {
//   final Map<String, dynamic> product;
//   final String sellerId;
//   final String? token;

//   const EditProductFormPage({super.key, required this.product, required this.sellerId, this.token});

//   @override
//   _EditProductFormPageState createState() => _EditProductFormPageState();
// }

// class _EditProductFormPageState extends State<EditProductFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _quantityController = TextEditingController();
//   String? _selectedCategoryId;
//   String? _selectedProductStatus;
//   PlatformFile? _selectedImageFile;
//   String? _currentImageUrl;
//   List<dynamic> _categories = [];

//   @override
//   void initState() {
//     super.initState();
//     _titleController.text = widget.product['title'] ?? '';
//     _priceController.text = widget.product['price']?.toString() ?? '';
//     _descriptionController.text = widget.product['description'] ?? '';
//     _quantityController.text = widget.product['quantity']?.toString() ?? '';
//     _selectedCategoryId = widget.product['categoryId']?.toString();
//     _selectedProductStatus = widget.product['productStatus'] ?? 'available';
//     _currentImageUrl = widget.product['image'];
//     _fetchCategories();
//   }

//   Future<void> _fetchCategories() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/categories'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _categories = data;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load categories: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching categories: $e')),
//       );
//     }
//   }

//   Future<void> _updateProduct() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/seller/products/${widget.product['_id']}'),
//         );
//         if (widget.token != null) {
//           request.headers['Authorization'] = 'Bearer ${widget.token}';
//         }
//         request.fields['title'] = _titleController.text;
//         request.fields['price'] = _priceController.text;
//         request.fields['description'] = _descriptionController.text;
//         request.fields['quantity'] = _quantityController.text;
//         request.fields['categoryId'] = _selectedCategoryId!;
//         request.fields['sellerId'] = widget.sellerId;
//         request.fields['productStatus'] = _selectedProductStatus!;

//         if (_selectedImageFile != null) {
//           final bytes = <int>[];
//           if (_selectedImageFile!.readStream != null) {
//             await for (var chunk in _selectedImageFile!.readStream!) {
//               bytes.addAll(chunk);
//             }
//           } else if (_selectedImageFile!.bytes != null) {
//             bytes.addAll(_selectedImageFile!.bytes!);
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('File data is unavailable')),
//             );
//             return;
//           }

//           request.files.add(
//             http.MultipartFile.fromBytes(
//               'image',
//               bytes,
//               filename: _selectedImageFile!.name,
//               contentType: MediaType('image', _selectedImageFile!.extension ?? 'jpeg'),
//             ),
//           );
//         } else {
//           request.fields['image'] = _currentImageUrl ?? '';
//         }

//         print('Updating product with fields: ${request.fields}');
//         print('Files: ${request.files.map((file) => file.filename).toList()}');

//         final response = await request.send();
//         final responseBody = await http.Response.fromStream(response);

//         print('Response status: ${response.statusCode}');
//         print('Response body: ${responseBody.body}');

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Product updated successfully')),
//           );
//           Navigator.pop(context);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to update product: ${responseBody.body}')),
//           );
//         }
//       } catch (error) {
//         print('Error updating product: $error');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating product: $error')),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     _quantityController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Edit Product',
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
//                   'Edit Product',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product title' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _priceController,
//                   decoration: InputDecoration(
//                     labelText: 'Price',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product price' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   maxLines: 3,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product description' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _quantityController,
//                   decoration: InputDecoration(
//                     labelText: 'Quantity',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product quantity' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: 'Category',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   value: _selectedCategoryId,
//                   hint: const Text('Select Category'),
//                   items: _categories.map((category) {
//                     return DropdownMenuItem<String>(
//                       value: category['_id'].toString(),
//                       child: Text(category['name']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCategoryId = value;
//                     });
//                   },
//                   validator: (value) =>
//                       value == null ? 'Please select a category' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: 'Product Status',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   value: _selectedProductStatus,
//                   hint: const Text('Select Product Status'),
//                   items: const [
//                     DropdownMenuItem<String>(
//                       value: 'available',
//                       child: Text('Available'),
//                     ),
//                     DropdownMenuItem<String>(
//                       value: 'sold',
//                       child: Text('Sold'),
//                     ),
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedProductStatus = value;
//                     });
//                   },
//                   validator: (value) =>
//                       value == null ? 'Please select a product status' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 _currentImageUrl != null
//                     ? Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Current Image:',
//                             style: GoogleFonts.poppins(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Image.network(
//                             '$baseUrl$_currentImageUrl',
//                             height: 100,
//                             width: 100,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return const Text('Error loading image');
//                             },
//                           ),
//                         ],
//                       )
//                     : const SizedBox.shrink(),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(
//                         type: FileType.image,
//                         allowMultiple: false,
//                       );
//                       if (result != null && result.files.isNotEmpty) {
//                         setState(() {
//                           _selectedImageFile = result.files.first;
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No file selected')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error selecting image: $e')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     _selectedImageFile == null
//                         ? 'Select New Product Image'
//                         : 'Image Selected: ${_selectedImageFile!.name}',
//                     style: GoogleFonts.poppins(),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _updateProduct,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: Text(
//                       'Update Product',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
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

// class OrdersPage extends StatelessWidget {
//   const OrdersPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Orders Page - Under Development',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

// class DeliveryPage extends StatelessWidget {
//   const DeliveryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Delivery Page - Under Development',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

// class SellerChatListPage extends StatefulWidget {
//   final String token;
//   final String sellerId;

//   const SellerChatListPage({
//     super.key,
//     required this.token,
//     required this.sellerId,
//   });

//   @override
//   _SellerChatListPageState createState() => _SellerChatListPageState();
// }

// class _SellerChatListPageState extends State<SellerChatListPage> {
//   List<dynamic> _chats = [];
//   List<dynamic> _filteredChats = [];
//   Map<String, List<dynamic>> _groupedChats = {};
//   bool _isLoading = true;
//   String _searchQuery = '';
//   final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

//   @override
//   void initState() {
//     super.initState();
//     _fetchChats();
//   }

//   Future<void> _fetchChats() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/chat/seller'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _chats = data;
//           _filteredChats = data;
//           _groupChatsByProduct();
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load chats: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching chats: $e')),
//       );
//     }
//   }

//   void _groupChatsByProduct() {
//     final Map<String, List<dynamic>> grouped = {};
//     for (var chat in _filteredChats) {
//       final productName = chat['productName'] ?? 'Unknown Product';
//       if (!grouped.containsKey(productName)) {
//         grouped[productName] = [];
//       }
//       grouped[productName]!.add(chat);
//     }
//     setState(() {
//       _groupedChats = grouped;
//     });
//   }

//   Future<void> _deleteChat(String chatId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/chat/seller/$chatId'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _chats.removeWhere((chat) => chat['_id'] == chatId);
//           _filteredChats.removeWhere((chat) => chat['_id'] == chatId);
//           _groupChatsByProduct();
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Chat deleted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete chat: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting chat: $e')),
//       );
//     }
//   }

//   void _filterChats(String query) {
//     setState(() {
//       _searchQuery = query;
//       if (query.isEmpty) {
//         _filteredChats = _chats;
//       } else {
//         _filteredChats = _chats.where((chat) {
//           final clientName = chat['clientName']?.toString().toLowerCase() ?? '';
//           final productName = chat['productName']?.toString().toLowerCase() ?? '';
//           final latestMessage = chat['latestMessage']?.toString().toLowerCase() ?? '';
//           final searchLower = query.toLowerCase();
//           return clientName.contains(searchLower) ||
//               productName.contains(searchLower) ||
//               latestMessage.contains(searchLower);
//         }).toList();
//       }
//       _groupChatsByProduct();
//     });
//   }

//   void _showDeleteConfirmationDialog(BuildContext context, String chatId, String clientName, String productName) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: Text(
//             'Delete Chat',
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: primaryColor,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete the chat with $clientName about "$productName"?',
//             style: GoogleFonts.poppins(fontSize: 16),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Cancel',
//                 style: GoogleFonts.poppins(color: primaryColor),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 _deleteChat(chatId);
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Delete',
//                 style: GoogleFonts.poppins(color: primaryColor),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         title: Text(
//           'Chats',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               onChanged: _filterChats,
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.search, color: primaryColor),
//                 hintText: 'Search by client, product, or message',
//                 hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                 filled: true,
//                 fillColor: Colors.grey[100],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: primaryColor, width: 1),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: primaryColor, width: 1),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: primaryColor, width: 1.5),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               ),
//               style: GoogleFonts.poppins(fontSize: 14),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
//                 : _groupedChats.isEmpty
//                     ? Center(
//                         child: Text(
//                           'No chats available',
//                           style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
//                         ),
//                       )
//                     : ListView.builder(
//                         padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
//                         itemCount: _groupedChats.keys.length,
//                         itemBuilder: (context, index) {
//                           final productName = _groupedChats.keys.elementAt(index);
//                           final chats = _groupedChats[productName]!;
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 12.0),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(10),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.2),
//                                   spreadRadius: 1,
//                                   blurRadius: 4,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: ExpansionTile(
//                               tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                               childrenPadding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
//                               title: Text(
//                                 '$productName (${chats.length})',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                   color: primaryColor,
//                                 ),
//                               ),
//                               children: chats.map((chat) {
//                                 return Container(
//                                   margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(10),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.grey.withOpacity(0.2),
//                                         spreadRadius: 1,
//                                         blurRadius: 4,
//                                         offset: const Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: ListTile(
//                                     contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
//                                     title: Text(
//                                       'Client: ${chat['clientName']}',
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                         color: primaryColor,
//                                       ),
//                                     ),
//                                     subtitle: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           chat['latestMessage'] ?? '[Empty Message]',
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 12,
//                                             color: Colors.grey[600],
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ],
//                                     ),
//                                     trailing: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Text(
//                                           _formatDateTime(chat['latestMessageTime']),
//                                           style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                                         ),
//                                         const SizedBox(width: 8),
//                                         IconButton(
//                                           icon: Icon(Icons.delete, color: primaryColor),
//                                           onPressed: () {
//                                             _showDeleteConfirmationDialog(
//                                               context,
//                                               chat['_id'].toString(),
//                                               chat['clientName'] ?? 'Unknown Client',
//                                               chat['productName'] ?? 'Unknown Product',
//                                             );
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => SellerChatPage(
//                                             chatId: chat['_id'].toString(),
//                                             productName: chat['productName'],
//                                             sellerId: widget.sellerId,
//                                             token: widget.token,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDateTime(String dateTime) {
//     final date = DateTime.parse(dateTime);
//     final now = DateTime.now();
//     final difference = now.difference(date);
//     if (difference.inDays > 0) {
//       return '${difference.inDays}d ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes}m ago';
//     } else {
//       return 'Just now';
//     }
//   }
// }



// version to update title index
 
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'sellerchat.dart';
// import 'sellerchangepassword.dart';
// import 'sellerorder.dart';
// import 'baseurl.dart';

// class SellerHomePage extends StatefulWidget {
//   final String sellerId;
//   final String token;

//   const SellerHomePage({super.key, required this.sellerId, required this.token});

//   @override
//   _SellerHomePageState createState() => _SellerHomePageState();
// }

// class _SellerHomePageState extends State<SellerHomePage> {
//   int _selectedIndex = 0;
//   String _sellerName = "John Doe";
//   String? _profilePicture;
//   final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

//   @override
//   void initState() {
//     super.initState();
//     _fetchSellerProfile();
//   }

//   Future<void> _fetchSellerProfile() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _sellerName = '${data['firstName']} ${data['lastName']}';
//           _profilePicture = data['profilePicture'];
//         });
//       } else {
//         print('Failed to load seller profile: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching seller profile: $e');
//     }
//   }

//   late final List<Widget> _pages;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _pages = [
//       AddProductPage(sellerId: widget.sellerId, token: widget.token),
//       ClientOrdersPage(sellerId: widget.sellerId, token: widget.token),
//       SellerChatListPage(token: widget.token, sellerId: widget.sellerId),
//       SetProfilePage(sellerId: widget.sellerId, token: widget.token),
//       SellerChangePasswordPage(sellerId: widget.sellerId, token: widget.token),
//     ];
//   }

//   void _onItemTapped(int index) {
//     if (index == 5) {
//       print('Logging out');
//       Navigator.pushReplacementNamed(context, '/login');
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         title: Text(
//           _selectedIndex == 0
//               ? 'Products'
//               : _selectedIndex == 1
//                   ? 'Orders'
//                   : _selectedIndex == 2
//                       ? 'Chat'
//                       : _selectedIndex == 3
//                           ? 'Set Profile'
//                           : _selectedIndex == 4
//                               ? 'Change Password'
//                               : 'Seller Panel',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       drawer: Drawer(
//         width: 240,
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserAccountsDrawerHeader(
//               accountName: Text(
//                 _sellerName,
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               accountEmail: Text(
//                 'Welcome, $_sellerName',
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   color: Colors.white70,
//                 ),
//               ),
//               currentAccountPicture: _profilePicture != null
//                   ? CircleAvatar(
//                       backgroundImage: NetworkImage('$baseUrl$_profilePicture'),
//                       onBackgroundImageError: (exception, stackTrace) {
//                         print('Error loading profile picture: $exception');
//                       },
//                     )
//                   : CircleAvatar(
//                       backgroundColor: primaryColor,
//                       child: Text(
//                         _sellerName.isNotEmpty ? _sellerName[0].toUpperCase() : 'P',
//                         style: GoogleFonts.poppins(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//               decoration: BoxDecoration(
//                 color: primaryColor,
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.inventory, color: primaryColor),
//               title: Text(
//                 'Products',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               selected: _selectedIndex == 0,
//               onTap: () {
//                 _onItemTapped(0);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.receipt, color: primaryColor),
//               title: Text(
//                 'Orders',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               selected: _selectedIndex == 1,
//               onTap: () {
//                 _onItemTapped(1);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.chat, color: primaryColor),
//               title: Text(
//                 'Chat',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               selected: _selectedIndex == 2,
//               onTap: () {
//                 _onItemTapped(2);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.person, color: primaryColor),
//               title: Text(
//                 'Set Profile',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               selected: _selectedIndex == 3,
//               onTap: () {
//                 _onItemTapped(3);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.lock, color: primaryColor),
//               title: Text(
//                 'Change Password',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               selected: _selectedIndex == 4,
//               onTap: () {
//                 _onItemTapped(4);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.logout, color: primaryColor),
//               title: Text(
//                 'Logout',
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//               onTap: () {
//                 _onItemTapped(5);
//               },
//             ),
//           ],
//         ),
//       ),
//       body: _pages[_selectedIndex],
//     );
//   }
// }


// class SetProfilePage extends StatefulWidget {
//   final String sellerId;
//   final String? token;

//   const SetProfilePage({super.key, required this.sellerId, this.token});

//   @override
//   _SetProfilePageState createState() => _SetProfilePageState();
// }

// class _SetProfilePageState extends State<SetProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   PlatformFile? _selectedProfilePicture;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSellerProfile();
//   }

//   Future<void> _fetchSellerProfile() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _firstNameController.text = data['firstName'] ?? '';
//           _lastNameController.text = data['lastName'] ?? '';
//           _emailController.text = data['email'] ?? '';
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load profile: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching profile: $e')),
//       );
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
//         );
//         if (widget.token != null) {
//           request.headers['Authorization'] = 'Bearer ${widget.token}';
//         }
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
//           Navigator.pop(context);
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
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Set Profile',
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
//                   'Set Profile',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(
//                         type: FileType.image,
//                         allowMultiple: false,
//                       );
//                       if (result != null && result.files.isNotEmpty) {
//                         setState(() {
//                           _selectedProfilePicture = result.files.first;
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No file selected')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error selecting image: $e')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     _selectedProfilePicture == null
//                         ? 'Select Profile Picture'
//                         : 'Image Selected: ${_selectedProfilePicture!.name}',
//                     style: GoogleFonts.poppins(),
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
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter email' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _passwordController,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     suffixIcon: TextButton(
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Change Password feature coming soon')),
//                         );
//                       },
//                       child: const Text('Change Password'),
//                     ),
//                   ),
//                   obscureText: true,
//                   enabled: false,
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _updateProfile,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: Text(
//                       'Update Profile',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
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

// class AddProductPage extends StatefulWidget {
//   final String sellerId;
//   final String? token;

//   const AddProductPage({super.key, required this.sellerId, this.token});

//   @override
//   _AddProductPageState createState() => _AddProductPageState();
// }

// class _AddProductPageState extends State<AddProductPage> {
//   List<dynamic> _products = [];
//   List<dynamic> _filteredProducts = [];
//   bool _isLoading = true;
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchProducts();
//   }

//   Future<void> _fetchProducts() async {
//     setState(() => _isLoading = true);
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/seller/products/${widget.sellerId}'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _products = data;
//           _filteredProducts = data;
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load products: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching products: $e')),
//       );
//     }
//   }

//   Future<void> _deleteProduct(String productId) async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.delete(
//         Uri.parse('$baseUrl/seller/products/$productId'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           _products.removeWhere((p) => p['_id'] == productId);
//           _filteredProducts.removeWhere((p) => p['_id'] == productId);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Product deleted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete product: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting product: $e')),
//       );
//     }
//   }

//   void _filterProducts(String query) {
//     setState(() {
//       _searchQuery = query;
//       _filteredProducts = _products.where((product) {
//         final title = product['title']?.toString().toLowerCase() ?? '';
//         final searchLower = query.toLowerCase();
//         return title.contains(searchLower);
//       }).toList();
//     });
//   }

//   void _showDeleteConfirmationDialog(BuildContext context, String productId, String productTitle) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: Text(
//             'Delete Product',
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.red,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete the product "$productTitle"?',
//             style: GoogleFonts.poppins(fontSize: 16),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Cancel',
//                 style: GoogleFonts.poppins(color: Colors.red),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 _deleteProduct(productId);
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Delete',
//                 style: GoogleFonts.poppins(color: Colors.red),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Row(
//           children: [
//             Text(
//               'Products (${_filteredProducts.length})',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const Spacer(),
//             IconButton(
//               icon: const Icon(Icons.add, color: Colors.white),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => AddProductFormPage(
//                       sellerId: widget.sellerId,
//                       token: widget.token,
//                     ),
//                   ),
//                 ).then((_) => _fetchProducts());
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               onChanged: _filterProducts,
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.search, color: Colors.purple),
//                 hintText: 'Search by product name',
//                 hintStyle: const TextStyle(color: Colors.grey),
//                 filled: true,
//                 fillColor: const Color(0xFFE0E0E0),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: Colors.purple, width: 2),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//                     itemCount: _filteredProducts.length,
//                     itemBuilder: (context, index) {
//                       final product = _filteredProducts[index];
//                       final imageUrl = product['image'] != null
//                           ? '$baseUrl${product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
//                           : null;
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12.0),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.3),
//                                 spreadRadius: 2,
//                                 blurRadius: 5,
//                                 offset: const Offset(0, 3),
//                               ),
//                             ],
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                           ),
//                           child: ListTile(
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                             leading: imageUrl != null
//                                 ? CircleAvatar(
//                                     radius: 30,
//                                     backgroundImage: NetworkImage(imageUrl),
//                                     backgroundColor: Colors.grey[300],
//                                     onBackgroundImageError: (exception, stackTrace) {
//                                       print('Error loading product image: $exception');
//                                     },
//                                   )
//                                 : CircleAvatar(
//                                     radius: 30,
//                                     backgroundColor: Colors.grey[300],
//                                     child: const Text('No Image'),
//                                   ),
//                             title: Text(
//                               product['title'] ?? 'Unknown Product',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             trailing: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.edit, color: Colors.purple),
//                                   onPressed: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => EditProductFormPage(
//                                           product: product,
//                                           sellerId: widget.sellerId,
//                                           token: widget.token,
//                                         ),
//                                       ),
//                                     ).then((_) => _fetchProducts());
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.purple),
//                                   onPressed: () {
//                                     _showDeleteConfirmationDialog(
//                                       context,
//                                       product['_id'].toString(),
//                                       product['title'] ?? 'Unknown Product',
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AddProductFormPage extends StatefulWidget {
//   final String sellerId;
//   final String? token;

//   const AddProductFormPage({super.key, required this.sellerId, this.token});

//   @override
//   _AddProductFormPageState createState() => _AddProductFormPageState();
// }

// class _AddProductFormPageState extends State<AddProductFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _quantityController = TextEditingController();
//   String? _selectedCategoryId;
//   PlatformFile? _selectedImageFile;
//   List<dynamic> _categories = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchCategories();
//   }

//   Future<void> _fetchCategories() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/categories'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print('Fetched categories for dropdown: $data');
//         setState(() {
//           _categories = data;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load categories: ${response.statusCode} - ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching categories: $e')),
//       );
//     }
//   }

//   Future<void> _addProduct(String title, String price, String description, String categoryId, PlatformFile? imageFile, String quantity) async {
//     if (imageFile == null || categoryId.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an image and a category')),
//       );
//       return;
//     }

//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/seller/products'),
//       );
//       if (widget.token != null) {
//         request.headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       request.fields['title'] = title;
//       request.fields['price'] = price;
//       request.fields['description'] = description;
//       request.fields['categoryId'] = categoryId;
//       request.fields['sellerId'] = widget.sellerId;
//       request.fields['quantity'] = quantity;
//       request.fields['productStatus'] = 'available';

//       final bytes = <int>[];
//       if (imageFile.readStream != null) {
//         await for (var chunk in imageFile.readStream!) {
//           bytes.addAll(chunk);
//         }
//       } else if (imageFile.bytes != null) {
//         bytes.addAll(imageFile.bytes!);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('File data is unavailable')),
//         );
//         return;
//       }

//       print('Uploading file with ${bytes.length} bytes');
//       request.files.add(
//         http.MultipartFile.fromBytes(
//           'image',
//           bytes,
//           filename: imageFile.name,
//           contentType: MediaType('image', imageFile.extension ?? 'jpeg'),
//         ),
//       );

//       final response = await request.send();
//       final responseBody = await http.Response.fromStream(response);

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Product added successfully')),
//         );
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to add product: ${responseBody.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error in _addProduct: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error adding product: $e')),
//       );
//     }
//   }

//   void _clearForm() {
//     _titleController.clear();
//     _priceController.clear();
//     _descriptionController.clear();
//     _quantityController.clear();
//     _selectedCategoryId = null;
//     _selectedImageFile = null;
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     _quantityController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Add Product',
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
//                   'Add Product',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product title' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _priceController,
//                   decoration: InputDecoration(
//                     labelText: 'Price',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product price' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   maxLines: 3,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product description' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _quantityController,
//                   decoration: InputDecoration(
//                     labelText: 'Quantity',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product quantity' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: 'Category',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   value: _selectedCategoryId,
//                   hint: const Text('Select Category'),
//                   items: _categories.map((category) {
//                     return DropdownMenuItem<String>(
//                       value: category['_id'].toString(),
//                       child: Text(category['name']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCategoryId = value;
//                     });
//                   },
//                   validator: (value) =>
//                       value == null ? 'Please select a category' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(
//                         type: FileType.image,
//                         allowMultiple: false,
//                       );
//                       if (result != null && result.files.isNotEmpty) {
//                         setState(() {
//                           _selectedImageFile = result.files.first;
//                           print('Selected file: ${_selectedImageFile?.name}');
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No file selected')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error selecting image: $e')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     _selectedImageFile == null
//                         ? 'Select Product Image'
//                         : 'Image Selected: ${_selectedImageFile!.name}',
//                     style: GoogleFonts.poppins(),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         _addProduct(
//                           _titleController.text,
//                           _priceController.text,
//                           _descriptionController.text,
//                           _selectedCategoryId!,
//                           _selectedImageFile,
//                           _quantityController.text,
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: Text(
//                       'Add Product',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
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

// class EditProductFormPage extends StatefulWidget {
//   final Map<String, dynamic> product;
//   final String sellerId;
//   final String? token;

//   const EditProductFormPage({super.key, required this.product, required this.sellerId, this.token});

//   @override
//   _EditProductFormPageState createState() => _EditProductFormPageState();
// }

// class _EditProductFormPageState extends State<EditProductFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _quantityController = TextEditingController();
//   String? _selectedCategoryId;
//   String? _selectedProductStatus;
//   PlatformFile? _selectedImageFile;
//   String? _currentImageUrl;
//   List<dynamic> _categories = [];

//   @override
//   void initState() {
//     super.initState();
//     _titleController.text = widget.product['title'] ?? '';
//     _priceController.text = widget.product['price']?.toString() ?? '';
//     _descriptionController.text = widget.product['description'] ?? '';
//     _quantityController.text = widget.product['quantity']?.toString() ?? '';
//     _selectedCategoryId = widget.product['categoryId']?.toString();
//     _selectedProductStatus = widget.product['productStatus'] ?? 'available';
//     _currentImageUrl = widget.product['image'];
//     _fetchCategories();
//   }

//   Future<void> _fetchCategories() async {
//     try {
//       final headers = <String, String>{};
//       if (widget.token != null) {
//         headers['Authorization'] = 'Bearer ${widget.token}';
//       }
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/categories'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _categories = data;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load categories: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching categories: $e')),
//       );
//     }
//   }

//   Future<void> _updateProduct() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/seller/products/${widget.product['_id']}'),
//         );
//         if (widget.token != null) {
//           request.headers['Authorization'] = 'Bearer ${widget.token}';
//         }
//         request.fields['title'] = _titleController.text;
//         request.fields['price'] = _priceController.text;
//         request.fields['description'] = _descriptionController.text;
//         request.fields['quantity'] = _quantityController.text;
//         request.fields['categoryId'] = _selectedCategoryId!;
//         request.fields['sellerId'] = widget.sellerId;
//         request.fields['productStatus'] = _selectedProductStatus!;

//         if (_selectedImageFile != null) {
//           final bytes = <int>[];
//           if (_selectedImageFile!.readStream != null) {
//             await for (var chunk in _selectedImageFile!.readStream!) {
//               bytes.addAll(chunk);
//             }
//           } else if (_selectedImageFile!.bytes != null) {
//             bytes.addAll(_selectedImageFile!.bytes!);
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('File data is unavailable')),
//             );
//             return;
//           }

//           request.files.add(
//             http.MultipartFile.fromBytes(
//               'image',
//               bytes,
//               filename: _selectedImageFile!.name,
//               contentType: MediaType('image', _selectedImageFile!.extension ?? 'jpeg'),
//             ),
//           );
//         } else {
//           request.fields['image'] = _currentImageUrl ?? '';
//         }

//         print('Updating product with fields: ${request.fields}');
//         print('Files: ${request.files.map((file) => file.filename).toList()}');

//         final response = await request.send();
//         final responseBody = await http.Response.fromStream(response);

//         print('Response status: ${response.statusCode}');
//         print('Response body: ${responseBody.body}');

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Product updated successfully')),
//           );
//           Navigator.pop(context);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to update product: ${responseBody.body}')),
//           );
//         }
//       } catch (error) {
//         print('Error updating product: $error');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating product: $error')),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     _quantityController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Edit Product',
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
//                   'Edit Product',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product title' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _priceController,
//                   decoration: InputDecoration(
//                     labelText: 'Price',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product price' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   maxLines: 3,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product description' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _quantityController,
//                   decoration: InputDecoration(
//                     labelText: 'Quantity',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Enter product quantity' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: 'Category',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   value: _selectedCategoryId,
//                   hint: const Text('Select Category'),
//                   items: _categories.map((category) {
//                     return DropdownMenuItem<String>(
//                       value: category['_id'].toString(),
//                       child: Text(category['name']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCategoryId = value;
//                     });
//                   },
//                   validator: (value) =>
//                       value == null ? 'Please select a category' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: 'Product Status',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   value: _selectedProductStatus,
//                   hint: const Text('Select Product Status'),
//                   items: const [
//                     DropdownMenuItem<String>(
//                       value: 'available',
//                       child: Text('Available'),
//                     ),
//                     DropdownMenuItem<String>(
//                       value: 'sold',
//                       child: Text('Sold'),
//                     ),
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedProductStatus = value;
//                     });
//                   },
//                   validator: (value) =>
//                       value == null ? 'Please select a product status' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 _currentImageUrl != null
//                     ? Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Current Image:',
//                             style: GoogleFonts.poppins(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Image.network(
//                             '$baseUrl$_currentImageUrl',
//                             height: 100,
//                             width: 100,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return const Text('Error loading image');
//                             },
//                           ),
//                         ],
//                       )
//                     : const SizedBox.shrink(),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(
//                         type: FileType.image,
//                         allowMultiple: false,
//                       );
//                       if (result != null && result.files.isNotEmpty) {
//                         setState(() {
//                           _selectedImageFile = result.files.first;
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No file selected')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error selecting image: $e')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     _selectedImageFile == null
//                         ? 'Select New Product Image'
//                         : 'Image Selected: ${_selectedImageFile!.name}',
//                     style: GoogleFonts.poppins(),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _updateProduct,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: Text(
//                       'Update Product',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
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

// class SellerChatListPage extends StatefulWidget {
//   final String token;
//   final String sellerId;

//   const SellerChatListPage({
//     super.key,
//     required this.token,
//     required this.sellerId,
//   });

//   @override
//   _SellerChatListPageState createState() => _SellerChatListPageState();
// }

// class _SellerChatListPageState extends State<SellerChatListPage> {
//   List<dynamic> _chats = [];
//   List<dynamic> _filteredChats = [];
//   Map<String, List<dynamic>> _groupedChats = {};
//   bool _isLoading = true;
//   String _searchQuery = '';
//   final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

//   @override
//   void initState() {
//     super.initState();
//     _fetchChats();
//   }

//   Future<void> _fetchChats() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/chat/seller'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _chats = data;
//           _filteredChats = data;
//           _groupChatsByProduct();
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load chats: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching chats: $e')),
//       );
//     }
//   }

//   void _groupChatsByProduct() {
//     final Map<String, List<dynamic>> grouped = {};
//     for (var chat in _filteredChats) {
//       final productName = chat['productName'] ?? 'Unknown Product';
//       if (!grouped.containsKey(productName)) {
//         grouped[productName] = [];
//       }
//       grouped[productName]!.add(chat);
//     }
//     setState(() {
//       _groupedChats = grouped;
//     });
//   }

//   Future<void> _deleteChat(String chatId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/chat/seller/$chatId'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _chats.removeWhere((chat) => chat['_id'] == chatId);
//           _filteredChats.removeWhere((chat) => chat['_id'] == chatId);
//           _groupChatsByProduct();
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Chat deleted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete chat: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting chat: $e')),
//       );
//     }
//   }

//   void _filterChats(String query) {
//     setState(() {
//       _searchQuery = query;
//       if (query.isEmpty) {
//         _filteredChats = _chats;
//       } else {
//         _filteredChats = _chats.where((chat) {
//           final clientName = chat['clientName']?.toString().toLowerCase() ?? '';
//           final productName = chat['productName']?.toString().toLowerCase() ?? '';
//           final latestMessage = chat['latestMessage']?.toString().toLowerCase() ?? '';
//           final searchLower = query.toLowerCase();
//           return clientName.contains(searchLower) ||
//               productName.contains(searchLower) ||
//               latestMessage.contains(searchLower);
//         }).toList();
//       }
//       _groupChatsByProduct();
//     });
//   }

//   void _showDeleteConfirmationDialog(BuildContext context, String chatId, String clientName, String productName) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: Text(
//             'Delete Chat',
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: primaryColor,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete the chat with $clientName about "$productName"?',
//             style: GoogleFonts.poppins(fontSize: 16),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Cancel',
//                 style: GoogleFonts.poppins(color: primaryColor),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 _deleteChat(chatId);
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Delete',
//                 style: GoogleFonts.poppins(color: primaryColor),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         title: Text(
//           'Chats',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               onChanged: _filterChats,
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.search, color: primaryColor),
//                 hintText: 'Search by client, product, or message',
//                 hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                 filled: true,
//                 fillColor: Colors.grey[100],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: primaryColor, width: 1),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: primaryColor, width: 1),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: primaryColor, width: 1.5),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               ),
//               style: GoogleFonts.poppins(fontSize: 14),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
//                 : _groupedChats.isEmpty
//                     ? Center(
//                         child: Text(
//                           'No chats available',
//                           style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
//                         ),
//                       )
//                     : ListView.builder(
//                         padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
//                         itemCount: _groupedChats.keys.length,
//                         itemBuilder: (context, index) {
//                           final productName = _groupedChats.keys.elementAt(index);
//                           final chats = _groupedChats[productName]!;
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 12.0),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(10),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.2),
//                                   spreadRadius: 1,
//                                   blurRadius: 4,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: ExpansionTile(
//                               tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                               childrenPadding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
//                               title: Text(
//                                 '$productName (${chats.length})',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                   color: primaryColor,
//                                 ),
//                               ),
//                               children: chats.map((chat) {
//                                 return Container(
//                                   margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(10),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.grey.withOpacity(0.2),
//                                         spreadRadius: 1,
//                                         blurRadius: 4,
//                                         offset: const Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: ListTile(
//                                     contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
//                                     title: Text(
//                                       'Client: ${chat['clientName']}',
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                         color: primaryColor,
//                                       ),
//                                     ),
//                                     subtitle: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           chat['latestMessage'] ?? '[Empty Message]',
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 12,
//                                             color: Colors.grey[600],
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ],
//                                     ),
//                                     trailing: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Text(
//                                           _formatDateTime(chat['latestMessageTime']),
//                                           style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                                         ),
//                                         const SizedBox(width: 8),
//                                         IconButton(
//                                           icon: Icon(Icons.delete, color: primaryColor),
//                                           onPressed: () {
//                                             _showDeleteConfirmationDialog(
//                                               context,
//                                               chat['_id'].toString(),
//                                               chat['clientName'] ?? 'Unknown Client',
//                                               chat['productName'] ?? 'Unknown Product',
//                                             );
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => SellerChatPage(
//                                             chatId: chat['_id'].toString(),
//                                             productName: chat['productName'],
//                                             sellerId: widget.sellerId,
//                                             token: widget.token,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDateTime(String dateTime) {
//     final date = DateTime.parse(dateTime);
//     final now = DateTime.now();
//     final difference = now.difference(date);
//     if (difference.inDays > 0) {
//       return '${difference.inDays}d ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes}m ago';
//     } else {
//       return 'Just now';
//     }
//   }
// }



// version ui
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'sellerchat.dart';
import 'sellerchangepassword.dart';
import 'sellerorder.dart';
import 'baseurl.dart';

class SellerHomePage extends StatefulWidget {
  final String sellerId;
  final String token;

  const SellerHomePage({super.key, required this.sellerId, required this.token});

  @override
  _SellerHomePageState createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  int _selectedIndex = 0;
  String _sellerName = "John Doe";
  String? _profilePicture;
  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

  @override
  void initState() {
    super.initState();
    _fetchSellerProfile();
  }

  Future<void> _fetchSellerProfile() async {
    try {
      final headers = <String, String>{};
      if (widget.token != null) {
        headers['Authorization'] = 'Bearer ${widget.token}';
      }
      final response = await http.get(
        Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _sellerName = '${data['firstName']} ${data['lastName']}';
          _profilePicture = data['profilePicture'];
        });
      } else {
        print('Failed to load seller profile: ${response.body}');
      }
    } catch (e) {
      print('Error fetching seller profile: $e');
    }
  }

  late final List<Widget> _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = [
      AddProductPage(sellerId: widget.sellerId, token: widget.token),
      ClientOrdersPage(sellerId: widget.sellerId, token: widget.token),
      SellerChatListPage(token: widget.token, sellerId: widget.sellerId),
      SetProfilePage(sellerId: widget.sellerId, token: widget.token),
      SellerChangePasswordPage(sellerId: widget.sellerId, token: widget.token),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 5) {
      print('Logging out');
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        _selectedIndex = index;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          _selectedIndex == 0
              ? 'Products'
              : _selectedIndex == 1
                  ? 'Orders'
                  : _selectedIndex == 2
                      ? 'Chat'
                      : _selectedIndex == 3
                          ? 'Set Profile'
                          : _selectedIndex == 4
                              ? 'Change Password'
                              : 'Seller Panel',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        width: 240,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _sellerName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(
                'Welcome, $_sellerName',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              currentAccountPicture: _profilePicture != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage('$baseUrl$_profilePicture'),
                      onBackgroundImageError: (exception, stackTrace) {
                        print('Error loading profile picture: $exception');
                      },
                    )
                  : CircleAvatar(
                      backgroundColor: primaryColor,
                      child: Text(
                        _sellerName.isNotEmpty ? _sellerName[0].toUpperCase() : 'P',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
              decoration: BoxDecoration(
                color: primaryColor,
              ),
            ),
            ListTile(
              leading: Icon(Icons.inventory, color: primaryColor),
              title: Text(
                'Products',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt, color: primaryColor),
              title: Text(
                'Orders',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.chat, color: primaryColor),
              title: Text(
                'Chat',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: primaryColor),
              title: Text(
                'Set Profile',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              selected: _selectedIndex == 3,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SetProfilePage(
                      sellerId: widget.sellerId,
                      token: widget.token,
                    ),
                  ),
                );
                // Always refresh profile data after returning from SetProfilePage
                _fetchSellerProfile();
                _onItemTapped(3);
              },
            ),
            ListTile(
              leading: Icon(Icons.lock, color: primaryColor),
              title: Text(
                'Change Password',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              selected: _selectedIndex == 4,
              onTap: () {
                _onItemTapped(4);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: primaryColor),
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              onTap: () {
                _onItemTapped(5);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

class SetProfilePage extends StatefulWidget {
  final String sellerId;
  final String? token;

  const SetProfilePage({super.key, required this.sellerId, this.token});

  @override
  _SetProfilePageState createState() => _SetProfilePageState();
}

class _SetProfilePageState extends State<SetProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  PlatformFile? _selectedProfilePicture;

  @override
  void initState() {
    super.initState();
    _fetchSellerProfile();
  }

  Future<void> _fetchSellerProfile() async {
    try {
      final headers = <String, String>{};
      if (widget.token != null) {
        headers['Authorization'] = 'Bearer ${widget.token}';
      }
      final response = await http.get(
        Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _emailController.text = data['email'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile: $e')),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/seller/profile/${widget.sellerId}'),
      );
      if (widget.token != null) {
        request.headers['Authorization'] = 'Bearer ${widget.token}';
      }
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
        // Show success SnackBar with green background and delay navigation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        // Reset form and state
        setState(() {
          _selectedProfilePicture = null;
        });
        _firstNameController.text = '';
        _lastNameController.text = '';
        _emailController.text = '';
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${responseBody.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
      // Reset form state to allow retry
      setState(() {
        _selectedProfilePicture = null;
      });
      _firstNameController.text = '';
      _lastNameController.text = '';
      _emailController.text = '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Reset form when back button is pressed
        setState(() {
          _selectedProfilePicture = null;
        });
        _firstNameController.text = '';
        _lastNameController.text = '';
        _emailController.text = '';
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 62, 62, 147),
          title: Text(
            'Set Profile',
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
                    'Set Profile',
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
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Change Password feature coming soon')),
                          );
                        },
                        child: const Text('Change Password'),
                      ),
                    ),
                    obscureText: true,
                    enabled: false,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color.fromARGB(255, 62, 62, 147),
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
            ),
          ),
        ),
      ),
    );
  }
}

class AddProductPage extends StatefulWidget {
  final String sellerId;
  final String? token;

  const AddProductPage({super.key, required this.sellerId, this.token});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final headers = <String, String>{};
      if (widget.token != null) {
        headers['Authorization'] = 'Bearer ${widget.token}';
      }
      final response = await http.get(
        Uri.parse('$baseUrl/seller/products/${widget.sellerId}'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _products = data;
          _filteredProducts = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      final headers = <String, String>{};
      if (widget.token != null) {
        headers['Authorization'] = 'Bearer ${widget.token}';
      }
      final response = await http.delete(
        Uri.parse('$baseUrl/seller/products/$productId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        setState(() {
          _products.removeWhere((p) => p['_id'] == productId);
          _filteredProducts.removeWhere((p) => p['_id'] == productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete product: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProducts = _products.where((product) {
        final title = product['title']?.toString().toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return title.contains(searchLower);
      }).toList();
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, String productId, String productTitle) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete Product',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Text(
            'Are you sure you want to delete the product "$productTitle"?',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(productId);
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 62, 62, 147),
        title: Row(
          children: [
            Text(
              'Products (${_filteredProducts.length})',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductFormPage(
                      sellerId: widget.sellerId,
                      token: widget.token,
                    ),
                  ),
                ).then((_) => _fetchProducts());
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterProducts,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 62, 62, 147)),
                hintText: 'Search by product name',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFE0E0E0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 62, 62, 147), width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final imageUrl = product['image'] != null
                          ? '$baseUrl${product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
                          : null;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            leading: imageUrl != null
                                ? CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(imageUrl),
                                    backgroundColor: Colors.grey[300],
                                    onBackgroundImageError: (exception, stackTrace) {
                                      print('Error loading product image: $exception');
                                    },
                                  )
                                : CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey[300],
                                    child: const Text('No Image'),
                                  ),
                            title: Text(
                              product['title'] ?? 'Unknown Product',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color.fromARGB(255, 62, 62, 147)),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProductFormPage(
                                          product: product,
                                          sellerId: widget.sellerId,
                                          token: widget.token,
                                        ),
                                      ),
                                    ).then((_) => _fetchProducts());
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Color.fromARGB(255, 62, 62, 147)),
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(
                                      context,
                                      product['_id'].toString(),
                                      product['title'] ?? 'Unknown Product',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class AddProductFormPage extends StatefulWidget {
  final String sellerId;
  final String? token;

  const AddProductFormPage({super.key, required this.sellerId, this.token});

  @override
  _AddProductFormPageState createState() => _AddProductFormPageState();
}

class _AddProductFormPageState extends State<AddProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _selectedCategoryId;
  PlatformFile? _selectedImageFile;
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final headers = <String, String>{};
      if (widget.token != null) {
        headers['Authorization'] = 'Bearer ${widget.token}';
      }
      final response = await http.get(
        Uri.parse('$baseUrl/admin/categories'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched categories for dropdown: $data');
        setState(() {
          _categories = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching categories: $e')),
      );
    }
  }

  Future<void> _addProduct(String title, String price, String description, String categoryId, PlatformFile? imageFile, String quantity) async {
    if (imageFile == null || categoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image and a category')),
      );
      return;
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/seller/products'),
      );
      if (widget.token != null) {
        request.headers['Authorization'] = 'Bearer ${widget.token}';
      }
      request.fields['title'] = title;
      request.fields['price'] = price;
      request.fields['description'] = description;
      request.fields['categoryId'] = categoryId;
      request.fields['sellerId'] = widget.sellerId;
      request.fields['quantity'] = quantity;
      request.fields['productStatus'] = 'available';

      final bytes = <int>[];
      if (imageFile.readStream != null) {
        await for (var chunk in imageFile.readStream!) {
          bytes.addAll(chunk);
        }
      } else if (imageFile.bytes != null) {
        bytes.addAll(imageFile.bytes!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File data is unavailable')),
        );
        return;
      }

      print('Uploading file with ${bytes.length} bytes');
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
          contentType: MediaType('image', imageFile.extension ?? 'jpeg'),
        ),
      );

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: ${responseBody.body}')),
        );
      }
    } catch (e) {
      print('Error in _addProduct: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
      );
    }
  }

  void _clearForm() {
    _titleController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _quantityController.clear();
    _selectedCategoryId = null;
    _selectedImageFile = null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 62, 62, 147),
        title: Text(
          'Add Product',
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
                  'Add Product',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter product title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter product price' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter product description' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter product quantity' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _selectedCategoryId,
                  hint: const Text('Select Category'),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['_id'].toString(),
                      child: Text(category['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
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
                          _selectedImageFile = result.files.first;
                          print('Selected file: ${_selectedImageFile?.name}');
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
                    _selectedImageFile == null
                        ? 'Select Product Image'
                        : 'Image Selected: ${_selectedImageFile!.name}',
                    style: GoogleFonts.poppins(),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _addProduct(
                          _titleController.text,
                          _priceController.text,
                          _descriptionController.text,
                          _selectedCategoryId!,
                          _selectedImageFile,
                          _quantityController.text,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color.fromARGB(255, 62, 62, 147),
                    ),
                    child: Text(
                      'Add Product',
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
          ),
        ),
      ),
    );
  }
}

class EditProductFormPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final String sellerId;
  final String? token;

  const EditProductFormPage({super.key, required this.product, required this.sellerId, this.token});

  @override
  _EditProductFormPageState createState() => _EditProductFormPageState();
}

class _EditProductFormPageState extends State<EditProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedProductStatus;
  PlatformFile? _selectedImageFile;
  String? _currentImageUrl;
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.product['title'] ?? '';
    _priceController.text = widget.product['price']?.toString() ?? '';
    _descriptionController.text = widget.product['description'] ?? '';
    _quantityController.text = widget.product['quantity']?.toString() ?? '';
    _selectedCategoryId = widget.product['categoryId']?.toString();
    _selectedProductStatus = widget.product['productStatus'] ?? 'available';
    _currentImageUrl = widget.product['image'];
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final headers = <String, String>{};
      if (widget.token != null) {
        headers['Authorization'] = 'Bearer ${widget.token}';
      }
      final response = await http.get(
        Uri.parse('$baseUrl/admin/categories'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _categories = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching categories: $e')),
      );
    }
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        final request = http.MultipartRequest(
          'PUT',
          Uri.parse('$baseUrl/seller/products/${widget.product['_id']}'),
        );
        if (widget.token != null) {
          request.headers['Authorization'] = 'Bearer ${widget.token}';
        }
        request.fields['title'] = _titleController.text;
        request.fields['price'] = _priceController.text;
        request.fields['description'] = _descriptionController.text;
        request.fields['quantity'] = _quantityController.text;
        request.fields['categoryId'] = _selectedCategoryId!;
        request.fields['sellerId'] = widget.sellerId;
        request.fields['productStatus'] = _selectedProductStatus!;

        if (_selectedImageFile != null) {
          final bytes = <int>[];
          if (_selectedImageFile!.readStream != null) {
            await for (var chunk in _selectedImageFile!.readStream!) {
              bytes.addAll(chunk);
            }
          } else if (_selectedImageFile!.bytes != null) {
            bytes.addAll(_selectedImageFile!.bytes!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File data is unavailable')),
            );
            return;
          }

          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              bytes,
              filename: _selectedImageFile!.name,
              contentType: MediaType('image', _selectedImageFile!.extension ?? 'jpeg'),
            ),
          );
        } else {
          request.fields['image'] = _currentImageUrl ?? '';
        }

        print('Updating product with fields: ${request.fields}');
        print('Files: ${request.files.map((file) => file.filename).toList()}');

        final response = await request.send();
        final responseBody = await http.Response.fromStream(response);

        print('Response status: ${response.statusCode}');
        print('Response body: ${responseBody.body}');

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update product: ${responseBody.body}')),
          );
        }
      } catch (error) {
        print('Error updating product: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating product: $error')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 62, 62, 147),
        title: Text(
          'Edit Product',
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
                  'Edit Product',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter product title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter product price' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter product description' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter product quantity' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _selectedCategoryId,
                  hint: const Text('Select Category'),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['_id'].toString(),
                      child: Text(category['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Product Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _selectedProductStatus,
                  hint: const Text('Select Product Status'),
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'available',
                      child: Text('Available'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'sold',
                      child: Text('Sold'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedProductStatus = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a product status' : null,
                ),
                const SizedBox(height: 16),
                _currentImageUrl != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Image:',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Image.network(
                            '$baseUrl$_currentImageUrl',
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text('Error loading image');
                            },
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
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
                          _selectedImageFile = result.files.first;
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
                    _selectedImageFile == null
                        ? 'Select New Product Image'
                        : 'Image Selected: ${_selectedImageFile!.name}',
                    style: GoogleFonts.poppins(),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateProduct,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color.fromARGB(255, 62, 62, 147),
                    ),
                    child: Text(
                      'Update Product',
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
          ),
        ),
      ),
    );
  }
}

class SellerChatListPage extends StatefulWidget {
  final String token;
  final String sellerId;

  const SellerChatListPage({
    super.key,
    required this.token,
    required this.sellerId,
  });

  @override
  _SellerChatListPageState createState() => _SellerChatListPageState();
}

class _SellerChatListPageState extends State<SellerChatListPage> {
  List<dynamic> _chats = [];
  List<dynamic> _filteredChats = [];
  Map<String, List<dynamic>> _groupedChats = {};
  bool _isLoading = true;
  String _searchQuery = '';
  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/seller'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _chats = data;
          _filteredChats = data;
          _groupChatsByProduct();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load chats: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching chats: $e')),
      );
    }
  }

  void _groupChatsByProduct() {
    final Map<String, List<dynamic>> grouped = {};
    for (var chat in _filteredChats) {
      final productName = chat['productName'] ?? 'Unknown Product';
      if (!grouped.containsKey(productName)) {
        grouped[productName] = [];
      }
      grouped[productName]!.add(chat);
    }
    setState(() {
      _groupedChats = grouped;
    });
  }

  Future<void> _deleteChat(String chatId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/chat/seller/$chatId'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _chats.removeWhere((chat) => chat['_id'] == chatId);
          _filteredChats.removeWhere((chat) => chat['_id'] == chatId);
          _groupChatsByProduct();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete chat: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting chat: $e')),
      );
    }
  }

  void _filterChats(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredChats = _chats;
      } else {
        _filteredChats = _chats.where((chat) {
          final clientName = chat['clientName']?.toString().toLowerCase() ?? '';
          final productName = chat['productName']?.toString().toLowerCase() ?? '';
          final latestMessage = chat['latestMessage']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return clientName.contains(searchLower) ||
              productName.contains(searchLower) ||
              latestMessage.contains(searchLower);
        }).toList();
      }
      _groupChatsByProduct();
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, String chatId, String clientName, String productName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete Chat',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          content: Text(
            'Are you sure you want to delete the chat with $clientName about "$productName"?',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: primaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteChat(chatId);
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(color: primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Chats',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterChats,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: primaryColor),
                hintText: 'Search by client, product, or message',
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
                : _groupedChats.isEmpty
                    ? Center(
                        child: Text(
                          'No chats available',
                          style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        itemCount: _groupedChats.keys.length,
                        itemBuilder: (context, index) {
                          final productName = _groupedChats.keys.elementAt(index);
                          final chats = _groupedChats[productName]!;
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
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              childrenPadding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                              title: Text(
                                '$productName (${chats.length})',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                              children: chats.map((chat) {
                                return Container(
                                  margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
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
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                                    title: Text(
                                      'Client: ${chat['clientName']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          chat['latestMessage'] ?? '[Empty Message]',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatDateTime(chat['latestMessageTime']),
                                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: primaryColor),
                                          onPressed: () {
                                            _showDeleteConfirmationDialog(
                                              context,
                                              chat['_id'].toString(),
                                              chat['clientName'] ?? 'Unknown Client',
                                              chat['productName'] ?? 'Unknown Product',
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SellerChatPage(
                                            chatId: chat['_id'].toString(),
                                            productName: chat['productName'],
                                            sellerId: widget.sellerId,
                                            token: widget.token,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTime) {
    final date = DateTime.parse(dateTime);
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}