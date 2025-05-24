
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'adminuser.dart';
import 'adminproduct.dart';
import 'admincategory.dart';
import 'adminseller.dart';
import 'adminaccount.dart';
import 'adminorders.dart';
import 'adminhome.dart';
import 'adminchangepassword.dart';
import 'auth-service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'baseurl.dart';

class AdminPage extends StatefulWidget {
  final String adminId;
  final String token;

  static const Color primaryColor = Color.fromARGB(255, 62, 62, 147);
  static const Color accentColor = Color(0xFFFFD700);

  const AdminPage({Key? key, required this.adminId, required this.token})
    : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  String _adminName = "Admin User";
  String? _profilePicture;

  @override
  void initState() {
    super.initState();
    _fetchAdminProfile();
  }

  Future<void> _fetchAdminProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      print(
        'Fetch Admin Profile Response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          String firstName = data['firstName']?.toString() ?? '';
          String lastName = data['lastName']?.toString() ?? '';
          _adminName = '$firstName $lastName'.trim();
          if (_adminName.isEmpty) {
            _adminName = 'Admin User';
          }
          _profilePicture = data['profilePicture'];
          print(
            'Updated _adminName: $_adminName, _profilePicture: $_profilePicture',
          );
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please log in again.'),
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        });
      } else if (response.statusCode == 404) {
        print('Admin not found for adminId: ${widget.adminId}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin profile not found. Please log in again.'),
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        });
      } else {
        print('Failed to load admin profile: ${response.body}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load profile: ${response.body}')),
          );
        });
      }
    } catch (e) {
      print('Error fetching admin profile: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching profile: $e')));
      });
    }
  }

  late final List<Widget> _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = [
      const AdminHomePage(),
      const UsersPage(),
      AdminOrdersPage(adminId: widget.adminId),
      const ProductsPage(),
      const AdminCategoryPage(),
      const SellerPage(),
      SetProfilePage(adminId: widget.adminId, token: widget.token),
      const AccountInfo(),
      SoldProductsPage(token: widget.token),
      AdminChangePasswordPage(token: widget.token, adminId: widget.adminId),
    ];
  }

  Future<void> _onItemTapped(int index) async {
    Navigator.pop(context); 

    if (index == 10) {
      print('Logging out');
      ScaffoldMessenger.of(context).clearSnackBars();
      await AuthService.clearAuthData();
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        _selectedIndex = index;
      });
      if (index == 7) {
        await _fetchAdminProfile(); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        backgroundColor: AdminPage.primaryColor, 
        title: Text(
          _selectedIndex == 0
              ? 'Admin Panel'
              : _selectedIndex == 1
              ? 'Users'
              : _selectedIndex == 2
              ? 'Orders'
              : _selectedIndex == 3
              ? 'Products'
              : _selectedIndex == 4
              ? 'Category'
              : _selectedIndex == 5
              ? 'Sellers'
              : _selectedIndex == 6
              ? 'Set Profile'
              : _selectedIndex == 7
              ? 'Account Info'
              : _selectedIndex == 8
              ? 'Sold Products'
              : _selectedIndex == 9
              ? 'Change Password'
              : 'Admin Panel',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _adminName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(
                'Welcome, $_adminName',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
              ),
              currentAccountPicture:
                  _profilePicture != null
                      ? CircleAvatar(
                        backgroundImage: NetworkImage(
                          '$baseUrl$_profilePicture',
                        ),
                        onBackgroundImageError: (exception, stackTrace) {
                          print('Error loading profile picture: $exception');
                        },
                      )
                      : CircleAvatar(
                        backgroundColor:
                            AdminPage.primaryColor, 
                        child: Text(
                          'P',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              decoration: BoxDecoration(
                color: AdminPage.primaryColor, // Use primaryColor
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: AdminPage.primaryColor),
              title: Text('Home', style: GoogleFonts.poppins()),
              selected: _selectedIndex == 0,
              selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.people, color: AdminPage.primaryColor),
              title: Text('Users', style: GoogleFonts.poppins()),
              selected: _selectedIndex == 1,
              selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart, color: AdminPage.primaryColor),
              title: Text('Orders', style: GoogleFonts.poppins()),
              selected: _selectedIndex == 2,
              selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: Icon(Icons.store, color: AdminPage.primaryColor),
              title: Text('Products', style: GoogleFonts.poppins()),
              selected: _selectedIndex == 3,
              selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              leading: Icon(Icons.category, color: AdminPage.primaryColor),
              title: Text('Category', style: GoogleFonts.poppins()),
              selected: _selectedIndex == 4,
              selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
              onTap: () => _onItemTapped(4),
            ),
            ListTile(
              leading: Icon(
                Icons.contact_support,
                color: AdminPage.primaryColor,
              ),
              title: Text('Sellers', style: GoogleFonts.poppins()),
              selected: _selectedIndex == 5,
              selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
              onTap: () => _onItemTapped(5),
            ),
            ListTile(
              leading: Icon(Icons.person, color: AdminPage.primaryColor),
              title: Text('Set Profile', style: GoogleFonts.poppins()),
              selected: _selectedIndex == 6,
              selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
              onTap: () => _onItemTapped(6),
            ),
            ListTile(
              leading: Icon(
                Icons.account_balance,
                color: AdminPage.primaryColor,
              ),
              title: Text('Account Info', style: GoogleFonts.poppins()),
              selected: _selectedIndex == 7,
              selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
              onTap: () => _onItemTapped(7),
            ),
            ListTile(
              leading: Icon(Icons.sell, color: AdminPage.primaryColor),
              title: Text('Sold Products', style: GoogleFonts.poppins()),
              selected: _selectedIndex == 8,
              selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
              onTap: () => _onItemTapped(8),
            ),
            ListTile(
              leading: Icon(Icons.lock, color: AdminPage.primaryColor),
              title: Text('Change Password', style: GoogleFonts.poppins()),
              selected: _selectedIndex == 9,
              selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
              onTap: () => _onItemTapped(9),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: AdminPage.primaryColor),
              title: Text('Log out', style: GoogleFonts.poppins()),
              selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
              onTap: () => _onItemTapped(10),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

class SetProfilePage extends StatefulWidget {
  final String adminId;
  final String token;

  const SetProfilePage({super.key, required this.adminId, required this.token});

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAdminProfile();
  }

  Future<void> _fetchAdminProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      print(
        'Fetch Admin Profile in SetProfilePage: ${response.statusCode} - ${response.body}',
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _firstNameController.text = data['firstName']?.toString() ?? '';
          _lastNameController.text = data['lastName']?.toString() ?? '';
          _emailController.text = data['email']?.toString() ?? '';
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please log in again.'),
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        });
      } else if (response.statusCode == 404) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin profile not found. Please log in again.'),
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load profile: ${response.body}')),
          );
        });
      }
    } catch (e) {
      print('Error fetching admin profile in SetProfilePage: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching profile: $e')));
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final request = http.MultipartRequest(
          'PUT',
          Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
        );
        request.headers['Authorization'] = 'Bearer ${widget.token}';
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
            setState(() {
              _isLoading = false;
            });
            return;
          }

          print('Uploading file with ${bytes.length} bytes');
          request.files.add(
            http.MultipartFile.fromBytes(
              'profilePicture',
              bytes,
              filename: _selectedProfilePicture!.name,
              contentType: MediaType(
                'image',
                _selectedProfilePicture!.extension ?? 'jpeg',
              ),
            ),
          );
        }

        final response = await request.send();
        final responseBody = await http.Response.fromStream(response);
        print(
          'Update Profile Response: ${response.statusCode} - ${responseBody.body}',
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          // Update SharedPreferences with new firstName
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('firstName', _firstNameController.text);
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please log in again.'),
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: ${responseBody.body}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : () async {
                          try {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(
                                  type: FileType.image,
                                  allowMultiple: false,
                                );
                            if (result != null && result.files.isNotEmpty) {
                              setState(() {
                                _selectedProfilePicture = result.files.first;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No file selected'),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error selecting image: $e'),
                              ),
                            );
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                    255,
                    97,
                    97,
                    159,
                  ), // Use primaryColor
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  _selectedProfilePicture == null
                      ? 'Select Profile Picture'
                      : 'Image Selected: ${_selectedProfilePicture!.name}',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: TextStyle(color: AdminPage.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AdminPage.primaryColor),
                  ),
                ),
                validator:
                    (value) => value!.isEmpty ? 'Enter first name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: TextStyle(color: AdminPage.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AdminPage.primaryColor),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Enter last name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: AdminPage.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AdminPage.primaryColor),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AdminPage.primaryColor, // Use primaryColor
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
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
    );
  }
}

