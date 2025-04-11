// // admincategory.dart
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'dart:io' show Platform;

// class AdminCategoryPage extends StatefulWidget {
//   const AdminCategoryPage({super.key});

//   @override
//   _AdminCategoryPageState createState() => _AdminCategoryPageState();
// }

// class _AdminCategoryPageState extends State<AdminCategoryPage> {
//   List<dynamic> _categories = [];
//   List<dynamic> _filteredCategories = [];
//   bool _isLoading = true;

//   String _searchQuery = '';
  
//   final String baseUrl = kIsWeb
//       ? 'http://localhost:3000'
//       : 'http://192.168.1.100:3000'; // Replace with your machine's IP for mobile

//   @override
//   void initState() {
//     super.initState();
//     _fetchCategories();
//   }

//   Future<void> _fetchCategories() async {
//     setState(() => _isLoading = true);
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/categories'),
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print('Fetched categories: $data');
//         setState(() {
//           _categories = data;
//           _filteredCategories = data;
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load categories: ${response.statusCode} - ${response.body}')),
//         );
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching categories: $e')),
//       );
//     }
//   }

//   Future<void> _deleteCategory(String categoryId) async {
//     try {
//       final url = '$baseUrl/admin/categories/$categoryId';
//       final response = await http.delete(Uri.parse(url));
//       if (response.statusCode == 200) {
//         setState(() {
//           _categories.removeWhere((c) => c['_id'] == categoryId);
//           _filteredCategories.removeWhere((c) => c['_id'] == categoryId);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Category deleted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete category: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting category: $e')),
//       );
//     }
//   }

//   Future<void> _addCategory(String name, PlatformFile? imageFile) async {
//     if (imageFile == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an image')),
//       );
//       return;
//     }

//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/admin/categories'),
//       );
//       request.fields['name'] = name;

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
//         await _fetchCategories();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Category added successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to add category: ${responseBody.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error in _addCategory: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error adding category: $e')),
//       );
//     }
//   }

//   Future<void> _updateCategory(String categoryId, String name, PlatformFile? imageFile) async {
//     try {
//       final request = http.MultipartRequest(
//         'PUT',
//         Uri.parse('$baseUrl/admin/categories/$categoryId'),
//       );
//       request.fields['name'] = name;

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
//         await _fetchCategories();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Category updated successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to update category: ${responseBody.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error in _updateCategory: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error updating category: $e')),
//       );
//     }
//   }

//   void _filterCategories(String query) {
//     setState(() {
//       _searchQuery = query;
//       _filteredCategories = _categories.where((category) {
//         final name = category['name']?.toString().toLowerCase() ?? '';
//         final searchLower = query.toLowerCase();
//         return name.contains(searchLower);
//       }).toList();
//     });
//   }

//   // Add confirmation dialog for deleting a category
//   void _showDeleteConfirmationDialog(BuildContext context, String categoryId, String categoryName) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: Text(
//             'Delete Category',
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFFF44336),
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete the category "$categoryName"?',
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
//                 _deleteCategory(categoryId);
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
//               'Categories (${_filteredCategories.length})',
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
//                 _showAddCategoryDialog(context);
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               onChanged: _filterCategories,
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.search, color: Color(0xFFAB47BC)),
//                 hintText: 'Search by category name',
//                 hintStyle: const TextStyle(color: Colors.grey),
//                 filled: true,
//                 fillColor: const Color(0xFFE0E0E0),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.green, width: 2),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//                     itemCount: _filteredCategories.length,
//                     itemBuilder: (context, index) {
//                       final category = _filteredCategories[index];
//                       final firstLetter = category['name']?.toString().substring(0, 1) ?? 'C';
//                       final imageUrl = category['image'] != null
//                           ? '$baseUrl${category['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
//                           : null;
//                       print('Attempting to load image: $imageUrl');
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
//                             leading: CircleAvatar(
//                               radius: 30,
//                               backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
//                               backgroundColor: imageUrl == null ? _getColorForLetter(firstLetter) : null,
//                               child: imageUrl == null
//                                   ? Text(
//                                       firstLetter,
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 20,
//                                       ),
//                                     )
//                                   : null,
//                             ),
//                             title: Text(
//                               category['name'] ?? 'Unknown Category',
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
//                                     _showEditCategoryDialog(context, category);
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete, color: Color(0xFFAB47BC)),
//                                   onPressed: () {
//                                     _showDeleteConfirmationDialog(
//                                       context,
//                                       category['_id'].toString(),
//                                       category['name'] ?? 'Unknown Category',
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

//   void _showAddCategoryDialog(BuildContext context) {
//     final _nameController = TextEditingController();
//     PlatformFile? _imageFile;

