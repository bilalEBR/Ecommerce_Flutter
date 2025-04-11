// // adminproduct.dart
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'dart:io' show Platform;

// class AdminProductPage extends StatefulWidget {
//   const AdminProductPage({super.key});

//   @override
//   _AdminProductPageState createState() => _AdminProductPageState();
// }

// class _AdminProductPageState extends State<AdminProductPage> {
//   List<dynamic> _products = [];
//   List<dynamic> _filteredProducts = [];
//   List<dynamic> _categories = [];
//   bool _isLoading = true;
//   String _searchQuery = '';
//   final String baseUrl = kIsWeb
//       ? 'http://localhost:3000'
//       : 'http://192.168.1.100:3000'; // Replace with your machine's IP for mobile

//   // Controllers for input fields in add/edit dialogs
//   final _titleController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   String? _selectedCategoryId;
//   PlatformFile? _selectedImageFile;

//   @override
//   void initState() {
//     super.initState();
//     _fetchProducts();
//     _fetchCategories();
//   }

//   Future<void> _fetchProducts() async {
//     setState(() => _isLoading = true);
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/products'),
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print('Fetched products: $data');
//         setState(() {
//           _products = data;
//           _filteredProducts = data;
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load products: ${response.statusCode} - ${response.body}')),
//         );
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching products: $e')),
//       );
//     }
//   }

//   Future<void> _fetchCategories() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/categories'),
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

//   Future<void> _deleteProduct(String productId) async {
//     try {
//       final url = '$baseUrl/admin/products/$productId';
//       final response = await http.delete(Uri.parse(url));
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






//   Future<void> _addProduct(String title, String price, String description, String categoryId, PlatformFile? imageFile) async {
//     if (imageFile == null || categoryId.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an image and a category')),
//       );
//       return;
//     }

//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/admin/products'),
//       );
//       request.fields['title'] = title;
//       request.fields['price'] = price;
//       request.fields['description'] = description;
//       request.fields['categoryId'] = categoryId;

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
//         await _fetchProducts();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Product added successfully')),
//         );
//         _clearForm();
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




//   Future<void> _updateProduct(String productId, String title, String price, String description, String categoryId, PlatformFile? imageFile) async {
//     try {
//       final request = http.MultipartRequest(
//         'PUT',
//         Uri.parse('$baseUrl/admin/products/$productId'),
//       );
//       request.fields['title'] = title;
//       request.fields['price'] = price;
//       request.fields['description'] = description;
//       request.fields['categoryId'] = categoryId;

//       if (imageFile != null) {
//         final bytes = <int>[];
//         if (imageFile.readStream != null) {
//           await for (var chunk in imageFile.readStream!) {
//             bytes.addAll(chunk);
//           }
//         } else if (imageFile.bytes != null) {
//           bytes.addAll(imageFile.bytes!);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('File data is unavailable')),
//           );
//           return;
//         }

//         request.files.add(
//           http.MultipartFile.fromBytes(
//             'image',
//             bytes,
//             filename: imageFile.name,
//             contentType: MediaType('image', imageFile.extension ?? 'jpeg'),
//           ),
//         );
//       }

//       final response = await request.send();
//       final responseBody = await http.Response.fromStream(response);

//       if (response.statusCode == 200) {
//         await _fetchProducts();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Product updated successfully')),
//         );
//         _clearForm();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to update product: ${responseBody.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error in _updateProduct: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error updating product: $e')),
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
//               color: const Color(0xFFF44336),
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
//                 style: GoogleFonts.poppins(color: const Color(0xFFF44336)),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 _deleteProduct(productId);
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Delete',
//                 style: GoogleFonts.poppins(color: const Color(0xFFF44336)),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _clearForm() {
//     _titleController.clear();
//     _priceController.clear();
//     _descriptionController.clear();
//     _selectedCategoryId = null;
//     _selectedImageFile = null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color.fromARGB(255, 129, 48, 143),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//             Navigator.pushNamed(context, '/adminpage'); // Navigate to admin page
//           },
//         ),
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
//                 _showAddProductDialog(context);
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
//                 prefixIcon: const Icon(Icons.search, color: Color(0xFFAB47BC)),
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
//                   borderSide: const BorderSide(color: Colors.green, width: 2),
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
//                       print('Attempting to load product image: $imageUrl');
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
//                                     radius: 30, // Sets diameter to 60 pixels
//                                     backgroundImage: NetworkImage(imageUrl),
//                                     backgroundColor: Colors.grey[300],
//                                     onBackgroundImageError: (exception, stackTrace) {
//                                       print('Error loading product image: $exception, StackTrace: $stackTrace');
//                                     },
//                                   )
//                                 : CircleAvatar(
//                                     radius: 30,
//                                     backgroundColor: Colors.grey[300],
//                                     child: const Center(
//                                       child: Text(
//                                         'No Image',
//                                         style: TextStyle(color: Colors.white),
//                                       ),
//                                     ),
//                                   ),
//                             title: Text(
//                               product['title'] ?? 'Unknown Product',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             trailing: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.edit, color: Color(0xFFAB47BC)),
//                                   onPressed: () {
//                                     _showEditProductDialog(context, product);
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete, color: Color(0xFFAB47BC)),
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