class SoldProductsPage extends StatefulWidget {
  final String token;

  const SoldProductsPage({super.key, required this.token});

  @override
  _SoldProductsPageState createState() => _SoldProductsPageState();
}

class _SoldProductsPageState extends State<SoldProductsPage> {
  List<dynamic> soldProductsBySeller = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSoldProducts();
  }

  Future<void> _fetchSoldProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/sold-products'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      print(
        'Fetch Sold Products Response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          soldProductsBySeller = data;
          isLoading = false;
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please log in again.'),
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load sold products: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching sold products: $e');
      setState(() {
        errorMessage = 'Error fetching sold products: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: AdminPage.primaryColor,
                  ),
                )
                : errorMessage != null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchSoldProducts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AdminPage.primaryColor, // Use primaryColor
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Retry',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                : soldProductsBySeller.isEmpty
                ? Center(
                  child: Text(
                    'No sold products found.',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AdminPage.primaryColor,
                    ),
                  ),
                )
                : ListView.builder(
                  itemCount: soldProductsBySeller.length,
                  itemBuilder: (context, index) {
                    final sellerData = soldProductsBySeller[index];
                    final seller = sellerData['seller'];
                    final products = sellerData['products'];
                    final totalPrice = sellerData['totalPrice'].toDouble();
                    final totalAfterFee =
                        sellerData['totalAfterFee'].toDouble();

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ), // Match client pages
                      ),
                      child: ExpansionTile(
                        leading:
                            seller['profilePicture'] != null
                                ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    '$baseUrl${seller['profilePicture']}',
                                  ),
                                  onBackgroundImageError: (
                                    exception,
                                    stackTrace,
                                  ) {
                                    print(
                                      'Error loading seller profile picture: $exception',
                                    );
                                  },
                                )
                                : CircleAvatar(
                                  backgroundColor:
                                      AdminPage
                                          .primaryColor, // Use primaryColor
                                  child: Text(
                                    seller['name'][0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                        title: Text(
                          seller['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AdminPage.primaryColor,
                          ),
                        ),
                        subtitle: Text(
                          'Total: ETB ${totalPrice.toStringAsFixed(2)} | After 5% Fee: ETB ${totalAfterFee.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        children:
                            products.map<Widget>((product) {
                              return ListTile(
                                leading:
                                    product['image'] != null
                                        ? Image.network(
                                          '$baseUrl${product['image']}',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                  ),
                                        )
                                        : const Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                        ),
                                title: Text(
                                  product['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: AdminPage.primaryColor,
                                  ),
                                ),
                                subtitle: Text(
                                  'Price: ETB ${product['price'].toStringAsFixed(2)} x ${product['quantity']} = ETB ${product['totalItemPrice'].toStringAsFixed(2)}\nOrder ID: ${product['orderId']}\nDate: ${product['orderDate'].substring(0, 10)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}