//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (dialogContext, setState) {
//             return AlertDialog(
//               title: Text(
//                 'Add New Category',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFFF44336),
//                 ),
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: _nameController,
//                     decoration: const InputDecoration(labelText: 'Category Name'),
//                   ),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () async {
//                       try {
//                         if (!kIsWeb && Platform.isAndroid) {
//                           var status = await Permission.storage.status;
//                           if (!status.isGranted) {
//                             status = await Permission.storage.request();
//                             if (!status.isGranted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('Storage permission denied')),
//                               );
//                               return;
//                             }
//                           }
//                         }

//                         print('Attempting to open file picker...');
//                         FilePickerResult? result = await FilePicker.platform.pickFiles(
//                           type: FileType.image,
//                           allowMultiple: false,
//                         );
//                         if (result != null && result.files.isNotEmpty) {
//                           setState(() {
//                             _imageFile = result.files.first;
//                             print('Selected file: ${_imageFile?.name} (Path: ${kIsWeb ? "N/A (Web)" : _imageFile?.path ?? "N/A"})');
//                           });
//                         } else {
//                           print('No file selected or operation cancelled');
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('No file selected')),
//                           );
//                         }
//                       } catch (e) {
//                         print('Error picking file: $e');
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Error selecting image: $e')),
//                         );
//                       }
//                     },
//                     child: Text(_imageFile == null ? 'Select Image' : 'Image Selected: ${_imageFile!.name}'),
//                   ),
//                 ],
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
//                     if (_nameController.text.isNotEmpty && _imageFile != null) {
//                       _addCategory(_nameController.text, _imageFile);
//                       Navigator.pop(dialogContext);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Please fill the name field and select an image')),
//                       );
//                     }
//                   },
//                   child: Text(
//                     'Add',
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

//   void _showEditCategoryDialog(BuildContext context, Map<String, dynamic> category) {
//     final _nameController = TextEditingController(text: category['name']);
//     PlatformFile? _imageFile;

//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (dialogContext, setState) {
//             final imageUrl = category['image'] != null
//                 ? '$baseUrl${category['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
//                 : null;
//             print('Edit dialog image URL: $imageUrl');
//             return AlertDialog(
//               title: Text(
//                 'Edit Category',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFFF44336),
//                 ),
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: _nameController,
//                     decoration: const InputDecoration(labelText: 'Category Name'),
//                   ),
//                   const SizedBox(height: 10),
//                   if (imageUrl != null)
//                     Column(
//                       children: [
//                         const Text(
//                           'Current Image:',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 5),
//                         Image.network(
//                           imageUrl,
//                           height: 100,
//                           width: 100,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             print('Error loading image in edit dialog: $error, StackTrace: $stackTrace');
//                             return const Text(
//                               'Image failed to load',
//                               style: TextStyle(color: Colors.grey),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () async {
//                       try {
//                         if (!kIsWeb && Platform.isAndroid) {
//                           var status = await Permission.storage.status;
//                           if (!status.isGranted) {
//                             status = await Permission.storage.request();
//                             if (!status.isGranted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('Storage permission denied')),
//                               );
//                               return;
//                             }
//                           }
//                         }

//                         print('Attempting to open file picker...');
//                         FilePickerResult? result = await FilePicker.platform.pickFiles(
//                           type: FileType.image,
//                           allowMultiple: false,
//                         );
//                         if (result != null && result.files.isNotEmpty) {
//                           setState(() {
//                             _imageFile = result.files.first;
//                             print('Selected file: ${_imageFile?.name} (Path: ${kIsWeb ? "N/A (Web)" : _imageFile?.path ?? "N/A"})');
//                           });
//                         } else {
//                           print('No file selected or operation cancelled');
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('No file selected')),
//                           );
//                         }
//                       } catch (e) {
//                         print('Error picking file: $e');
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Error selecting image: $e')),
//                         );
//                       }
//                     },
//                     child: Text(_imageFile == null ? 'Change Image (Optional)' : 'New Image Selected: ${_imageFile!.name}'),
//                   ),
//                 ],
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
//                     if (_nameController.text.isNotEmpty) {
//                       _updateCategory(category['_id'], _nameController.text, _imageFile);
//                       Navigator.pop(dialogContext);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Please fill the name field')),
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

// admincategory.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class AdminCategoryPage extends StatefulWidget {
  const AdminCategoryPage({super.key});

  @override
  _AdminCategoryPageState createState() => _AdminCategoryPageState();
}