//   void _showAddProductDialog(BuildContext context) {
//     _titleController.clear();
//     _priceController.clear();
//     _descriptionController.clear();
//     _selectedCategoryId = null;
//     _selectedImageFile = null;

//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (dialogContext, setState) {
//             return AlertDialog(
//               title: Text(
//                 'Add New Product',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFFF44336),
//                 ),
//               ),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: _titleController,
//                       decoration: const InputDecoration(labelText: 'Product Title'),
//                     ),
//                     const SizedBox(height: 10),
//                     TextField(
//                       controller: _priceController,
//                       decoration: const InputDecoration(labelText: 'Full Price'),
//                       keyboardType: TextInputType.number,
//                     ),
//                     const SizedBox(height: 10),
//                     TextField(
//                       controller: _descriptionController,
//                       decoration: const InputDecoration(labelText: 'Product Description'),
//                       maxLines: 3,
//                     ),
//                     const SizedBox(height: 10),
//                     DropdownButton<String>(
//                       hint: const Text('Select Category'),
//                       value: _selectedCategoryId,
//                       items: _categories.map((category) {
//                         return DropdownMenuItem<String>(
//                           value: category['_id'].toString(),
//                           child: Text(category['name']),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedCategoryId = value;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: () async {
//                         try {
//                           if (!kIsWeb && Platform.isAndroid) {
//                             var status = await Permission.storage.status;
//                             if (!status.isGranted) {
//                               status = await Permission.storage.request();
//                               if (!status.isGranted) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(content: Text('Storage permission denied')),
//                                 );
//                                 return;
//                               }
//                             }
//                           }

//                           print('Attempting to open file picker...');
//                           FilePickerResult? result = await FilePicker.platform.pickFiles(
//                             type: FileType.image,
//                             allowMultiple: false,
//                           );
//                           if (result != null && result.files.isNotEmpty) {
//                             setState(() {
//                               _selectedImageFile = result.files.first;
//                               print('Selected file: ${_selectedImageFile?.name} (Path: ${kIsWeb ? "N/A (Web)" : _selectedImageFile?.path ?? "N/A"})');
//                             });
//                           } else {
//                             print('No file selected or operation cancelled');
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('No file selected')),
//                             );
//                           }
//                         } catch (e) {
//                           print('Error picking file: $e');
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Error selecting image: $e')),
//                           );
//                         }
//                       },
//                       child: Text(_selectedImageFile == null ? 'Select Product Image' : 'Image Selected: ${_selectedImageFile!.name}'),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(dialogContext);
//                   },
//                   child: Text(
//                     'Cancel',
//                     style: GoogleFonts.poppins(color: const Color(0xFFF44336)),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     if (_titleController.text.isNotEmpty &&
//                         _priceController.text.isNotEmpty &&
//                         _descriptionController.text.isNotEmpty &&
//                         _selectedCategoryId != null &&
//                         _selectedImageFile != null) {
//                       _addProduct(
//                         _titleController.text,
//                         _priceController.text,
//                         _descriptionController.text,
//                         _selectedCategoryId!,
//                         _selectedImageFile,
//                       );
//                       Navigator.pop(dialogContext);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Please fill all fields and select an image')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     'Add Product',
//                     style: GoogleFonts.poppins(color: const Color(0xFFF44336)),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }


//   void _showEditProductDialog(BuildContext context, Map<String, dynamic> product) {
//     _titleController.text = product['title'] ?? '';
//     _priceController.text = product['price']?.toString() ?? '';
//     _descriptionController.text = product['description'] ?? '';
//     _selectedCategoryId = product['categoryId']?.toString();
//     _selectedImageFile = null;

