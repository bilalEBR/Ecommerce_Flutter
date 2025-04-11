
// adminpage.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'adminuser.dart'; // Import the real UsersPage
import 'adminproduct.dart'; // Add this import at the top
import 'admincategory.dart';
import 'adminseller.dart';
class AdminPage extends StatefulWidget {
  final String adminId;

  const AdminPage({super.key, required this.adminId});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  String _adminName = "Admin User";
  String? _profilePicture;
  final String baseUrl = 'http://localhost:3000';

  @override
  void initState() {
    super.initState();
    _fetchAdminProfile();
  }

  Future<void> _fetchAdminProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
      );
      print('Fetch Admin Profile Response: ${response.statusCode} - ${response.body}');

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
          print('Updated _adminName: $_adminName, _profilePicture: $_profilePicture');
        });
      } else if (response.statusCode == 404) {
        print('Admin not found for adminId: ${widget.adminId}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin profile not found. Please log in again.')),
          );
          Navigator.pushReplacementNamed(context, '/login');
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching profile: $e')),
        );
      });
    }
  }

  late final List<Widget> _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = [
      const HomePage(),
      const UsersPage(), // Use the real UsersPage from adminuser.dart
      const OrdersPage(),
      const ReviewsPage(),
      const ProductsPage(),
      // const ProductsPage(),
      const AdminCategoryPage(),
      const SellerPage(),
      SetProfilePage(adminId: widget.adminId),
    ];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == 7 && index != 7) {
      _fetchAdminProfile();
    }

    if (index == 8) {
      print('Logging out');
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        _selectedIndex = index;
      });
      Navigator.pop(context);
    }
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Admin Panel';
      case 1:
        return 'Users';
      case 2:
        return 'Orders';
      case 3:
        return 'Reviews';
      case 4:
        return 'Products';
      case 5:
        return 'Category';
      case 6:
        return 'Sellers';
      case 7:
        return 'Set Profile';
      default:
        return 'Admin Panel';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 129, 48, 143),
        title: Text(
          _getAppBarTitle(),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFFAB47BC),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  _adminName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  'Welcome, $_adminName',
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
                    : const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 212, 3, 249),
                        child: Text(
                          'P',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 91, 2, 104),
                ),
              ),
              _buildDrawerItem(
                icon: Icons.home,
                title: 'Home',
                onTap: () => _onItemTapped(0),
                isSelected: _selectedIndex == 0,
              ),
              _buildDrawerItem(
                icon: Icons.people,
                title: 'Users',
                onTap: () => _onItemTapped(1),
                isSelected: _selectedIndex == 1,
              ),
              _buildDrawerItem(
                icon: Icons.shopping_cart,
                title: 'Orders',
                onTap: () => _onItemTapped(2),
                isSelected: _selectedIndex == 2,
              ),
              _buildDrawerItem(
                icon: Icons.comment,
                title: 'Reviews',
                onTap: () => _onItemTapped(3),
                isSelected: _selectedIndex == 3,
              ),
              _buildDrawerItem(
                icon: Icons.store,
                title: 'Products',
                onTap: () => _onItemTapped(4),
                isSelected: _selectedIndex == 4,
              ),
              _buildDrawerItem(
                icon: Icons.category,
                title: 'Category',
                onTap: () => _onItemTapped(5),
                isSelected: _selectedIndex == 5,
              ),
              _buildDrawerItem(
                icon: Icons.contact_support,
                title: 'Contact Us',
                onTap: () => _onItemTapped(6),
                isSelected: _selectedIndex == 6,
              ),
              _buildDrawerItem(
                icon: Icons.person,
                title: 'Set Profile',
                onTap: () => _onItemTapped(7),
                isSelected: _selectedIndex == 7,
              ),
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Log out',
                onTap: () => _onItemTapped(8),
                isSelected: false,
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.yellow : Colors.white,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: isSelected ? Colors.yellow : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      tileColor: isSelected ? Colors.white12 : null,
    );
  }
}

// SetProfilePage
class SetProfilePage extends StatefulWidget {
  final String adminId;

  const SetProfilePage({super.key, required this.adminId});

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
  final String baseUrl = 'http://localhost:3000';
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
      );
      print('Fetch Admin Profile in SetProfilePage: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _firstNameController.text = data['firstName']?.toString() ?? '';
          _lastNameController.text = data['lastName']?.toString() ?? '';
          _emailController.text = data['email']?.toString() ?? '';
        });
      } else if (response.statusCode == 404) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin profile not found. Please log in again.')),
          );
          Navigator.pushReplacementNamed(context, '/login');
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching profile: $e')),
        );
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
              contentType: MediaType('image', _selectedProfilePicture!.extension ?? 'jpeg'),
            ),
          );
        }

        final response = await request.send();
        final responseBody = await http.Response.fromStream(response);
        print('Update Profile Response: ${response.statusCode} - ${responseBody.body}');

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: ${responseBody.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
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
              Text(
                'Set Profile',
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
                  onPressed: _isLoading ? null : _updateProfile,
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

// Home Page (Charts)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Users',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFAB47BC),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(fontSize: 12);
                        switch (value.toInt()) {
                          case 0:
                            return const Text('9/2023', style: style);
                          case 1:
                            return const Text('10/2023', style: style);
                          case 2:
                            return const Text('11/2023', style: style);
                          case 3:
                            return const Text('12/2023', style: style);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 3,
                minY: 0,
                maxY: 60,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 20),
                      FlSpot(1, 50),
                      FlSpot(2, 40),
                      FlSpot(3, 10),
                    ],
                    isCurved: false,
                    color: const Color(0xFF8A4B3A),
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        if (index == 1) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: Colors.yellow,
                            strokeWidth: 0,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF8A4B3A),
                          strokeWidth: 0,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Total Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFAB47BC),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(fontSize: 12);
                        switch (value.toInt()) {
                          case 0:
                            return const Text('9/2023', style: style);
                          case 1:
                            return const Text('10/2023', style: style);
                          case 2:
                            return const Text('11/2023', style: style);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 8,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: 2,
                        color: const Color(0xFF8A4B3A),
                        width: 20,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: 6,
                        color: const Color(0xFF8A4B3A),
                        width: 20,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: 3,
                        color: const Color(0xFF8A4B3A),
                        width: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Total Orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFAB47BC),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(fontSize: 12);
                        switch (value.toInt()) {
                          case 0:
                            return const Text('9/2023', style: style);
                          case 1:
                            return const Text('10/2023', style: style);
                          case 2:
                            return const Text('11/2023', style: style);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 8,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: 1,
                        color: const Color(0xFF8A4B3A),
                        width: 20,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: 4,
                        color: const Color(0xFF8A4B3A),
                        width: 20,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: 2,
                        color: const Color(0xFF8A4B3A),
                        width: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder Pages
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Orders Page - Under Development',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Reviews Page - Under Development',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// class ProductsPage extends StatelessWidget {
//   const ProductsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Products Page - Under Development',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Category Page - Under Development',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Contact Us Page - Under Development',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}




