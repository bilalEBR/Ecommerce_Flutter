
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'client-state.dart';
import 'baseurl.dart';

class ClientAddressPage extends StatefulWidget {
  final String? fullName;
  final String? email;

  const ClientAddressPage({
    super.key,
    this.fullName,
    this.email,
  });

  @override
  _ClientAddressPageState createState() => _ClientAddressPageState();
}

class _ClientAddressPageState extends State<ClientAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedRegion;
  bool _isLoading = true;
  bool _isSubmitting = false;

  final List<String> _regions = [
    'Amhara',
    'Oromia',
    'Tigray',
    'Afar',
    'Somali',
    'Benishangul',
    'Gambela',
    'Harar',
    'Sidama',
    'Debub Ethiopia',
    'Debub Kellel',
  ];

  // Color scheme
  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);
  final Color accentColor = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    // Initialize controllers with widget values
    _fullNameController.text = widget.fullName ?? '';
    _emailController.text = widget.email ?? '';
    // Debug print to confirm received values
    print('ClientAddressPage init: fullName=${widget.fullName ?? 'null'}, email=${widget.email ?? 'null'}');
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    setState(() {
      _isLoading = true;
    });

    final clientState = Provider.of<ClientState>(context, listen: false);
    final userId = clientState.userId;
    final token = clientState.token;

    if (userId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication error: Please log in again.')),
      );
      setState(() {
        _isLoading = false;
      });
      print('Authentication error: userId or token is null');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/client/address/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Fetch Address Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _phoneNumberController.text = data['phoneNumber']?.isNotEmpty == true ? data['phoneNumber'] : '';
          _selectedRegion = data['region']?.isNotEmpty == true ? data['region'] : null;
          _postalCodeController.text = data['postalCode']?.isNotEmpty == true ? data['postalCode'] : '';
          _cityController.text = data['city']?.isNotEmpty == true ? data['city'] : '';
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load address: ${response.body}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching address: $e')),
      );
      setState(() {
        _isLoading = false;
      });
      print('Error fetching address: $e');
    }
  }

  Future<void> _updateAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final clientState = Provider.of<ClientState>(context, listen: false);
    final userId = clientState.userId;
    final token = clientState.token;

    if (userId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication error: Please log in again.')),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final addressData = {
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
      'region': _selectedRegion ?? '',
      'postalCode': _postalCodeController.text.trim(),
      'city': _cityController.text.trim(),
    };

    print('Updating address with data: $addressData');

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/client/address/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(addressData),
      );

      print('Update Address Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonDecode(response.body)['message'] ?? 'Address updated successfully')),
        );
        Navigator.pop(context); // Return to ClientCheckoutPage
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update address: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating address: $e')),
      );
      print('Error updating address: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Shipping Address',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 2,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Full Name',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
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
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Email',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
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
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegExp.hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                        }
                        return null;
                      },
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Phone Number',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
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
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? 'Enter phone number' : null,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Region',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedRegion,
                      decoration: InputDecoration(
                        labelText: 'Region',
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
                      items: _regions.map((region) {
                        return DropdownMenuItem<String>(
                          value: region,
                          child: Text(region, style: GoogleFonts.poppins(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRegion = value;
                        });
                      },
                      validator: (value) => value == null ? 'Please select a region' : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Postal Code',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _postalCodeController,
                      decoration: InputDecoration(
                        labelText: 'Postal Code',
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
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter postal code' : null,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'City',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'City',
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
                      validator: (value) => value!.isEmpty ? 'Enter city' : null,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _updateAddress,
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
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Save Address',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
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