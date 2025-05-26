
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'client-state.dart';
import 'baseurl.dart';


class ClientCheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double total;

  const ClientCheckoutPage({
    super.key,
    required this.cartItems,
    required this.total,
  });

  @override
  _ClientCheckoutPageState createState() => _ClientCheckoutPageState();
}

class _ClientCheckoutPageState extends State<ClientCheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPaymentMethod;
  String? _accountHolderName;
  String? _accountNumber;
  String? _transactionId;
  PlatformFile? _recipientScreenshotFile;
  bool _isLoading = false;
  bool _isFetchingAccount = false;
  bool _isFetchingAddress = false;
  String? _errorMessage;
  String? _imageUploadError;
  String? _transactionError;
  bool _isOrderSuccessful = false;

  String? _fullName;
  String? _email;
  String? _phoneNumber;
  String? _region;
  String? _postalCode;
  String? _city;
  String? _firstName;
  String? _lastName;
  bool _isAddressExpanded = false;

  final List<String> _paymentMethods = [
    'CBE',
    'Awash Bank',
    'Dashin Bank',
  ];

  final _accountHolderNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _transactionIdController = TextEditingController();

  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);
  final Color accentColor = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = _paymentMethods.first;
    _fetchAccountDetails(_selectedPaymentMethod!);
    _fetchClientData();
  }

  Future<void> _fetchClientData() async {
    setState(() {
      _isFetchingAddress = true;
      _errorMessage = null;
    });

    final clientState = Provider.of<ClientState>(context, listen: false);
    final token = clientState.token;
    final userId = clientState.userId;

    print('Fetching client address: userId=$userId, token=${token?.substring(0, 10)}...');

    if (token == null || userId == null) {
      setState(() {
        _errorMessage = 'Authentication error: userId or token is null';
        _fullName = '';
        _email = '';
        _phoneNumber = '';
        _region = '';
        _postalCode = '';
        _city = '';
        _isFetchingAddress = false;
      });
      print('Authentication error: userId=$userId, token=$token');
      return;
    }

    try {
      final addressResponse = await http.get(
        Uri.parse('$baseUrl/client/address/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      print('Address API: Status=${addressResponse.statusCode}, Body=${addressResponse.body}');

      if (addressResponse.statusCode == 200) {
        final addressData = jsonDecode(addressResponse.body);
        setState(() {
          _fullName = addressData['fullName']?.isNotEmpty == true ? addressData['fullName'] : '';
          _email = addressData['email']?.isNotEmpty == true ? addressData['email'] : '';
          _phoneNumber = addressData['phoneNumber']?.isNotEmpty == true ? addressData['phoneNumber'] : '';
          _region = addressData['region']?.isNotEmpty == true ? addressData['region'] : '';
          _postalCode = addressData['postalCode']?.isNotEmpty == true ? addressData['postalCode'] : '';
          _city = addressData['city']?.isNotEmpty == true ? addressData['city'] : '';
          _isFetchingAddress = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch address: ${addressResponse.statusCode} - ${addressResponse.body}';
          _fullName = '';
          _email = '';
          _phoneNumber = '';
          _region = '';
          _postalCode = '';
          _city = '';
          _isFetchingAddress = false;
        });
        print('Address fetch failed: ${_errorMessage}');
      }

      print('Fetched Address: fullName=$_fullName, email=$_email, phoneNumber=$_phoneNumber, region=$_region, postalCode=$_postalCode, city=$_city');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching address: $e';
        _fullName = '';
        _email = '';
        _phoneNumber = '';
        _region = '';
        _postalCode = '';
        _city = '';
        _isFetchingAddress = false;
      });
      print('Error fetching address: $e');
    }
  }

  Future<void> _fetchAccountDetails(String paymentMethod) async {
    setState(() {
      _isFetchingAccount = true;
      _accountHolderName = null;
      _accountNumber = null;
      _accountHolderNameController.text = 'Loading...';
      _accountNumberController.text = 'Loading...';
    });

    try {
      final url = '$baseUrl/adminAccount/all';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final matchingAccounts = data.where((account) => account['bankName'] == paymentMethod).toList();

        if (matchingAccounts.isNotEmpty) {
          final account = matchingAccounts[0];
          final String accountStatus = account['accountStatus']?.toLowerCase() ?? 'active';
          setState(() {
            if (accountStatus == 'active') {
              _accountHolderName = account['accountHolderName'];
              _accountNumber = account['accountNumber'];
              _accountHolderNameController.text = _accountHolderName ?? 'Not Available';
              _accountNumberController.text = _accountNumber ?? 'Not Available';
            } else {
              _accountHolderName = 'Not Available';
              _accountNumber = 'Not Available';
              _accountHolderNameController.text = 'Not Available';
              _accountNumberController.text = 'Not Available';
            }
            _isFetchingAccount = false;
          });
        } else {
          setState(() {
            _accountHolderName = 'Not Available';
            _accountNumber = 'Not Available';
            _accountHolderNameController.text = 'Not Available';
            _accountNumberController.text = 'Not Available';
            _isFetchingAccount = false;
          });
        }
      } else {
        setState(() {
          _accountHolderName = 'Error';
          _accountNumber = 'Error';
          _accountHolderNameController.text = 'Error';
          _accountNumberController.text = 'Error';
          _isFetchingAccount = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch admin accounts: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() {
        _accountHolderName = 'Error';
        _accountNumber = 'Error';
        _accountHolderNameController.text = 'Error';
        _accountNumberController.text = 'Error';
        _isFetchingAccount = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching admin accounts: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _recipientScreenshotFile = result.files.first;
          _imageUploadError = null;
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
  }

  String? _validateTransactionId(String? transactionId) {
    if (transactionId == null || transactionId.isEmpty) {
      return 'Transaction ID cannot be empty';
    }
    if (transactionId.length != 12) {
      return 'Transaction ID must be exactly 12 characters';
    }
    if (!transactionId.startsWith('FT25')) {
      return 'Transaction ID must start with "FT25"';
    }
    final suffix = transactionId.substring(4);
    if (!RegExp(r'^[a-zA-Z0-9]{8}$').hasMatch(suffix)) {
      return 'Transaction ID must contain only letters and digits after "FT25"';
    }
    return null;
  }

  void _showAddressNotSetPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Address Required',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          content: Text(
            'Delivery address not set, please insert your address in your profile',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _placeOrder() async {
    // Check if address fields are null or empty
    if (_phoneNumber == null || _phoneNumber!.isEmpty ||
        _region == null || _region!.isEmpty ||
        _postalCode == null || _postalCode!.isEmpty ||
        _city == null || _city!.isEmpty) {
      _showAddressNotSetPopup(context);
      return;
    }

    if (_recipientScreenshotFile == null) {
      setState(() {
        _imageUploadError = 'Please upload image';
      });
      return;
    }

    setState(() {
      _imageUploadError = null;
    });

    final transactionIdError = _validateTransactionId(_transactionIdController.text);
    if (transactionIdError != null) {
      setState(() {
        _transactionError = transactionIdError;
      });
      return;
    }

    setState(() {
      _transactionError = null;
    });

    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    if (_accountHolderName == 'Not Available' || _accountNumber == 'Not Available') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an available payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final clientState = Provider.of<ClientState>(context, listen: false);
    final token = clientState.token;
    final userId = clientState.userId;

    if (token == null || userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication error: Please log in again.';
      });
      return;
    }

    final orderDate = DateTime.now();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/client/orders'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['userId'] = userId;
      request.fields['items'] = jsonEncode(widget.cartItems.map((item) => ({
            'productId': item['productId'],
            'sellerId': item['sellerId'],
            'price': item['price'],
            'image': item['image'],
            'quantity': item['quantity'],
          })).toList());
      request.fields['total'] = widget.total.toString();
      request.fields['paymentMethod'] = _selectedPaymentMethod!;
      request.fields['accountHolderName'] = _accountHolderName!;
      request.fields['accountNumber'] = _accountNumber!;
      request.fields['transactionId'] = _transactionIdController.text;
      request.fields['status'] = 'pending';
      request.fields['shippingAddress'] = jsonEncode({
        'fullName': _fullName ?? '',
        'email': _email ?? '',
        'phoneNumber': _phoneNumber ?? '',
        'region': _region ?? '',
        'postalCode': _postalCode ?? '',
        'city': _city ?? '',
      });
      request.fields['orderDate'] = orderDate.toIso8601String();

      if (_recipientScreenshotFile != null) {
        final bytes = <int>[];
        if (_recipientScreenshotFile!.readStream != null) {
          await for (var chunk in _recipientScreenshotFile!.readStream!) {
            bytes.addAll(chunk);
          }
        } else if (_recipientScreenshotFile!.bytes != null) {
          bytes.addAll(_recipientScreenshotFile!.bytes!);
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
            'recipientScreenshot',
            bytes,
            filename: _recipientScreenshotFile!.name,
            contentType: MediaType('image', _recipientScreenshotFile!.extension ?? 'jpeg'),
          ),
        );
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 201) {
        setState(() {
          _isOrderSuccessful = true;
        });
        clientState.clearCart();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to ClientHomePage
        // Navigator.pushNamedAndRemoveUntil(context, ClientHomePage(), (route) => false);
      } else {
        setState(() {
          _errorMessage = 'Failed to place order: ${responseBody.body}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: ${responseBody.body}')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error placing order: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _accountHolderNameController.dispose();
    _accountNumberController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: widget.total.toStringAsFixed(2),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Total Amount (ETB)',
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
              Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAddressExpanded = !_isAddressExpanded;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Address',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          Icon(
                            _isAddressExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                            size: 20,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ),
                    if (_isAddressExpanded) ...[
                      const SizedBox(height: 6),
                      _isFetchingAddress
                          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Full Name: ${_fullName ?? 'Not Available'}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[800]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Email: ${_email ?? 'Not Available'}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[800]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Phone Number: ${_phoneNumber ?? 'Not Available'}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[800]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Region: ${_region ?? 'Not Available'}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[800]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Postal Code: ${_postalCode ?? 'Not Available'}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[800]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'City: ${_city ?? 'Not Available'}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[800]),
                                ),
                              ],
                            ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Select Payment Method',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: InputDecoration(
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
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method, style: GoogleFonts.poppins(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                    _accountHolderName = null;
                    _accountNumber = null;
                  });
                  _fetchAccountDetails(value!);
                },
                validator: (value) => value == null ? 'Please select a payment method' : null,
              ),
              const SizedBox(height: 12),
              Text(
                'Account Holder Name',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _accountHolderNameController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Account Holder Name',
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
                'Account Number',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _accountNumberController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Account Number',
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
                'Recipient Screenshot',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: primaryColor, width: 1),
                    ),
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: _recipientScreenshotFile == null ? 'Upload Recipient Screenshot' : null,
                        labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                        hintText: _recipientScreenshotFile == null ? 'No file selected' : _recipientScreenshotFile!.name,
                        hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ),
                  if (_imageUploadError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 6),
                      child: Text(
                        _imageUploadError!,
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  if (_recipientScreenshotFile != null && _recipientScreenshotFile!.bytes != null) ...[
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          _recipientScreenshotFile!.bytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 150,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text(
                                'Error loading image',
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        shadowColor: Colors.grey.withOpacity(0.5),
                      ),
                      child: Text(
                        'Upload',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Transaction ID',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _transactionIdController,
                decoration: InputDecoration(
                  labelText: 'Transaction ID',
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
                onChanged: (value) {
                  _transactionId = value;
                  setState(() {
                    _transactionError = null;
                  });
                },
                validator: _validateTransactionId,
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              if (_transactionError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 6),
                  child: Text(
                    _transactionError!,
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_isLoading || _isOrderSuccessful) {
                      // Do nothing if loading or order is successful
                      return;
                    }
                    if (_phoneNumber == null || _phoneNumber!.isEmpty ||
                        _region == null || _region!.isEmpty ||
                        _postalCode == null || _postalCode!.isEmpty ||
                        _city == null || _city!.isEmpty) {
                      _showAddressNotSetPopup(context);
                    } else {
                      _placeOrder();
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
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Order',
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
    );
  }
}
