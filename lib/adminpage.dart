

// // new version including external file of account info 

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'adminuser.dart';
// import 'adminproduct.dart';
// import 'admincategory.dart';
// import 'adminseller.dart';
// import 'adminaccount.dart';

// class AdminPage extends StatefulWidget {
//   final String adminId;

//   const AdminPage({super.key, required this.adminId});

//   @override
//   _AdminPageState createState() => _AdminPageState();
// }

// class _AdminPageState extends State<AdminPage> {
//   int _selectedIndex = 0;
//   String _adminName = "Admin User";
//   String? _profilePicture;
//   final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchAdminProfile();
//   }

//   Future<void> _fetchAdminProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//       );
//       print('Fetch Admin Profile Response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           String firstName = data['firstName']?.toString() ?? '';
//           String lastName = data['lastName']?.toString() ?? '';
//           _adminName = '$firstName $lastName'.trim();
//           if (_adminName.isEmpty) {
//             _adminName = 'Admin User';
//           }
//           _profilePicture = data['profilePicture'];
//           print('Updated _adminName: $_adminName, _profilePicture: $_profilePicture');
//         });
//       } else if (response.statusCode == 404) {
//         print('Admin not found for adminId: ${widget.adminId}');
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Admin profile not found. Please log in again.')),
//           );
//           Navigator.pushReplacementNamed(context, '/login');
//         });
//       } else {
//         print('Failed to load admin profile: ${response.body}');
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to load profile: ${response.body}')),
//           );
//         });
//       }
//     } catch (e) {
//       print('Error fetching admin profile: $e');
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching profile: $e')),
//         );
//       });
//     }
//   }

//   late final List<Widget> _pages;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _pages = [
//       const HomePage(),
//       const UsersPage(),
//       const OrdersPage(),
//       const ReviewsPage(),
//       const ProductsPage(),
//       const AdminCategoryPage(),
//       const SellerPage(),
//       SetProfilePage(adminId: widget.adminId),
//       const AccountInfo(),
//     ];
//   }

//   void _onItemTapped(int index) {
//     if (_selectedIndex == 7 && index != 7) {
//       _fetchAdminProfile();
//     }

//     if (index == 9) {
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
//       appBar: _selectedIndex == 8
//           ? null // Let AccountInfo handle its own AppBar
//           : AppBar(
//               backgroundColor: Colors.purple,
//               title: Text(
//                 _selectedIndex == 0
//                     ? 'Admin Panel'
//                     : _selectedIndex == 1
//                         ? 'Users'
//                         : _selectedIndex == 2
//                             ? 'Orders'
//                             : _selectedIndex == 3
//                                 ? 'Reviews'
//                                 : _selectedIndex == 4
//                                     ? 'Products'
//                                     : _selectedIndex == 5
//                                         ? 'Category'
//                                         : _selectedIndex == 6
//                                             ? 'Sellers'
//                                             : _selectedIndex == 7
//                                                 ? 'Set Profile'
//                                                 : 'Admin Panel',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserAccountsDrawerHeader(
//               accountName: Text(
//                 _adminName,
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               accountEmail: Text(
//                 'Welcome, $_adminName',
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
//                   : const CircleAvatar(
//                       backgroundColor: Color.fromARGB(255, 212, 3, 249),
//                       child: Text(
//                         'P',
//                         style: TextStyle(
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
//               leading: const Icon(Icons.home),
//               title: Text(
//                 'Home',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 0,
//               onTap: () => _onItemTapped(0),
//             ),
//             ListTile(
//               leading: const Icon(Icons.people),
//               title: Text(
//                 'Users',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 1,
//               onTap: () => _onItemTapped(1),
//             ),
//             ListTile(
//               leading: const Icon(Icons.shopping_cart),
//               title: Text(
//                 'Orders',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 2,
//               onTap: () => _onItemTapped(2),
//             ),
//             ListTile(
//               leading: const Icon(Icons.comment),
//               title: Text(
//                 'Reviews',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 3,
//               onTap: () => _onItemTapped(3),
//             ),
//             ListTile(
//               leading: const Icon(Icons.store),
//               title: Text(
//                 'Products',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 4,
//               onTap: () => _onItemTapped(4),
//             ),
//             ListTile(
//               leading: const Icon(Icons.category),
//               title: Text(
//                 'Category',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 5,
//               onTap: () => _onItemTapped(5),
//             ),
//             ListTile(
//               leading: const Icon(Icons.contact_support),
//               title: Text(
//                 'Sellers',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 6,
//               onTap: () => _onItemTapped(6),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: Text(
//                 'Set Profile',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 7,
//               onTap: () => _onItemTapped(7),
//             ),
//             ListTile(
//               leading: const Icon(Icons.account_balance),
//               title: Text(
//                 'Account Info',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 8,
//               onTap: () => _onItemTapped(8),
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: Text(
//                 'Log out',
//                 style: GoogleFonts.poppins(),
//               ),
//               onTap: () => _onItemTapped(9),
//             ),
//           ],
//         ),
//       ),
//       body: _pages[_selectedIndex],
//     );
//   }
// }

// // SetProfilePage
// class SetProfilePage extends StatefulWidget {
//   final String adminId;

//   const SetProfilePage({super.key, required this.adminId});

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
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAdminProfile();
//   }

//   Future<void> _fetchAdminProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//       );
//       print('Fetch Admin Profile in SetProfilePage: ${response.statusCode} - ${response.body}');
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _firstNameController.text = data['firstName']?.toString() ?? '';
//           _lastNameController.text = data['lastName']?.toString() ?? '';
//           _emailController.text = data['email']?.toString() ?? '';
//         });
//       } else if (response.statusCode == 404) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Admin profile not found. Please log in again.')),
//           );
//           Navigator.pushReplacementNamed(context, '/login');
//         });
//       } else {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to load profile: ${response.body}')),
//           );
//         });
//       }
//     } catch (e) {
//       print('Error fetching admin profile in SetProfilePage: $e');
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching profile: $e')),
//         );
//       });
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//         );
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
//             setState(() {
//               _isLoading = false;
//             });
//             return;
//           }

//           print('Uploading file with ${bytes.length} bytes');
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
//         print('Update Profile Response: ${response.statusCode} - ${responseBody.body}');

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Profile updated successfully')),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to update profile: ${responseBody.body}')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating profile: $e')),
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
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Set Profile',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _isLoading
//                     ? null
//                     : () async {
//                         try {
//                           FilePickerResult? result = await FilePicker.platform.pickFiles(
//                             type: FileType.image,
//                             allowMultiple: false,
//                           );
//                           if (result != null && result.files.isNotEmpty) {
//                             setState(() {
//                               _selectedProfilePicture = result.files.first;
//                             });
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('No file selected')),
//                             );
//                           }
//                         } catch (e) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Error selecting image: $e')),
//                           );
//                         }
//                       },
//                 child: Text(
//                   _selectedProfilePicture == null
//                       ? 'Select Profile Picture'
//                       : 'Image Selected: ${_selectedProfilePicture!.name}',
//                   style: GoogleFonts.poppins(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _firstNameController,
//                 decoration: InputDecoration(
//                   labelText: 'First Name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter first name' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _lastNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Last Name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter last name' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter email' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   suffixIcon: TextButton(
//                     onPressed: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Change Password feature coming soon')),
//                       );
//                     },
//                     child: const Text('Change Password'),
//                   ),
//                 ),
//                 obscureText: true,
//                 enabled: false,
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _updateProfile,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     backgroundColor: Colors.purple,
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Text(
//                           'Update Profile',
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Home Page (Charts)
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Total Users',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFFAB47BC),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             height: 200,
//             child: LineChart(
//               LineChartData(
//                 gridData: const FlGridData(show: false),
//                 titlesData: FlTitlesData(
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 30,
//                       getTitlesWidget: (value, meta) {
//                         const style = TextStyle(fontSize: 12);
//                         switch (value.toInt()) {
//                           case 0:
//                             return const Text('9/2023', style: style);
//                           case 1:
//                             return const Text('10/2023', style: style);
//                           case 2:
//                             return const Text('11/2023', style: style);
//                           case 3:
//                             return const Text('12/2023', style: style);
//                         }
//                         return const Text('');
//                       },
//                     ),
//                   ),
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 40,
//                       getTitlesWidget: (value, meta) => Text(
//                         value.toInt().toString(),
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   ),
//                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 minX: 0,
//                 maxX: 3,
//                 minY: 0,
//                 maxY: 60,
//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: const [
//                       FlSpot(0, 20),
//                       FlSpot(1, 50),
//                       FlSpot(2, 40),
//                       FlSpot(3, 10),
//                     ],
//                     isCurved: false,
//                     color: const Color(0xFF8A4B3A),
//                     dotData: FlDotData(
//                       getDotPainter: (spot, percent, barData, index) {
//                         if (index == 1) {
//                           return FlDotCirclePainter(
//                             radius: 6,
//                             color: Colors.yellow,
//                             strokeWidth: 0,
//                           );
//                         }
//                         return FlDotCirclePainter(
//                           radius: 4,
//                           color: const Color(0xFF8A4B3A),
//                           strokeWidth: 0,
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'Total Products',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFFAB47BC),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             height: 200,
//             child: BarChart(
//               BarChartData(
//                 gridData: const FlGridData(show: false),
//                 titlesData: FlTitlesData(
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 30,
//                       getTitlesWidget: (value, meta) {
//                         const style = TextStyle(fontSize: 12);
//                         switch (value.toInt()) {
//                           case 0:
//                             return const Text('9/2023', style: style);
//                           case 1:
//                             return const Text('10/2023', style: style);
//                           case 2:
//                             return const Text('11/2023', style: style);
//                         }
//                         return const Text('');
//                       },
//                     ),
//                   ),
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 40,
//                       getTitlesWidget: (value, meta) => Text(
//                         value.toInt().toString(),
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   ),
//                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 minY: 0,
//                 maxY: 8,
//                 barGroups: [
//                   BarChartGroupData(
//                     x: 0,
//                     barRods: [
//                       BarChartRodData(
//                         toY: 2,
//                         color: const Color(0xFF8A4B3A),
//                         width: 20,
//                       ),
//                     ],
//                   ),
//                   BarChartGroupData(
//                     x: 1,
//                     barRods: [
//                       BarChartRodData(
//                         toY: 6,
//                         color: const Color(0xFF8A4B3A),
//                         width: 20,
//                       ),
//                     ],
//                   ),
//                   BarChartGroupData(
//                     x: 2,
//                     barRods: [
//                       BarChartRodData(
//                         toY: 3,
//                         color: const Color(0xFF8A4B3A),
//                         width: 20,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'Total Orders',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFFAB47BC),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             height: 200,
//             child: BarChart(
//               BarChartData(
//                 gridData: const FlGridData(show: false),
//                 titlesData: FlTitlesData(
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 30,
//                       getTitlesWidget: (value, meta) {
//                         const style = TextStyle(fontSize: 12);
//                         switch (value.toInt()) {
//                           case 0:
//                             return const Text('9/2023', style: style);
//                           case 1:
//                             return const Text('10/2023', style: style);
//                           case 2:
//                             return const Text('11/2023', style: style);
//                         }
//                         return const Text('');
//                       },
//                     ),
//                   ),
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 40,
//                       getTitlesWidget: (value, meta) => Text(
//                         value.toInt().toString(),
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   ),
//                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 minY: 0,
//                 maxY: 8,
//                 barGroups: [
//                   BarChartGroupData(
//                     x: 0,
//                     barRods: [
//                       BarChartRodData(
//                         toY: 1,
//                         color: const Color(0xFF8A4B3A),
//                         width: 20,
//                       ),
//                     ],
//                   ),
//                   BarChartGroupData(
//                     x: 1,
//                     barRods: [
//                       BarChartRodData(
//                         toY: 4,
//                         color: const Color(0xFF8A4B3A),
//                         width: 20,
//                       ),
//                     ],
//                   ),
//                   BarChartGroupData(
//                     x: 2,
//                     barRods: [
//                       BarChartRodData(
//                         toY: 2,
//                         color: const Color(0xFF8A4B3A),
//                         width: 20,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
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