//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (dialogContext, setState) {
//             final imageUrl = product['image'] != null
//                 ? '$baseUrl${product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
//                 : null;
//             print('Edit dialog product image URL: $imageUrl');
//             return AlertDialog(
//               title: Text(
//                 'Edit Product',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFFF44336),
//                 ),
//               ),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: _titleController,
//                       decoration: const InputDecoration(labelText: 'Product Title'),
//                     ),
//                     const SizedBox(height: 10),
//                     TextField(
//                       controller: _priceController,
//                       decoration: const InputDecoration(labelText: 'Full Price'),
//                       keyboardType: TextInputType.number,
//                     ),
//                     const SizedBox(height: 10),
//                     TextField(
//                       controller: _descriptionController,
//                       decoration: const InputDecoration(labelText: 'Product Description'),
//                       maxLines: 3,
//                     ),
//                     const SizedBox(height: 10),
//                     DropdownButton<String>(
//                       hint: const Text('Select Category'),
//                       value: _selectedCategoryId,
//                       items: _categories.map((category) {
//                         return DropdownMenuItem<String>(
//                           value: category['_id'].toString(),
//                           child: Text(category['name']),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedCategoryId = value;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 10),
//                     if (imageUrl != null)
//                       Column(
//                         children: [
//                           const Text(
//                             'Current Image:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 5),
//                           Container(
//                             width: 100,
//                             height: 100,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8.0),
//                               image: DecorationImage(
//                                 image: NetworkImage(imageUrl),
//                                 fit: BoxFit.cover,
//                                 onError: (exception, stackTrace) {
//                                   print('Error loading product image in edit dialog: $exception, StackTrace: $stackTrace');
//                                 },
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: () async {
//                         try {
//                           if (!kIsWeb && Platform.isAndroid) {
//                             var status = await Permission.storage.status;
//                             if (!status.isGranted) {
//                               status = await Permission.storage.request();
//                               if (!status.isGranted) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(content: Text('Storage permission denied')),
//                                 );
//                                 return;
//                               }
//                             }
//                           }

//                           print('Attempting to open file picker...');
//                           FilePickerResult? result = await FilePicker.platform.pickFiles(
//                             type: FileType.image,
//                             allowMultiple: false,
//                           );
//                           if (result != null && result.files.isNotEmpty) {
//                             setState(() {
//                               _selectedImageFile = result.files.first;
//                               print('Selected file: ${_selectedImageFile?.name} (Path: ${kIsWeb ? "N/A (Web)" : _selectedImageFile?.path ?? "N/A"})');
//                             });
//                           } else {
//                             print('No file selected or operation cancelled');
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('No file selected')),
//                             );
//                           }
//                         } catch (e) {
//                           print('Error picking file: $e');
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Error selecting image: $e')),
//                           );
//                         }
//                       },
//                       child: Text(_selectedImageFile == null ? 'Change Image (Optional)' : 'New Image Selected: ${_selectedImageFile!.name}'),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(dialogContext);
//                   },
//                   child: Text(
//                     'Cancel',
//                     style: GoogleFonts.poppins(color: const Color(0xFFF44336)),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     if (_titleController.text.isNotEmpty &&
//                         _priceController.text.isNotEmpty &&
//                         _descriptionController.text.isNotEmpty &&
//                         _selectedCategoryId != null) {
//                       _updateProduct(
//                         product['_id'].toString(),
//                         _titleController.text,
//                         _priceController.text,
//                         _descriptionController.text,
//                         _selectedCategoryId!,
//                         _selectedImageFile,
//                       );
//                       Navigator.pop(dialogContext);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Please fill all required fields')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     'Update',
//                     style: GoogleFonts.poppins(color: const Color(0xFFF44336)),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }



