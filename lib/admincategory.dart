
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'baseurl.dart';

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

  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

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
      
      final url = '$baseUrl/admin/categories/$categoryId';
      final response = await http.delete(Uri.parse(url));

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
                    prefixIcon: Icon(Icons.search, color: primaryColor),
                    hintText: 'Search by category name',
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
              ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = _filteredCategories[index];
                    final imageUrl = category['image'] != null
                        ? '$baseUrl${category['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
                        : null;
                    final firstLetter = category['name']?.toString().substring(0, 1) ?? 'C';
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
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                        title: Text(
                          category['name'] ?? 'Unknown Category',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
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
                                      'Are you sure you want to delete the category "${category['name']}"?',
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
                                  await _deleteCategory(category['_id']);
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: primaryColor),
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

  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

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

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category updated successfully')),
          );
          widget.onCategoryUpdated();
          Navigator.pop(context); 
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
        backgroundColor: primaryColor,
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
                
                const SizedBox(height: 16),
                if (imageUrl != null) ...[
                  Text(
                    'Current Image:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
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
                SizedBox(
                  
                  child: ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 3,
                      shadowColor: Colors.grey.withOpacity(0.5),
                    ),
                    child: Text(
                      _selectedImageFile == null
                          ? 'Change Image (Optional)'
                          : 'New Image Selected: ${_selectedImageFile!.name}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
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
                  validator: (value) => value!.isEmpty ? 'Enter category name' : null,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateCategory,
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
                            'Update Category',
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

  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

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
        backgroundColor: primaryColor,
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
                
                const SizedBox(height: 16),
                SizedBox(
                  // width: double.infinity,
                  child: ElevatedButton(
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
                      _selectedImageFile == null
                          ? 'Select Category Image'
                          : 'Image Selected: ${_selectedImageFile!.name}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
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
                  validator: (value) => value!.isEmpty ? 'Enter category name' : null,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addCategory,
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
                            'Add Category',
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