// class ReviewsPage extends StatelessWidget {
//   const ReviewsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Reviews Page - Under Development',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

// class CategoryPage extends StatelessWidget {
//   const CategoryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Category Page - Under Development',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }


// new version to add admin orders page 

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'adminuser.dart';
// import 'adminproduct.dart';
// import 'admincategory.dart';
// import 'adminseller.dart';
// import 'adminaccount.dart';
// import 'adminorders.dart'; // Added import

// class AdminPage extends StatefulWidget {
//   final String adminId;

//   const AdminPage({super.key, required this.adminId});

//   @override
//   _AdminPageState createState() => _AdminPageState();
// }

// class _AdminPageState extends State<AdminPage> {
//   int _selectedIndex = 0;
//   String _adminName = "Admin User";
//   String? _profilePicture;
//   final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchAdminProfile();
//   }

//   Future<void> _fetchAdminProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//       );
//       print('Fetch Admin Profile Response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           String firstName = data['firstName']?.toString() ?? '';
//           String lastName = data['lastName']?.toString() ?? '';
//           _adminName = '$firstName $lastName'.trim();
//           if (_adminName.isEmpty) {
//             _adminName = 'Admin User';
//           }
//           _profilePicture = data['profilePicture'];
//           print('Updated _adminName: $_adminName, _profilePicture: $_profilePicture');
//         });
//       } else if (response.statusCode == 404) {
//         print('Admin not found for adminId: ${widget.adminId}');
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Admin profile not found. Please log in again.')),
//           );
//           Navigator.pushReplacementNamed(context, '/login');
//         });
//       } else {
//         print('Failed to load admin profile: ${response.body}');
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to load profile: ${response.body}')),
//           );
//         });
//       }
//     } catch (e) {
//       print('Error fetching admin profile: $e');
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching profile: $e')),
//         );
//       });
//     }
//   }

//   late final List<Widget> _pages;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _pages = [
//       const HomePage(),
//       const UsersPage(),
//       AdminOrdersPage(adminId: widget.adminId), // Updated to use AdminOrdersPage
//       const ReviewsPage(),
//       const ProductsPage(),
//       const AdminCategoryPage(),
//       const SellerPage(),
//       SetProfilePage(adminId: widget.adminId),
//       const AccountInfo(),
//     ];
//   }

//   void _onItemTapped(int index) {
//     if (_selectedIndex == 7 && index != 7) {
//       _fetchAdminProfile();
//     }