// adminproduct.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// import 'dart:io' show Platform;

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/products'),
      );
      print('Fetch Products Response: ${response.statusCode} - ${response.body}');
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
          SnackBar(
            content: Text('Failed to load products: ${response.statusCode} - ${response.body}'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
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

  Future<void> _deleteProduct(String productId) async {
    try {
      final url = '$baseUrl/admin/products/$productId';

      print('Deleting product with URL: $url');
      final response = await http.delete(Uri.parse(url));
      print('Delete Product Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _products.removeWhere((p) => p['_id'] == productId);
          _filteredProducts.removeWhere((p) => p['_id'] == productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete product: ${response.statusCode} - ${response.body}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
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
                  onChanged: _filterProducts,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFAB47BC)),
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
                      borderSide: const BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.add, color: Color(0xFFAB47BC)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddProductPage(
                        onProductAdded: () {
                          _fetchProducts(); // Refresh the product list after adding
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
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    final imageUrl = product['image'] != null
                        ? '$baseUrl${product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
                        : null;
                    final firstLetter = product['title']?.toString().substring(0, 1) ?? 'P';
                    return ListTile(
                      leading: imageUrl != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(imageUrl),
                              backgroundColor: _getColorForLetter(firstLetter),
                              onBackgroundImageError: (exception, stackTrace) {
                                print('Error loading product image: $exception');
                              },
                            )
                          : CircleAvatar(
                              backgroundColor: _getColorForLetter(firstLetter),
                              child: Text(
                                firstLetter,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      title: Text(
                        product['title'] ?? 'Unknown Product',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      subtitle: Text(
                        'Price: \$${product['price']?.toString() ?? 'N/A'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Color(0xFFAB47BC),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: Text(
                                    'Are you sure you want to delete the product "${product['title']}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await _deleteProduct(product['_id']);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xFFAB47BC),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProductPage(
                                    product: product,
                                    onProductUpdated: () {
                                      _fetchProducts(); // Refresh the product list after updating
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
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

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onProductUpdated;

  const EditProductPage({super.key, required this.product, required this.onProductUpdated});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  String? _selectedCategoryId;
  PlatformFile? _selectedImageFile;
  List<dynamic> _categories = [];
  bool _isLoading = false;
  final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product['title'] ?? '');
    _priceController = TextEditingController(text: widget.product['price']?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.product['description'] ?? '');
    _selectedCategoryId = widget.product['categoryId']?.toString();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/categories'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final request = http.MultipartRequest(
          'PUT',
          Uri.parse('$baseUrl/admin/products/${widget.product['_id']}'),
        );
        request.fields['title'] = _titleController.text;
        request.fields['price'] = _priceController.text;
        request.fields['description'] = _descriptionController.text;
        request.fields['categoryId'] = _selectedCategoryId!;

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
            setState(() {
              _isLoading = false;
            });
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
        }

        final response = await request.send();
        final responseBody = await http.Response.fromStream(response);
        print('Update Product Response: ${response.statusCode} - ${responseBody.body}');

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully')),
          );
          widget.onProductUpdated();
          Navigator.pop(context); // Go back to ProductsPage
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update product: ${response.statusCode} - ${responseBody.body}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating product: $e')),
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
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.product['image'] != null
        ? '$baseUrl${widget.product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
        : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 129, 48, 143),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                  'Edit Product Details',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (imageUrl != null) ...[
                  const Text(
                    'Current Image:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          print('Error loading product image: $exception');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
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
                        ? 'Change Image (Optional)'
                        : 'New Image Selected: ${_selectedImageFile!.name}',
                    style: GoogleFonts.poppins(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Product Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter product title' : null,
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
                  validator: (value) => value!.isEmpty ? 'Enter price' : null,
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
                  validator: (value) => value!.isEmpty ? 'Enter description' : null,
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
                  validator: (value) => value == null ? 'Select a category' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProduct,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.purple,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
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

class AddProductPage extends StatefulWidget {
  final VoidCallback onProductAdded;

  const AddProductPage({super.key, required this.onProductAdded});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategoryId;
  PlatformFile? _selectedImageFile;
  List<dynamic> _categories = [];
  bool _isLoading = false;
  final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/categories'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate() && _selectedImageFile != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/admin/products'),
        );
        request.fields['title'] = _titleController.text;
        request.fields['price'] = _priceController.text;
        request.fields['description'] = _descriptionController.text;
        request.fields['categoryId'] = _selectedCategoryId!;

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
          setState(() {
            _isLoading = false;
          });
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

        final response = await request.send();
        final responseBody = await http.Response.fromStream(response);
        print('Add Product Response: ${response.statusCode} - ${responseBody.body}');

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')),
          );
          widget.onProductAdded();
          Navigator.pop(context); // Go back to ProductsPage
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add product: ${response.statusCode} - ${responseBody.body}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding product: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 129, 48, 143),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                  'Add New Product',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
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
                        ? 'Select Product Image'
                        : 'Image Selected: ${_selectedImageFile!.name}',
                    style: GoogleFonts.poppins(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Product Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter product title' : null,
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
                  validator: (value) => value!.isEmpty ? 'Enter price' : null,
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
                  validator: (value) => value!.isEmpty ? 'Enter description' : null,
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
                  validator: (value) => value == null ? 'Select a category' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addProduct,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.purple,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
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