class _AdminCategoryPageState extends State<AdminCategoryPage> {
  List<dynamic> _categories = [];
  List<dynamic> _filteredCategories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/categories'),
      );
      print('Fetch Categories Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _categories = data;
          _filteredCategories = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load categories: ${response.statusCode} - ${response.body}'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching categories: $e')),
      );
    }
  }

  void _filterCategories(String query) {
    setState(() {
      _searchQuery = query;
      _filteredCategories = _categories.where((category) {
        final name = category['name']?.toString().toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return name.contains(searchLower);
      }).toList();
    });
  }

  Future<void> _deleteCategory(String categoryId) async {
    try {
      print('Attempting to delete category with ID: $categoryId');
      final url = '$baseUrl/admin/categories/$categoryId';
      print('DELETE request URL: $url');
      final response = await http.delete(Uri.parse(url));
      print('Delete Category Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _categories.removeWhere((c) => c['_id'] == categoryId);
          _filteredCategories.removeWhere((c) => c['_id'] == categoryId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete category: ${response.statusCode} - ${response.body}'),
          ),
        );
      }
    } catch (e) {
      print('Exception during DELETE request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting category: $e')),
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
                  onChanged: _filterCategories,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFAB47BC)),
                    hintText: 'Search by category name',
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
                      builder: (context) => AddCategoryPage(
                        onCategoryAdded: () {
                          _fetchCategories(); // Refresh the category list after adding
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
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = _filteredCategories[index];
                    final imageUrl = category['image'] != null
                        ? '$baseUrl${category['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
                        : null;
                    final firstLetter = category['name']?.toString().substring(0, 1) ?? 'C';
                    return ListTile(
                      leading: imageUrl != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(imageUrl),
                              backgroundColor: _getColorForLetter(firstLetter),
                              onBackgroundImageError: (exception, stackTrace) {
                                print('Error loading category image: $exception');
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
                        category['name'] ?? 'Unknown Category',
                        style: GoogleFonts.poppins(fontSize: 16),
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
                                    'Are you sure you want to delete the category "${category['name']}"?',
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
                                await _deleteCategory(category['_id']);
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
                                  builder: (context) => EditCategoryPage(
                                    category: category,
                                    onCategoryUpdated: () {
                                      _fetchCategories(); // Refresh the category list after updating
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

class EditCategoryPage extends StatefulWidget {
  final Map<String, dynamic> category;
  final VoidCallback onCategoryUpdated;

  const EditCategoryPage({super.key, required this.category, required this.onCategoryUpdated});

  @override
  _EditCategoryPageState createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  PlatformFile? _selectedImageFile;
  bool _isLoading = false;
  final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category['name'] ?? '');
  }

  Future<void> _updateCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        print('Updating category with ID: ${widget.category['_id']}');
        print('Request data: name=${_nameController.text}');

        final request = http.MultipartRequest(
          'PUT',
          Uri.parse('$baseUrl/admin/categories/${widget.category['_id']}'),
        );
        request.fields['name'] = _nameController.text;

        if (_selectedImageFile != null) {
          print('Uploading new image: ${_selectedImageFile!.name}');
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
        } else {
          print('No new image selected for upload');
        }

        final response = await request.send();
        final responseBody = await http.Response.fromStream(response);
        print('Update Category Response: ${response.statusCode} - ${responseBody.body}');

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category updated successfully')),
          );
          widget.onCategoryUpdated();
          Navigator.pop(context); // Go back to AdminCategoryPage
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update category: ${response.statusCode} - ${responseBody.body}'),
            ),
          );
        }
      } catch (e) {
        print('Exception during PUT request: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating category: $e')),
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
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.category['image'] != null
        ? '$baseUrl${widget.category['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
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
          'Edit Category',
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
                  'Edit Category Details',
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
                          print('Error loading category image: $exception');
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
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter category name' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateCategory,
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
                            'Update Category',
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

class AddCategoryPage extends StatefulWidget {
  final VoidCallback onCategoryAdded;

  const AddCategoryPage({super.key, required this.onCategoryAdded});

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  PlatformFile? _selectedImageFile;
  bool _isLoading = false;
  final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';

  Future<void> _addCategory() async {
    if (_formKey.currentState!.validate() && _selectedImageFile != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/admin/categories'),
        );
        request.fields['name'] = _nameController.text;

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
        print('Add Category Response: ${response.statusCode} - ${responseBody.body}');

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category added successfully')),
          );
          widget.onCategoryAdded();
          Navigator.pop(context); // Go back to AdminCategoryPage
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add category: ${response.statusCode} - ${responseBody.body}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding category: $e')),
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
    _nameController.dispose();
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
          'Add Category',
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
                  'Add New Category',
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
                        ? 'Select Category Image'
                        : 'Image Selected: ${_selectedImageFile!.name}',
                    style: GoogleFonts.poppins(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter category name' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addCategory,
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
                            'Add Category',
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