//     if (index == 9) {
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
//       appBar: _selectedIndex == 8
//           ? null // Let AccountInfo handle its own AppBar
//           : AppBar(
//               backgroundColor: Colors.purple,
//               title: Text(
//                 _selectedIndex == 0
//                     ? 'Admin Panel'
//                     : _selectedIndex == 1
//                         ? 'Users'
//                         : _selectedIndex == 2
//                             ? 'Orders'
//                             : _selectedIndex == 3
//                                 ? 'Reviews'
//                                 : _selectedIndex == 4
//                                     ? 'Products'
//                                     : _selectedIndex == 5
//                                         ? 'Category'
//                                         : _selectedIndex == 6
//                                             ? 'Sellers'
//                                             : _selectedIndex == 7
//                                                 ? 'Set Profile'
//                                                 : 'Admin Panel',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserAccountsDrawerHeader(
//               accountName: Text(
//                 _adminName,
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               accountEmail: Text(
//                 'Welcome, $_adminName',
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
//                   : const CircleAvatar(
//                       backgroundColor: Color.fromARGB(255, 212, 3, 249),
//                       child: Text(
//                         'P',
//                         style: TextStyle(
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
//               leading: const Icon(Icons.home),
//               title: Text(
//                 'Home',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 0,
//               onTap: () => _onItemTapped(0),
//             ),
//             ListTile(
//               leading: const Icon(Icons.people),
//               title: Text(
//                 'Users',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 1,
//               onTap: () => _onItemTapped(1),
//             ),
//             ListTile(
//               leading: const Icon(Icons.shopping_cart),
//               title: Text(
//                 'Orders',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 2,
//               onTap: () => _onItemTapped(2),
//             ),
//             ListTile(
//               leading: const Icon(Icons.comment),
//               title: Text(
//                 'Reviews',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 3,
//               onTap: () => _onItemTapped(3),
//             ),
//             ListTile(
//               leading: const Icon(Icons.store),
//               title: Text(
//                 'Products',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 4,
//               onTap: () => _onItemTapped(4),
//             ),
//             ListTile(
//               leading: const Icon(Icons.category),
//               title: Text(
//                 'Category',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 5,
//               onTap: () => _onItemTapped(5),
//             ),
//             ListTile(
//               leading: const Icon(Icons.contact_support),
//               title: Text(
//                 'Sellers',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 6,
//               onTap: () => _onItemTapped(6),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: Text(
//                 'Set Profile',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 7,
//               onTap: () => _onItemTapped(7),
//             ),
//             ListTile(
//               leading: const Icon(Icons.account_balance),
//               title: Text(
//                 'Account Info',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 8,
//               onTap: () => _onItemTapped(8),
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: Text(
//                 'Log out',
//                 style: GoogleFonts.poppins(),
//               ),
//               onTap: () => _onItemTapped(9),
//             ),
//           ],
//         ),
//       ),
//       body: _pages[_selectedIndex],
//     );
//   }
// }

// // SetProfilePage
// class SetProfilePage extends StatefulWidget {
//   final String adminId;

//   const SetProfilePage({super.key, required this.adminId});

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
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAdminProfile();
//   }

//   Future<void> _fetchAdminProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//       );
//       print('Fetch Admin Profile in SetProfilePage: ${response.statusCode} - ${response.body}');
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _firstNameController.text = data['firstName']?.toString() ?? '';
//           _lastNameController.text = data['lastName']?.toString() ?? '';
//           _emailController.text = data['email']?.toString() ?? '';
//         });
//       } else if (response.statusCode == 404) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Admin profile not found. Please log in again.')),
//           );
//           Navigator.pushReplacementNamed(context, '/login');
//         });
//       } else {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to load profile: ${response.body}')),
//           );
//         });
//       }
//     } catch (e) {
//       print('Error fetching admin profile in SetProfilePage: $e');
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching profile: $e')),
//         );
//       });
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//         );
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
//             setState(() {
//               _isLoading = false;
//             });
//             return;
//           }

//           print('Uploading file with ${bytes.length} bytes');
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
//         print('Update Profile Response: ${response.statusCode} - ${responseBody.body}');

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Profile updated successfully')),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to update profile: ${responseBody.body}')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating profile: $e')),
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
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Set Profile',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _isLoading
//                     ? null
//                     : () async {
//                         try {
//                           FilePickerResult? result = await FilePicker.platform.pickFiles(
//                             type: FileType.image,
//                             allowMultiple: false,
//                           );
//                           if (result != null && result.files.isNotEmpty) {
//                             setState(() {
//                               _selectedProfilePicture = result.files.first;
//                             });
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('No file selected')),
//                             );
//                           }
//                         } catch (e) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Error selecting image: $e')),
//                           );
//                         }
//                       },
//                 child: Text(
//                   _selectedProfilePicture == null
//                       ? 'Select Profile Picture'
//                       : 'Image Selected: ${_selectedProfilePicture!.name}',
//                   style: GoogleFonts.poppins(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _firstNameController,
//                 decoration: InputDecoration(
//                   labelText: 'First Name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter first name' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _lastNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Last Name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter last name' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter email' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   suffixIcon: TextButton(
//                     onPressed: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Change Password feature coming soon')),
//                       );
//                     },
//                     child: const Text('Change Password'),
//                   ),
//                 ),
//                 obscureText: true,
//                 enabled: false,
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _updateProfile,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     backgroundColor: Colors.purple,
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Text(
//                           'Update Profile',
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Home Page (Charts)
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Total Users',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFFAB47BC),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             height: 200,
//             child: LineChart(
//               LineChartData(
//                 gridData: const FlGridData(show: false),
//                 titlesData: FlTitlesData(
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 30,
//                       getTitlesWidget: (value, meta) {
//                         const style = TextStyle(fontSize: 12);
//                         switch (value.toInt()) {
//                           case 0:
//                             return const Text('9/2023', style: style);
//                           case 1:
//                             return const Text('10/2023', style: style);
//                           case 2:
//                             return const Text('11/2023', style: style);
//                           case 3:
//                             return const Text('12/2023', style: style);
//                         }
//                         return const Text('');
//                       },
//                     ),
//                   ),
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 40,
//                       getTitlesWidget: (value, meta) => Text(
//                         value.toInt().toString(),
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   ),
//                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 minX: 0,
//                 maxX: 3,
//                 minY: 0,
//                 maxY: 60,
//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: const [
//                       FlSpot(0, 20),
//                       FlSpot(1, 50),
//                       FlSpot(2, 40),
//                       FlSpot(3, 10),
//                     ],
//                     isCurved: false,
//                     color: const Color(0xFF8A4B3A),
//                     dotData: FlDotData(
//                       getDotPainter: (spot, percent, barData, index) {
//                         if (index == 1) {
//                           return FlDotCirclePainter(
//                             radius: 6,
//                             color: Colors.yellow,
//                             strokeWidth: 0,
//                           );
//                         }
//                         return FlDotCirclePainter(
//                           radius: 4,
//                           color: const Color(0xFF8A4B3A),
//                           strokeWidth: 0,
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'Total Products',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFFAB47BC),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             height: 200,
//             child: BarChart(
//               BarChartData(
//                 gridData: const FlGridData(show: false),
//                 titlesData: FlTitlesData(
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 30,
//                       getTitlesWidget: (value, meta) {
//                         const style = TextStyle(fontSize: 12);
//                         switch (value.toInt()) {
//                           case 0:
//                             return const Text('9/2023', style: style);
//                           case 1:
//                             return const Text('10/2023', style: style);
//                           case 2:
//                             return const Text('11/2023', style: style);
//                         }
//                         return const Text('');
//                       },
//                     ),
//                   ),
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 40,
//                       getTitlesWidget: (value, meta) => Text(
//                         value.toInt().toString(),
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   ),
//                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 minY: 0,
//                 maxY: 8,
//                 barGroups: [
//                   BarChartGroupData(
//                     x: 0,
//                     barRods: [
//                       BarChartRodData(
//                         toY: 2,
//                         color: const Color(0xFF8A4B3A),
//                         width: 20,
//                       ),
//                     ],
//                   ),
//                   BarChartGroupData(
//                     x: 1,
//                     barRods: [
//                       BarChartRodData(
//                         toY: 6,
//                         color: const Color(0xFF8A4B3A),
//                         width: 20,
//                       ),
//                     ],
//                   ),
//                   BarChartGroupData(
//                     x: 2,
//                     barRods: [
//                       BarChartRodData(
//                         toY: 3,
//                         color: const Color(0xFF8A4B3A),
//                         width: 20,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'Total Orders',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFFAB47BC),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             height: 200,
//             child: BarChart(
//               BarChartData(
//                 gridData: const FlGridData(show: false),
//                 titlesData: FlTitlesData(
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 30,
//                       getTitlesWidget: (value, meta) {
//                         const style = TextStyle(fontSize: 12);
//                         switch (value.toInt()) {
//                           case 0:
//                             return const Text('9/2023', style: style);
//                           case 1:
//                             return const Text('10/2023', style: style);
//                           case 2:
//                             return const Text('11/2023', style: style);
//                         }
//                         return const Text('');
//                       },
//                     ),
//                   ),
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 40,
//                       getTitlesWidget: (value, meta) => Text(
//                         value.toInt().toString(),
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   ),
//                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 minY: 0,
//                 maxY: 8,
//                 barGroups: [
//                   BarChartGroupData(
//                     x: 0,
//                     barRods: [
//                       BarChartRodData(
//                         toY: 1,
//                         color: const Color(0xFF8A4B3A),
//                         width: 20,
//                       ),
//                     ],
//                   ),
//                   BarChartGroupData(
//                     x: 1,
//                     barRods: [
//                       BarChartRodData(
//                         toY: 4,
//                         color: const Color(0xFF8A4B3A),
//                         width: 20,
//                       ),
//                     ],
//                   ),
//                   BarChartGroupData(
//                     x: 2,
//                     barRods: [
//                       BarChartRodData(
//                         toY: 2,
//                         color: const Color(0xFF8A4B3A),
//                         width: 20,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ReviewsPage extends StatelessWidget {
//   const ReviewsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Reviews Page - Under Development',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

// class CategoryPage extends StatelessWidget {
//   const CategoryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Category Page - Under Development',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

// new version to parting homeclass lonely

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// // import 'package:fl_chart/fl_chart.dart';
// import 'adminuser.dart';
// import 'adminproduct.dart';
// import 'admincategory.dart';
// import 'adminseller.dart';
// import 'adminaccount.dart';
// import 'adminorders.dart';
// import 'adminhome.dart'; // Added import for AdminHomePage
// import 'adminchangepassword.dart';

// // class AdminPage extends StatefulWidget {
// //   final String adminId;

// //   const AdminPage({super.key, required this.adminId});

// //   @override
// //   _AdminPageState createState() => _AdminPageState();
// // }

// class AdminPage extends StatefulWidget {
//   final String adminId;
//   final String token;

//   const AdminPage({
//     Key? key,
//     required this.adminId,
//     required this.token,
//   }) : super(key: key);

//   @override
//   _AdminPageState createState() => _AdminPageState();
// }


// class _AdminPageState extends State<AdminPage> {
//   int _selectedIndex = 0;
//   String _adminName = "Admin User";
//   String? _profilePicture;
//   final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchAdminProfile();
//   }

//   Future<void> _fetchAdminProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//       );
//       print('Fetch Admin Profile Response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           String firstName = data['firstName']?.toString() ?? '';
//           String lastName = data['lastName']?.toString() ?? '';
//           _adminName = '$firstName $lastName'.trim();
//           if (_adminName.isEmpty) {
//             _adminName = 'Admin User';
//           }
//           _profilePicture = data['profilePicture'];
//           print('Updated _adminName: $_adminName, _profilePicture: $_profilePicture');
//         });
//       } else if (response.statusCode == 404) {
//         print('Admin not found for adminId: ${widget.adminId}');
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Admin profile not found. Please log in again.')),
//           );
//           Navigator.pushReplacementNamed(context, '/login');
//         });
//       } else {
//         print('Failed to load admin profile: ${response.body}');
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to load profile: ${response.body}')),
//           );
//         });
//       }
//     } catch (e) {
//       print('Error fetching admin profile: $e');
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching profile: $e')),
//         );
//       });
//     }
//   }

//   late final List<Widget> _pages;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _pages = [
//       const AdminHomePage(), // Updated to use AdminHomePage
//       const UsersPage(),
//       AdminOrdersPage(adminId: widget.adminId),
//        AdminChangePasswordPage(
//       token: widget.token, // Passing token to AdminChangePasswordPage
//       adminId: widget.adminId, // Passing adminId to AdminChangePasswordPage
//     ),
//       const ProductsPage(),
//       const AdminCategoryPage(),
//       const SellerPage(),
//       SetProfilePage(adminId: widget.adminId),
//       const AccountInfo(),
//     ];
//   }

//   void _onItemTapped(int index) {
//     if (_selectedIndex == 7 && index != 7) {
//       _fetchAdminProfile();
//     }

//     if (index == 9) {
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
//       appBar: _selectedIndex == 8
//           ? null // Let AccountInfo handle its own AppBar
//           : AppBar(
//               backgroundColor: Colors.purple,
//               title: Text(
//                 _selectedIndex == 0
//                     ? 'Admin Panel'
//                     : _selectedIndex == 1
//                         ? 'Users'
//                         : _selectedIndex == 2
//                             ? 'Orders'
//                             : _selectedIndex == 3
//                                 ? 'change password'
//                                 : _selectedIndex == 4
//                                     ? 'Products'
//                                     : _selectedIndex == 5
//                                         ? 'Category'
//                                         : _selectedIndex == 6
//                                             ? 'Sellers'
//                                             : _selectedIndex == 7
//                                                 ? 'Set Profile'
//                                                 : 'Admin Panel',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: const Color.fromARGB(255, 255, 255, 255),
//                 ),
//               ),
//             ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserAccountsDrawerHeader(
//               accountName: Text(
//                 _adminName,
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               accountEmail: Text(
//                 'Welcome, $_adminName',
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
//                   : const CircleAvatar(
//                       backgroundColor: Color.fromARGB(255, 212, 3, 249),
//                       child: Text(
//                         'P',
//                         style: TextStyle(
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
//               leading: const Icon(Icons.home),
//               title: Text(
//                 'Home',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 0,
//               onTap: () => _onItemTapped(0),
//             ),
//             ListTile(
//               leading: const Icon(Icons.people),
//               title: Text(
//                 'Users',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 1,
//               onTap: () => _onItemTapped(1),
//             ),
//             ListTile(
//               leading: const Icon(Icons.shopping_cart),
//               title: Text(
//                 'Orders',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 2,
//               onTap: () => _onItemTapped(2),
//             ),
//             ListTile(
//               leading: const Icon(Icons.comment),
//               title: Text(
//                 'change password',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 3,
//               onTap: () => _onItemTapped(3),
//             ),
//             ListTile(
//               leading: const Icon(Icons.store),
//               title: Text(
//                 'Products',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 4,
//               onTap: () => _onItemTapped(4),
//             ),
//             ListTile(
//               leading: const Icon(Icons.category),
//               title: Text(
//                 'Category',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 5,
//               onTap: () => _onItemTapped(5),
//             ),
//             ListTile(
//               leading: const Icon(Icons.contact_support),
//               title: Text(
//                 'Sellers',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 6,
//               onTap: () => _onItemTapped(6),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: Text(
//                 'Set Profile',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 7,
//               onTap: () => _onItemTapped(7),
//             ),
//             ListTile(
//               leading: const Icon(Icons.account_balance),
//               title: Text(
//                 'Account Info',
//                 style: GoogleFonts.poppins(),
//               ),
//               selected: _selectedIndex == 8,
//               onTap: () => _onItemTapped(8),
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: Text(
//                 'Log out',
//                 style: GoogleFonts.poppins(),
//               ),
//               onTap: () => _onItemTapped(9),
//             ),
//           ],
//         ),
//       ),
//       body: _pages[_selectedIndex],
//     );
//   }
// }

// // SetProfilePage
// class SetProfilePage extends StatefulWidget {
//   final String adminId;

//   const SetProfilePage({super.key, required this.adminId});

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
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAdminProfile();
//   }

//   Future<void> _fetchAdminProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//       );
//       print('Fetch Admin Profile in SetProfilePage: ${response.statusCode} - ${response.body}');
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _firstNameController.text = data['firstName']?.toString() ?? '';
//           _lastNameController.text = data['lastName']?.toString() ?? '';
//           _emailController.text = data['email']?.toString() ?? '';
//         });
//       } else if (response.statusCode == 404) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Admin profile not found. Please log in again.')),
//           );
//           Navigator.pushReplacementNamed(context, '/login');
//         });
//       } else {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to load profile: ${response.body}')),
//           );
//         });
//       }
//     } catch (e) {
//       print('Error fetching admin profile in SetProfilePage: $e');
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching profile: $e')),
//         );
//       });
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//         );
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
//             setState(() {
//               _isLoading = false;
//             });
//             return;
//           }

//           print('Uploading file with ${bytes.length} bytes');
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
//         print('Update Profile Response: ${response.statusCode} - ${responseBody.body}');

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Profile updated successfully')),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to update profile: ${responseBody.body}')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating profile: $e')),
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
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Set Profile',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _isLoading
//                     ? null
//                     : () async {
//                         try {
//                           FilePickerResult? result = await FilePicker.platform.pickFiles(
//                             type: FileType.image,
//                             allowMultiple: false,
//                           );
//                           if (result != null && result.files.isNotEmpty) {
//                             setState(() {
//                               _selectedProfilePicture = result.files.first;
//                             });
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('No file selected')),
//                             );
//                           }
//                         } catch (e) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Error selecting image: $e')),
//                           );
//                         }
//                       },
//                 child: Text(
//                   _selectedProfilePicture == null
//                       ? 'Select Profile Picture'
//                       : 'Image Selected: ${_selectedProfilePicture!.name}',
//                   style: GoogleFonts.poppins(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _firstNameController,
//                 decoration: InputDecoration(
//                   labelText: 'First Name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter first name' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _lastNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Last Name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter last name' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter email' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   suffixIcon: TextButton(
//                     onPressed: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Change Password feature coming soon')),
//                       );
//                     },
//                     child: const Text('Change Password'),
//                   ),
//                 ),
//                 obscureText: true,
//                 enabled: false,
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _updateProfile,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     backgroundColor: Colors.purple,
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Text(
//                           'Update Profile',
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // class ReviewsPage extends StatelessWidget {
// //   const ReviewsPage({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Text(
// //         'Reviews Page - Under Development',
// //         style: GoogleFonts.poppins(
// //           fontSize: 20,
// //           fontWeight: FontWeight.bold,
// //         ),
// //       ),
// //     );
// //   }
// // }

// class CategoryPage extends StatelessWidget {
//   const CategoryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Category Page - Under Development',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

// version to ADD sold products 


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'adminuser.dart';
// import 'adminproduct.dart';
// import 'admincategory.dart';
// import 'adminseller.dart';
// import 'adminaccount.dart';
// import 'adminorders.dart';
// import 'adminhome.dart';
// import 'adminchangepassword.dart';
// import 'auth-service.dart';

// class AdminPage extends StatefulWidget {
//   final String adminId;
//   final String token;

//   const AdminPage({
//     Key? key,
//     required this.adminId,
//     required this.token,
//   }) : super(key: key);

//   @override
//   _AdminPageState createState() => _AdminPageState();
// }

// class _AdminPageState extends State<AdminPage> {
//   int _selectedIndex = 0;
//   String _adminName = "Admin User";
//   String? _profilePicture;
//   final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchAdminProfile();
//   }

//   Future<void> _fetchAdminProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//       );
//       print('Fetch Admin Profile Response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           String firstName = data['firstName']?.toString() ?? '';
//           String lastName = data['lastName']?.toString() ?? '';
//           _adminName = '$firstName $lastName'.trim();
//           if (_adminName.isEmpty) {
//             _adminName = 'Admin User';
//           }
//           _profilePicture = data['profilePicture'];
//           print('Updated _adminName: $_adminName, _profilePicture: $_profilePicture');
//         });
//       } else if (response.statusCode == 404) {
//         print('Admin not found for adminId: ${widget.adminId}');
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Admin profile not found. Please log in again.')),
//           );
//           Navigator.pushReplacementNamed(context, '/login');
//         });
//       } else {
//         print('Failed to load admin profile: ${response.body}');
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to load profile: ${response.body}')),
//           );
//         });
//       }
//     } catch (e) {
//       print('Error fetching admin profile: $e');
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching profile: $e')),
//         );
//       });
//     }
//   }

//   late final List<Widget> _pages;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _pages = [
//       const AdminHomePage(),
//       const UsersPage(),
//       AdminOrdersPage(adminId: widget.adminId),
//       AdminChangePasswordPage(token: widget.token, adminId: widget.adminId),
//       const ProductsPage(),
//       const AdminCategoryPage(),
//       const SellerPage(),
//       SetProfilePage(adminId: widget.adminId),
//       const AccountInfo(),
//       const SoldProductsPage(),
//     ];
//   }

//   void _onItemTapped(int index) {
//     if (_selectedIndex == 7 && index != 7) {
//       _fetchAdminProfile();
//     }

//     if (index == 10) {
//       print('Logging out');
//       Navigator.pushReplacementNamed(context, '/login');
//     }

//   //  else if (index == 10) { // Logout

//   //   // try {
//   //   //   await AuthService.logout(context); // Now this will work
//   //   // } catch (e) {
//   //   //   debugPrint('Logout error: $e');
//   //   //   ScaffoldMessenger.of(context).showSnackBar(
//   //   //     SnackBar(content: Text('Logout failed. Please try again.'))
//   //   //   );
//   //   // }
//   //  }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _selectedIndex == 8
//           ? null
//           : AppBar(
//               backgroundColor: Colors.purple,
//               title: Text(
//                 _selectedIndex == 0
//                     ? 'Admin Panel'
//                     : _selectedIndex == 1
//                         ? 'Users'
//                         : _selectedIndex == 2
//                             ? 'Orders'
//                             : _selectedIndex == 3
//                                 ? 'Change Password'
//                                 : _selectedIndex == 4
//                                     ? 'Products'
//                                     : _selectedIndex == 5
//                                         ? 'Category'
//                                         : _selectedIndex == 6
//                                             ? 'Sellers'
//                                             : _selectedIndex == 7
//                                                 ? 'Set Profile'
//                                                 : _selectedIndex == 8
//                                                     ? 'Account Info'
//                                                     : _selectedIndex == 9
//                                                         ? 'Sold Products'
//                                                         : 'Admin Panel',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserAccountsDrawerHeader(
//               accountName: Text(
//                 _adminName,
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               accountEmail: Text(
//                 'Welcome, $_adminName',
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
//                   : const CircleAvatar(
//                       backgroundColor: Colors.purple,
//                       child: Text(
//                         'P',
//                         style: TextStyle(
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
//               leading: const Icon(Icons.home),
//               title: Text('Home', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 0,
//               onTap: () => _onItemTapped(0),
//             ),
//             ListTile(
//               leading: const Icon(Icons.people),
//               title: Text('Users', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 1,
//               onTap: () => _onItemTapped(1),
//             ),
//             ListTile(
//               leading: const Icon(Icons.shopping_cart),
//               title: Text('Orders', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 2,
//               onTap: () => _onItemTapped(2),
//             ),
//             ListTile(
//               leading: const Icon(Icons.lock),
//               title: Text('Change Password', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 3,
//               onTap: () => _onItemTapped(3),
//             ),
//             ListTile(
//               leading: const Icon(Icons.store),
//               title: Text('Products', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 4,
//               onTap: () => _onItemTapped(4),
//             ),
//             ListTile(
//               leading: const Icon(Icons.category),
//               title: Text('Category', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 5,
//               onTap: () => _onItemTapped(5),
//             ),
//             ListTile(
//               leading: const Icon(Icons.contact_support),
//               title: Text('Sellers', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 6,
//               onTap: () => _onItemTapped(6),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: Text('Set Profile', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 7,
//               onTap: () => _onItemTapped(7),
//             ),
//             ListTile(
//               leading: const Icon(Icons.account_balance),
//               title: Text('Account Info', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 8,
//               onTap: () => _onItemTapped(8),
//             ),
//             ListTile(
//               leading: const Icon(Icons.sell),
//               title: Text('Sold Products', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 9,
//               onTap: () => _onItemTapped(9),
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: Text('Log out', style: GoogleFonts.poppins()),
//               onTap: () => _onItemTapped(10),
//             ),
//           ],
//         ),
//       ),
//       body: _pages[_selectedIndex],
//     );
//   }
// }

// class SetProfilePage extends StatefulWidget {
//   final String adminId;

//   const SetProfilePage({super.key, required this.adminId});

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
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAdminProfile();
//   }

//   Future<void> _fetchAdminProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//       );
//       print('Fetch Admin Profile in SetProfilePage: ${response.statusCode} - ${response.body}');
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _firstNameController.text = data['firstName']?.toString() ?? '';
//           _lastNameController.text = data['lastName']?.toString() ?? '';
//           _emailController.text = data['email']?.toString() ?? '';
//         });
//       } else if (response.statusCode == 404) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Admin profile not found. Please log in again.')),
//           );
//           Navigator.pushReplacementNamed(context, '/login');
//         });
//       } else {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to load profile: ${response.body}')),
//           );
//         });
//       }
//     } catch (e) {
//       print('Error fetching admin profile in SetProfilePage: $e');
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching profile: $e')),
//         );
//       });
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//         );
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
//             setState(() {
//               _isLoading = false;
//             });
//             return;
//           }

//           print('Uploading file with ${bytes.length} bytes');
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
//         print('Update Profile Response: ${response.statusCode} - ${responseBody.body}');

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Profile updated successfully')),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to update profile: ${responseBody.body}')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating profile: $e')),
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
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Set Profile',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _isLoading
//                     ? null
//                     : () async {
//                         try {
//                           FilePickerResult? result = await FilePicker.platform.pickFiles(
//                             type: FileType.image,
//                             allowMultiple: false,
//                           );
//                           if (result != null && result.files.isNotEmpty) {
//                             setState(() {
//                               _selectedProfilePicture = result.files.first;
//                             });
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('No file selected')),
//                             );
//                           }
//                         } catch (e) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Error selecting image: $e')),
//                           );
//                         }
//                       },
//                 child: Text(
//                   _selectedProfilePicture == null
//                       ? 'Select Profile Picture'
//                       : 'Image Selected: ${_selectedProfilePicture!.name}',
//                   style: GoogleFonts.poppins(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _firstNameController,
//                 decoration: InputDecoration(
//                   labelText: 'First Name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter first name' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _lastNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Last Name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter last name' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter email' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   suffixIcon: TextButton(
//                     onPressed: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Change Password feature coming soon')),
//                       );
//                     },
//                     child: const Text('Change Password'),
//                   ),
//                 ),
//                 obscureText: true,
//                 enabled: false,
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _updateProfile,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     backgroundColor: Colors.purple,
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Text(
//                           'Update Profile',
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SoldProductsPage extends StatefulWidget {
//   const SoldProductsPage({super.key});

//   @override
//   _SoldProductsPageState createState() => _SoldProductsPageState();
// }

// class _SoldProductsPageState extends State<SoldProductsPage> {
//   final String baseUrl = 'http://localhost:3000';
//   List<dynamic> soldProductsBySeller = [];
//   bool isLoading = true;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSoldProducts();
//   }

//   Future<void> _fetchSoldProducts() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/sold-products'),
//       );
//       print('Fetch Sold Products Response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           soldProductsBySeller = data;
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Failed to load sold products: ${response.body}';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error fetching sold products: $e');
//       setState(() {
//         errorMessage = 'Error fetching sold products: $e';
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : errorMessage != null
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           errorMessage!,
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             color: Colors.red,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: _fetchSoldProducts,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.purple,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: Text(
//                             'Retry',
//                             style: GoogleFonts.poppins(
//                               fontSize: 16,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : soldProductsBySeller.isEmpty
//                     ? Center(
//                         child: Text(
//                           'No sold products found.',
//                           style: GoogleFonts.poppins(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       )
//                     : ListView.builder(
//                         itemCount: soldProductsBySeller.length,
//                         itemBuilder: (context, index) {
//                           final sellerData = soldProductsBySeller[index];
//                           final seller = sellerData['seller'];
//                           final products = sellerData['products'];
//                           final totalPrice = sellerData['totalPrice'].toDouble();
//                           final totalAfterFee = sellerData['totalAfterFee'].toDouble();

//                           return Card(
//                             elevation: 4,
//                             margin: const EdgeInsets.symmetric(vertical: 8),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: ExpansionTile(
//                               leading: seller['profilePicture'] != null
//                                   ? CircleAvatar(
//                                       backgroundImage: NetworkImage('$baseUrl${seller['profilePicture']}'),
//                                       onBackgroundImageError: (exception, stackTrace) {
//                                         print('Error loading seller profile picture: $exception');
//                                       },
//                                     )
//                                   : CircleAvatar(
//                                       backgroundColor: Colors.purple,
//                                       child: Text(
//                                         seller['name'][0].toUpperCase(),
//                                         style: const TextStyle(color: Colors.white),
//                                       ),
//                                     ),
//                               title: Text(
//                                 seller['name'],
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               subtitle: Text(
//                                 'Total: ETB ${totalPrice.toStringAsFixed(2)} | After 5% Fee: ETB ${totalAfterFee.toStringAsFixed(2)}',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                               children: products.map<Widget>((product) {
//                                 return ListTile(
//                                   leading: product['image'] != null
//                                       ? Image.network(
//                                           '$baseUrl${product['image']}',
//                                           width: 50,
//                                           height: 50,
//                                           fit: BoxFit.cover,
//                                           errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
//                                         )
//                                       : const Icon(Icons.image_not_supported, size: 50),
//                                   title: Text(
//                                     product['name'],
//                                     style: GoogleFonts.poppins(fontSize: 16),
//                                   ),
//                                   subtitle: Text(
//                                     'Price: ETB ${product['price'].toStringAsFixed(2)} x ${product['quantity']} = ETB ${product['totalItemPrice'].toStringAsFixed(2)}\nOrder ID: ${product['orderId']}\nDate: ${product['orderDate'].substring(0, 10)}',
//                                     style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           );
//                         },
//                       ),
//       ),
//     );
//   }
// }

// class CategoryPage extends StatelessWidget {
//   const CategoryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Category Page - Under Development',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

// version last

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'adminuser.dart';
// import 'adminproduct.dart';
// import 'admincategory.dart';
// import 'adminseller.dart';
// import 'adminaccount.dart';
// import 'adminorders.dart';
// import 'adminhome.dart';
// import 'adminchangepassword.dart';
// // import 'auth-service.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AdminPage extends StatefulWidget {
//   final String adminId;
//   final String token;

//   const AdminPage({
//     Key? key,
//     required this.adminId,
//     required this.token,
//   }) : super(key: key);

//   @override
//   _AdminPageState createState() => _AdminPageState();
// }

// class _AdminPageState extends State<AdminPage> {
//   int _selectedIndex = 0;
//   String _adminName = "Admin User";
//   String? _profilePicture;
//   final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchAdminProfile();
//   }

//   Future<void> _fetchAdminProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//         headers: {'Authorization': 'Bearer ${widget.token}'},
//       );
//       print('Fetch Admin Profile Response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           String firstName = data['firstName']?.toString() ?? '';
//           String lastName = data['lastName']?.toString() ?? '';
//           _adminName = '$firstName $lastName'.trim();
//           if (_adminName.isEmpty) {
//             _adminName = 'Admin User';
//           }
//           _profilePicture = data['profilePicture'];
//           print('Updated _adminName: $_adminName, _profilePicture: $_profilePicture');
//         });
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Session expired. Please log in again.')),
//           );
//           Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//         });
//       } else if (response.statusCode == 404) {
//         print('Admin not found for adminId: ${widget.adminId}');
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Admin profile not found. Please log in again.')),
//           );
//           Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//         });
//       } else {
//         print('Failed to load admin profile: ${response.body}');
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to load profile: ${response.body}')),
//           );
//         });
//       }
//     } catch (e) {
//       print('Error fetching admin profile: $e');
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching profile: $e')),
//         );
//       });
//     }
//   }

//   late final List<Widget> _pages;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _pages = [
//       const AdminHomePage(),
//       const UsersPage(),
//       AdminOrdersPage(adminId: widget.adminId),
//       AdminChangePasswordPage(token: widget.token, adminId: widget.adminId),
//       const ProductsPage(),
//       const AdminCategoryPage(),
//       const SellerPage(),
//       SetProfilePage(adminId: widget.adminId, token: widget.token),
//       const AccountInfo(),
//       SoldProductsPage(token: widget.token),
//     ];
//   }

//   Future<void> _onItemTapped(int index) async {
//     Navigator.pop(context); // Close the drawer
//     setState(() {
//       _selectedIndex = index;
//     });

//     if (_selectedIndex == 7) {
//       await _fetchAdminProfile(); // Refresh profile when navigating to Set Profile
//     }

//     if (index == 10) {
//       print('Logging out');
//       // ScaffoldMessenger.of(context).clearSnackBars(); // Clear any existing snackbars
//       // await AuthService.clearAuthData(); // Clear auth data
//       Navigator.pushReplacementNamed(context, '/login'); // Navigate to login
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _selectedIndex == 8
//           ? null
//           : AppBar(
//               backgroundColor: Colors.purple,
//               title: Text(
//                 _selectedIndex == 0
//                     ? 'Admin Panel'
//                     : _selectedIndex == 1
//                         ? 'Users'
//                         : _selectedIndex == 2
//                             ? 'Orders'
//                             : _selectedIndex == 3
//                                 ? 'Change Password'
//                                 : _selectedIndex == 4
//                                     ? 'Products'
//                                     : _selectedIndex == 5
//                                         ? 'Category'
//                                         : _selectedIndex == 6
//                                             ? 'Sellers'
//                                             : _selectedIndex == 7
//                                                 ? 'Set Profile'
//                                                 : _selectedIndex == 8
//                                                     ? 'Account Info'
//                                                     : _selectedIndex == 9
//                                                         ? 'Sold Products'
//                                                         : 'Admin Panel',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserAccountsDrawerHeader(
//               accountName: Text(
//                 _adminName,
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               accountEmail: Text(
//                 'Welcome, $_adminName',
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
//                   : const CircleAvatar(
//                       backgroundColor: Colors.purple,
//                       child: Text(
//                         'P',
//                         style: TextStyle(
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
//               leading: const Icon(Icons.home),
//               title: Text('Home', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 0,
//               onTap: () => _onItemTapped(0),
//             ),
//             ListTile(
//               leading: const Icon(Icons.people),
//               title: Text('Users', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 1,
//               onTap: () => _onItemTapped(1),
//             ),
//             ListTile(
//               leading: const Icon(Icons.shopping_cart),
//               title: Text('Orders', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 2,
//               onTap: () => _onItemTapped(2),
//             ),
//             ListTile(
//               leading: const Icon(Icons.lock),
//               title: Text('Change Password', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 3,
//               onTap: () => _onItemTapped(3),
//             ),
//             ListTile(
//               leading: const Icon(Icons.store),
//               title: Text('Products', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 4,
//               onTap: () => _onItemTapped(4),
//             ),
//             ListTile(
//               leading: const Icon(Icons.category),
//               title: Text('Category', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 5,
//               onTap: () => _onItemTapped(5),
//             ),
//             ListTile(
//               leading: const Icon(Icons.contact_support),
//               title: Text('Sellers', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 6,
//               onTap: () => _onItemTapped(6),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: Text('Set Profile', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 7,
//               onTap: () => _onItemTapped(7),
//             ),
//             ListTile(
//               leading: const Icon(Icons.account_balance),
//               title: Text('Account Info', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 8,
//               onTap: () => _onItemTapped(8),
//             ),
//             ListTile(
//               leading: const Icon(Icons.sell),
//               title: Text('Sold Products', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 9,
//               onTap: () => _onItemTapped(9),
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: Text('Log out', style: GoogleFonts.poppins()),
//               onTap: () => _onItemTapped(10),
//             ),
//           ],
//         ),
//       ),
//       body: _pages[_selectedIndex],
//     );
//   }
// }

// class SetProfilePage extends StatefulWidget {
//   final String adminId;
//   final String token;

//   const SetProfilePage({super.key, required this.adminId, required this.token});

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
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAdminProfile();
//   }

//   Future<void> _fetchAdminProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//         headers: {'Authorization': 'Bearer ${widget.token}'},
//       );
//       print('Fetch Admin Profile in SetProfilePage: ${response.statusCode} - ${response.body}');
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _firstNameController.text = data['firstName']?.toString() ?? '';
//           _lastNameController.text = data['lastName']?.toString() ?? '';
//           _emailController.text = data['email']?.toString() ?? '';
//         });
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Session expired. Please log in again.')),
//           );
//           Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//         });
//       } else if (response.statusCode == 404) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Admin profile not found. Please log in again.')),
//           );
//           Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//         });
//       } else {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to load profile: ${response.body}')),
//           );
//         });
//       }
//     } catch (e) {
//       print('Error fetching admin profile in SetProfilePage: $e');
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching profile: $e')),
//         );
//       });
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//         );
//         request.headers['Authorization'] = 'Bearer ${widget.token}';
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
//             setState(() {
//               _isLoading = false;
//             });
//             return;
//           }

//           print('Uploading file with ${bytes.length} bytes');
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
//         print('Update Profile Response: ${response.statusCode} - ${responseBody.body}');

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Profile updated successfully')),
//           );
//           // Update SharedPreferences with new firstName
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString('firstName', _firstNameController.text);
//         } else if (response.statusCode == 401 || response.statusCode == 403) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Session expired. Please log in again.')),
//           );
//           Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to update profile: ${responseBody.body}')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating profile: $e')),
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
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Set Profile',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _isLoading
//                     ? null
//                     : () async {
//                         try {
//                           FilePickerResult? result = await FilePicker.platform.pickFiles(
//                             type: FileType.image,
//                             allowMultiple: false,
//                           );
//                           if (result != null && result.files.isNotEmpty) {
//                             setState(() {
//                               _selectedProfilePicture = result.files.first;
//                             });
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('No file selected')),
//                             );
//                           }
//                         } catch (e) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Error selecting image: $e')),
//                           );
//                         }
//                       },
//                 child: Text(
//                   _selectedProfilePicture == null
//                       ? 'Select Profile Picture'
//                       : 'Image Selected: ${_selectedProfilePicture!.name}',
//                   style: GoogleFonts.poppins(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _firstNameController,
//                 decoration: InputDecoration(
//                   labelText: 'First Name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter first name' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _lastNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Last Name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter last name' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter email' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   suffixIcon: TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AdminChangePasswordPage(
//                             token: widget.token,
//                             adminId: widget.adminId,
//                           ),
//                         ),
//                       );
//                     },
//                     child: const Text('Change Password'),
//                   ),
//                 ),
//                 obscureText: true,
//                 enabled: false,
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _updateProfile,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     backgroundColor: Colors.purple,
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Text(
//                           'Update Profile',
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SoldProductsPage extends StatefulWidget {
//   final String token;

//   const SoldProductsPage({super.key, required this.token});

//   @override
//   _SoldProductsPageState createState() => _SoldProductsPageState();
// }

// class _SoldProductsPageState extends State<SoldProductsPage> {
//   final String baseUrl = 'http://localhost:3000';
//   List<dynamic> soldProductsBySeller = [];
//   bool isLoading = true;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSoldProducts();
//   }

//   Future<void> _fetchSoldProducts() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/sold-products'),
//         headers: {'Authorization': 'Bearer ${widget.token}'},
//       );
//       print('Fetch Sold Products Response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           soldProductsBySeller = data;
//           isLoading = false;
//         });
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Session expired. Please log in again.')),
//           );
//           Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Failed to load sold products: ${response.body}';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error fetching sold products: $e');
//       setState(() {
//         errorMessage = 'Error fetching sold products: $e';
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : errorMessage != null
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           errorMessage!,
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             color: Colors.red,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: _fetchSoldProducts,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.purple,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: Text(
//                             'Retry',
//                             style: GoogleFonts.poppins(
//                               fontSize: 16,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : soldProductsBySeller.isEmpty
//                     ? Center(
//                         child: Text(
//                           'No sold products found.',
//                           style: GoogleFonts.poppins(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       )
//                     : ListView.builder(
//                         itemCount: soldProductsBySeller.length,
//                         itemBuilder: (context, index) {
//                           final sellerData = soldProductsBySeller[index];
//                           final seller = sellerData['seller'];
//                           final products = sellerData['products'];
//                           final totalPrice = sellerData['totalPrice'].toDouble();
//                           final totalAfterFee = sellerData['totalAfterFee'].toDouble();

//                           return Card(
//                             elevation: 4,
//                             margin: const EdgeInsets.symmetric(vertical: 8),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: ExpansionTile(
//                               leading: seller['profilePicture'] != null
//                                   ? CircleAvatar(
//                                       backgroundImage: NetworkImage('$baseUrl${seller['profilePicture']}'),
//                                       onBackgroundImageError: (exception, stackTrace) {
//                                         print('Error loading seller profile picture: $exception');
//                                       },
//                                     )
//                                   : CircleAvatar(
//                                       backgroundColor: Colors.purple,
//                                       child: Text(
//                                         seller['name'][0].toUpperCase(),
//                                         style: const TextStyle(color: Colors.white),
//                                       ),
//                                     ),
//                               title: Text(
//                                 seller['name'],
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               subtitle: Text(
//                                 'Total: ETB ${totalPrice.toStringAsFixed(2)} | After 5% Fee: ETB ${totalAfterFee.toStringAsFixed(2)}',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                               children: products.map<Widget>((product) {
//                                 return ListTile(
//                                   leading: product['image'] != null
//                                       ? Image.network(
//                                           '$baseUrl${product['image']}',
//                                           width: 50,
//                                           height: 50,
//                                           fit: BoxFit.cover,
//                                           errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
//                                         )
//                                       : const Icon(Icons.image_not_supported, size: 50),
//                                   title: Text(
//                                     product['name'],
//                                     style: GoogleFonts.poppins(fontSize: 16),
//                                   ),
//                                   subtitle: Text(
//                                     'Price: ETB ${product['price'].toStringAsFixed(2)} x ${product['quantity']} = ETB ${product['totalItemPrice'].toStringAsFixed(2)}\nOrder ID: ${product['orderId']}\nDate: ${product['orderDate'].substring(0, 10)}',
//                                     style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           );
//                         },
//                       ),
//       ),
//     );
//   }
// }

// class CategoryPage extends StatelessWidget {
//   const CategoryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Category Page - Under Development',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

// version to fix index

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'adminuser.dart';
// import 'adminproduct.dart';
// import 'admincategory.dart';
// import 'adminseller.dart';
// import 'adminaccount.dart';
// import 'adminorders.dart';
// import 'adminhome.dart';
// import 'adminchangepassword.dart';
// import 'auth-service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'baseurl.dart';

// class AdminPage extends StatefulWidget {
//   final String adminId;
//   final String token;

//   // Define colors locally
//   static const Color primaryColor = Color.fromARGB(255, 62, 62, 147);
//   static const Color accentColor = Color(0xFFFFD700);

//   const AdminPage({
//     Key? key,
//     required this.adminId,
//     required this.token,
//   }) : super(key: key);

//   @override
//   _AdminPageState createState() => _AdminPageState();
// }

// class _AdminPageState extends State<AdminPage> {
//   int _selectedIndex = 0;
//   String _adminName = "Admin User";
//   String? _profilePicture;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAdminProfile();
//   }

//   Future<void> _fetchAdminProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//         headers: {'Authorization': 'Bearer ${widget.token}'},
//       );
//       print('Fetch Admin Profile Response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           String firstName = data['firstName']?.toString() ?? '';
//           String lastName = data['lastName']?.toString() ?? '';
//           _adminName = '$firstName $lastName'.trim();
//           if (_adminName.isEmpty) {
//             _adminName = 'Admin User';
//           }
//           _profilePicture = data['profilePicture'];
//           print('Updated _adminName: $_adminName, _profilePicture: $_profilePicture');
//         });
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Session expired. Please log in again.')),
//           );
//           Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//         });
//       } else if (response.statusCode == 404) {
//         print('Admin not found for adminId: ${widget.adminId}');
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Admin profile not found. Please log in again.')),
//           );
//           Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//         });
//       } else {
//         print('Failed to load admin profile: ${response.body}');
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to load profile: ${response.body}')),
//           );
//         });
//       }
//     } catch (e) {
//       print('Error fetching admin profile: $e');
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching profile: $e')),
//         );
//       });
//     }
//   }

//   late final List<Widget> _pages;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _pages = [
//       const AdminHomePage(),
//       const UsersPage(),
//       AdminOrdersPage(adminId: widget.adminId),
//       AdminChangePasswordPage(token: widget.token, adminId: widget.adminId),
//       const ProductsPage(),
//       const AdminCategoryPage(),
//       const SellerPage(),
//       SetProfilePage(adminId: widget.adminId, token: widget.token),
//       const AccountInfo(),
//       SoldProductsPage(token: widget.token),
//     ];
//   }

//   Future<void> _onItemTapped(int index) async {
//     Navigator.pop(context); // Close the drawer

//     if (index == 10) {
//       print('Logging out');
//       ScaffoldMessenger.of(context).clearSnackBars();
//       await AuthService.clearAuthData();
//       Navigator.pushReplacementNamed(context, '/login');
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//       if (index == 7) {
//         await _fetchAdminProfile(); // Refresh profile for Set Profile
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100], // Match client pages
//       appBar: _selectedIndex == 8
//           ? null
//           : AppBar(
//               backgroundColor: AdminPage.primaryColor, // Use local primaryColor
//               title: Text(
//                 _selectedIndex == 0
//                     ? 'Admin Panel'
//                     : _selectedIndex == 1
//                         ? 'Users'
//                         : _selectedIndex == 2
//                             ? 'Orders'
//                             : _selectedIndex == 3
//                                 ? 'Change Password'
//                                 : _selectedIndex == 4
//                                     ? 'Products'
//                                     : _selectedIndex == 5
//                                         ? 'Category'
//                                         : _selectedIndex == 6
//                                             ? 'Sellers'
//                                             : _selectedIndex == 7
//                                                 ? 'Set Profile'
//                                                 : _selectedIndex == 8
//                                                     ? 'Account Info'
//                                                     : _selectedIndex == 9
//                                                         ? 'Sold Products'
//                                                         : 'Admin Panel',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               foregroundColor: Colors.white,
//               elevation: 2,
//             ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserAccountsDrawerHeader(
//               accountName: Text(
//                 _adminName,
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               accountEmail: Text(
//                 'Welcome, $_adminName',
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
//                       backgroundColor: AdminPage.primaryColor, // Use primaryColor
//                       child: Text(
//                         'P',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//               decoration: BoxDecoration(
//                 color: AdminPage.primaryColor, // Use primaryColor
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.home, color: AdminPage.primaryColor),
//               title: Text('Home', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 0,
//               selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
//               onTap: () => _onItemTapped(0),
//             ),
//             ListTile(
//               leading: Icon(Icons.people, color: AdminPage.primaryColor),
//               title: Text('Users', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 1,
//               selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
//               onTap: () => _onItemTapped(1),
//             ),
//             ListTile(
//               leading: Icon(Icons.shopping_cart, color: AdminPage.primaryColor),
//               title: Text('Orders', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 2,
//               selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
//               onTap: () => _onItemTapped(2),
//             ),
//             ListTile(
//               leading: Icon(Icons.lock, color: AdminPage.primaryColor),
//               title: Text('Change Password', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 3,
//               selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
//               onTap: () => _onItemTapped(3),
//             ),
//             ListTile(
//               leading: Icon(Icons.store, color: AdminPage.primaryColor),
//               title: Text('Products', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 4,
//               selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
//               onTap: () => _onItemTapped(4),
//             ),
//             ListTile(
//               leading: Icon(Icons.category, color: AdminPage.primaryColor),
//               title: Text('Category', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 5,
//               selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
//               onTap: () => _onItemTapped(5),
//             ),
//             ListTile(
//               leading: Icon(Icons.contact_support, color: AdminPage.primaryColor),
//               title: Text('Sellers', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 6,
//               selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
//               onTap: () => _onItemTapped(6),
//             ),
//             ListTile(
//               leading: Icon(Icons.person, color: AdminPage.primaryColor),
//               title: Text('Set Profile', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 7,
//               selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
//               onTap: () => _onItemTapped(7),
//             ),
//             ListTile(
//               leading: Icon(Icons.account_balance, color: AdminPage.primaryColor),
//               title: Text('Account Info', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 8,
//               selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
//               onTap: () => _onItemTapped(8),
//             ),
//             ListTile(
//               leading: Icon(Icons.sell, color: AdminPage.primaryColor),
//               title: Text('Sold Products', style: GoogleFonts.poppins()),
//               selected: _selectedIndex == 9,
//               selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
//               onTap: () => _onItemTapped(9),
//             ),
//             ListTile(
//               leading: Icon(Icons.logout, color: AdminPage.primaryColor),
//               title: Text('Log out', style: GoogleFonts.poppins()),
//               selectedTileColor: AdminPage.primaryColor.withOpacity(0.1),
//               onTap: () => _onItemTapped(10),
//             ),
//           ],
//         ),
//       ),
//       body: _pages[_selectedIndex],
//     );
//   }
// }

// class SetProfilePage extends StatefulWidget {
//   final String adminId;
//   final String token;

//   const SetProfilePage({super.key, required this.adminId, required this.token});

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
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAdminProfile();
//   }

//   Future<void> _fetchAdminProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//         headers: {'Authorization': 'Bearer ${widget.token}'},
//       );
//       print('Fetch Admin Profile in SetProfilePage: ${response.statusCode} - ${response.body}');
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _firstNameController.text = data['firstName']?.toString() ?? '';
//           _lastNameController.text = data['lastName']?.toString() ?? '';
//           _emailController.text = data['email']?.toString() ?? '';
//         });
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Session expired. Please log in again.')),
//           );
//           Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//         });
//       } else if (response.statusCode == 404) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Admin profile not found. Please log in again.')),
//           );
//           Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//         });
//       } else {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to load profile: ${response.body}')),
//           );
//         });
//       }
//     } catch (e) {
//       print('Error fetching admin profile in SetProfilePage: $e');
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching profile: $e')),
//         );
//       });
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         final request = http.MultipartRequest(
//           'PUT',
//           Uri.parse('$baseUrl/admin/profile/${widget.adminId}'),
//         );
//         request.headers['Authorization'] = 'Bearer ${widget.token}';
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
//             setState(() {
//               _isLoading = false;
//             });
//             return;
//           }

//           print('Uploading file with ${bytes.length} bytes');
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
//         print('Update Profile Response: ${response.statusCode} - ${responseBody.body}');

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Profile updated successfully')),
//           );
//           // Update SharedPreferences with new firstName
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString('firstName', _firstNameController.text);
//         } else if (response.statusCode == 401 || response.statusCode == 403) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Session expired. Please log in again.')),
//           );
//           Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to update profile: ${responseBody.body}')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating profile: $e')),
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
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Set Profile',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: AdminPage.primaryColor, // Use local primaryColor
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _isLoading
//                     ? null
//                     : () async {
//                         try {
//                           FilePickerResult? result = await FilePicker.platform.pickFiles(
//                             type: FileType.image,
//                             allowMultiple: false,
//                           );
//                           if (result != null && result.files.isNotEmpty) {
//                             setState(() {
//                               _selectedProfilePicture = result.files.first;
//                             });
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('No file selected')),
//                             );
//                           }
//                         } catch (e) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Error selecting image: $e')),
//                           );
//                         }
//                       },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AdminPage.primaryColor, // Use primaryColor
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   _selectedProfilePicture == null
//                       ? 'Select Profile Picture'
//                       : 'Image Selected: ${_selectedProfilePicture!.name}',
//                   style: GoogleFonts.poppins(
//                     color: Colors.white,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _firstNameController,
//                 decoration: InputDecoration(
//                   labelText: 'First Name',
//                   labelStyle: TextStyle(color: AdminPage.primaryColor),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: AdminPage.primaryColor),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter first name' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _lastNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Last Name',
//                   labelStyle: TextStyle(color: AdminPage.primaryColor),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: AdminPage.primaryColor),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter last name' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   labelStyle: TextStyle(color: AdminPage.primaryColor),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: AdminPage.primaryColor),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter email' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   labelStyle: TextStyle(color: AdminPage.primaryColor),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: AdminPage.primaryColor),
//                   ),
//                   suffixIcon: TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AdminChangePasswordPage(
//                             token: widget.token,
//                             adminId: widget.adminId,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Text(
//                       'Change Password',
//                       style: TextStyle(color: AdminPage.primaryColor),
//                     ),
//                   ),
//                 ),
//                 obscureText: true,
//                 enabled: false,
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _updateProfile,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     backgroundColor: AdminPage.primaryColor, // Use primaryColor
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Text(
//                           'Update Profile',
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SoldProductsPage extends StatefulWidget {
//   final String token;

//   const SoldProductsPage({super.key, required this.token});

//   @override
//   _SoldProductsPageState createState() => _SoldProductsPageState();
// }

// class _SoldProductsPageState extends State<SoldProductsPage> {
//   // final String baseUrl = 'http://localhost:3000';
//   List<dynamic> soldProductsBySeller = [];
//   bool isLoading = true;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSoldProducts();
//   }

//   Future<void> _fetchSoldProducts() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/sold-products'),
//         headers: {'Authorization': 'Bearer ${widget.token}'},
//       );
//       print('Fetch Sold Products Response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           soldProductsBySeller = data;
//           isLoading = false;
//         });
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Session expired. Please log in again.')),
//           );
//           Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Failed to load sold products: ${response.body}';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error fetching sold products: $e');
//       setState(() {
//         errorMessage = 'Error fetching sold products: $e';
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100], // Match client pages
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: isLoading
//             ? Center(child: CircularProgressIndicator(color: AdminPage.primaryColor))
//             : errorMessage != null
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           errorMessage!,
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             color: Colors.red,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: _fetchSoldProducts,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AdminPage.primaryColor, // Use primaryColor
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           child: Text(
//                             'Retry',
//                             style: GoogleFonts.poppins(
//                               fontSize: 16,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : soldProductsBySeller.isEmpty
//                     ? Center(
//                         child: Text(
//                           'No sold products found.',
//                           style: GoogleFonts.poppins(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: AdminPage.primaryColor,
//                           ),
//                         ),
//                       )
//                     : ListView.builder(
//                         itemCount: soldProductsBySeller.length,
//                         itemBuilder: (context, index) {
//                           final sellerData = soldProductsBySeller[index];
//                           final seller = sellerData['seller'];
//                           final products = sellerData['products'];
//                           final totalPrice = sellerData['totalPrice'].toDouble();
//                           final totalAfterFee = sellerData['totalAfterFee'].toDouble();

//                           return Card(
//                             elevation: 4,
//                             margin: const EdgeInsets.symmetric(vertical: 8),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               side: BorderSide(color: Colors.grey[200]!, width: 1), // Match client pages
//                             ),
//                             child: ExpansionTile(
//                               leading: seller['profilePicture'] != null
//                                   ? CircleAvatar(
//                                       backgroundImage: NetworkImage('$baseUrl${seller['profilePicture']}'),
//                                       onBackgroundImageError: (exception, stackTrace) {
//                                         print('Error loading seller profile picture: $exception');
//                                       },
//                                     )
//                                   : CircleAvatar(
//                                       backgroundColor: AdminPage.primaryColor, // Use primaryColor
//                                       child: Text(
//                                         seller['name'][0].toUpperCase(),
//                                         style: const TextStyle(color: Colors.white),
//                                       ),
//                                     ),
//                               title: Text(
//                                 seller['name'],
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: AdminPage.primaryColor,
//                                 ),
//                               ),
//                               subtitle: Text(
//                                 'Total: ETB ${totalPrice.toStringAsFixed(2)} | After 5% Fee: ETB ${totalAfterFee.toStringAsFixed(2)}',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                               children: products.map<Widget>((product) {
//                                 return ListTile(
//                                   leading: product['image'] != null
//                                       ? Image.network(
//                                           '$baseUrl${product['image']}',
//                                           width: 50,
//                                           height: 50,
//                                           fit: BoxFit.cover,
//                                           errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
//                                         )
//                                       : const Icon(Icons.image_not_supported, size: 50),
//                                   title: Text(
//                                     product['name'],
//                                     style: GoogleFonts.poppins(fontSize: 16, color: AdminPage.primaryColor),
//                                   ),
//                                   subtitle: Text(
//                                     'Price: ETB ${product['price'].toStringAsFixed(2)} x ${product['quantity']} = ETB ${product['totalItemPrice'].toStringAsFixed(2)}\nOrder ID: ${product['orderId']}\nDate: ${product['orderDate'].substring(0, 10)}',
//                                     style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           );
//                         },
//                       ),
//       ),
//     );
//   }
// }

// class CategoryPage extends StatelessWidget {
//   const CategoryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100], // Match client pages
//       body: Center(
//         child: Text(
//           'Category Page - Under Development',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: AdminPage.primaryColor, // Use primaryColor
//           ),
//         ),
//       ),
//     );
//   }
// }

// version 

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

  // Define colors locally
  static const Color primaryColor = Color.fromARGB(255, 62, 62, 147);
  static const Color accentColor = Color(0xFFFFD700);

  const AdminPage({
    Key? key,
    required this.adminId,
    required this.token,
  }) : super(key: key);

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
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Please log in again.')),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        });
      } else if (response.statusCode == 404) {
        print('Admin not found for adminId: ${widget.adminId}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin profile not found. Please log in again.')),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
    Navigator.pop(context); // Close the drawer

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
        await _fetchAdminProfile(); // Refresh profile for Set Profile
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Match client pages
      appBar: AppBar(
        backgroundColor: AdminPage.primaryColor, // Use local primaryColor
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
                      backgroundColor: AdminPage.primaryColor, // Use primaryColor
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
              leading: Icon(Icons.contact_support, color: AdminPage.primaryColor),
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
              leading: Icon(Icons.account_balance, color: AdminPage.primaryColor),
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
  // final String baseUrl = 'http://localhost:3000';
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
      print('Fetch Admin Profile in SetProfilePage: ${response.statusCode} - ${response.body}');
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
            const SnackBar(content: Text('Session expired. Please log in again.')),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        });
      } else if (response.statusCode == 404) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin profile not found. Please log in again.')),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
          // Update SharedPreferences with new firstName
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('firstName', _firstNameController.text);
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Please log in again.')),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 97, 97, 159), // Use primaryColor
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  _selectedProfilePicture == null
                      ? 'Select Profile Picture'
                      : 'Image Selected: ${_selectedProfilePicture!.name}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                  ),
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
                validator: (value) =>
                    value!.isEmpty ? 'Enter first name' : null,
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
                validator: (value) =>
                    value!.isEmpty ? 'Enter last name' : null,
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
                validator: (value) =>
                    value!.isEmpty ? 'Enter email' : null,
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

class SoldProductsPage extends StatefulWidget {
  final String token;

  const SoldProductsPage({super.key, required this.token});

  @override
  _SoldProductsPageState createState() => _SoldProductsPageState();
}

class _SoldProductsPageState extends State<SoldProductsPage> {
  // final String baseUrl = 'http://localhost:3000';
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
      print('Fetch Sold Products Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          soldProductsBySeller = data;
          isLoading = false;
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Please log in again.')),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
      backgroundColor: Colors.grey[100], // Match client pages
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: AdminPage.primaryColor))
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
                            backgroundColor: AdminPage.primaryColor, // Use primaryColor
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
                          final totalAfterFee = sellerData['totalAfterFee'].toDouble();

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey[200]!, width: 1), // Match client pages
                            ),
                            child: ExpansionTile(
                              leading: seller['profilePicture'] != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage('$baseUrl${seller['profilePicture']}'),
                                      onBackgroundImageError: (exception, stackTrace) {
                                        print('Error loading seller profile picture: $exception');
                                      },
                                    )
                                  : CircleAvatar(
                                      backgroundColor: AdminPage.primaryColor, // Use primaryColor
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
                              children: products.map<Widget>((product) {
                                return ListTile(
                                  leading: product['image'] != null
                                      ? Image.network(
                                          '$baseUrl${product['image']}',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                        )
                                      : const Icon(Icons.image_not_supported, size: 50),
                                  title: Text(
                                    product['name'],
                                    style: GoogleFonts.poppins(fontSize: 16, color: AdminPage.primaryColor),
                                  ),
                                  subtitle: Text(
                                    'Price: ETB ${product['price'].toStringAsFixed(2)} x ${product['quantity']} = ETB ${product['totalItemPrice'].toStringAsFixed(2)}\nOrder ID: ${product['orderId']}\nDate: ${product['orderDate'].substring(0, 10)}',
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
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

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Match client pages
      body: Center(
        child: Text(
          'Category Page - Under Development',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AdminPage.primaryColor, // Use primaryColor
          ),
        ),
      ),
    );
  }
}