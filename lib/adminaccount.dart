// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'baseurl.dart';


// class AccountInfo extends StatefulWidget {
//   const AccountInfo({super.key});

//   @override
//   _AccountInfoState createState() => _AccountInfoState();
// }

// class _AccountInfoState extends State<AccountInfo> {
//   // final String baseUrl = 'http://localhost:3000';
//   List<dynamic> accounts = [];
//   List<dynamic> filteredAccounts = [];
//   bool isLoading = false;
//   final TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     fetchAccounts();
//   }

//   Future<void> fetchAccounts() async {
//     setState(() {
//       isLoading = true;
//     });
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/adminAccount/all'));
//       if (response.statusCode == 200) {
//         setState(() {
//           accounts = jsonDecode(response.body);
//           filteredAccounts = accounts;
//           isLoading = false;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load accounts: ${response.body}')),
//         );
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching accounts: $e')),
//       );
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> deleteAccount(String accountId) async {
//     bool? confirmDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Confirm Delete', style: GoogleFonts.poppins()),
//         content: Text('Are you sure you want to delete this account?', style: GoogleFonts.poppins()),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text('Cancel', style: GoogleFonts.poppins()),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: Text('Delete', style: GoogleFonts.poppins()),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//           ),
//         ],
//       ),
//     );

//     if (confirmDelete == true) {
//       try {
//         final response = await http.delete(Uri.parse('$baseUrl/adminAccount/$accountId'));
//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Account deleted successfully')),
//           );
//           fetchAccounts();
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to delete account: ${response.body}')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error deleting account: $e')),
//         );
//       }
//     }
//   }

//   void filterAccounts(String query) {
//     setState(() {
//       filteredAccounts = accounts.where((account) =>
//           account['bankName'].toLowerCase().contains(query.toLowerCase()) ||
//           account['accountHolderName'].toLowerCase().contains(query.toLowerCase())).toList();
//     });
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           'Account Info',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.menu, color: Colors.white),
//           onPressed: () {
//             Scaffold.of(context).openDrawer(); // Open the drawer
//           },
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search by bank name or account holder',
//                       hintStyle: GoogleFonts.poppins(color: Colors.grey),
//                       prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     style: GoogleFonts.poppins(),
//                     onChanged: filterAccounts,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.purple,
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.add, color: Colors.white),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const AddEditAccountPage(),
//                         ),
//                       ).then((_) => fetchAccounts());
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : filteredAccounts.isEmpty
//                     ? const Center(child: Text('No accounts found'))
//                     : ListView.builder(
//                         padding: const EdgeInsets.all(16.0),
//                         itemCount: filteredAccounts.length,
//                         itemBuilder: (context, index) {
//                           final account = filteredAccounts[index];
//                           return Card(
//                             elevation: 3,
//                             margin: const EdgeInsets.symmetric(vertical: 8.0),
//                             child: ListTile(
//                               title: Text(
//                                 account['bankName'],
//                                 style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//                               ),
//                               subtitle: Text(
//                                 account['accountHolderName'],
//                                 style: GoogleFonts.poppins(),
//                               ),
//                               trailing: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                     decoration: BoxDecoration(
//                                       color: account['accountStatus'] == 'Active' ? Colors.green : Colors.red,
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: Text(
//                                       account['accountStatus'],
//                                       style: GoogleFonts.poppins(color: Colors.white),
//                                     ),
//                                   ),
//                                   IconButton(
//                                     icon: const Icon(Icons.edit, color: Colors.blue),
//                                     onPressed: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => AddEditAccountPage(account: account),
//                                         ),
//                                       ).then((_) => fetchAccounts());
//                                     },
//                                   ),
//                                   IconButton(
//                                     icon: const Icon(Icons.delete, color: Colors.red),
//                                     onPressed: () => deleteAccount(account['_id']),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AddEditAccountPage extends StatefulWidget {
//   final Map<String, dynamic>? account;

//   const AddEditAccountPage({super.key, this.account});

//   @override
//   _AddEditAccountPageState createState() => _AddEditAccountPageState();
// }

// class _AddEditAccountPageState extends State<AddEditAccountPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _bankNameController = TextEditingController();
//   final _accountHolderNameController = TextEditingController();
//   final _accountNumberController = TextEditingController();
//   final _phoneNumberController = TextEditingController();
//   // final _teleBirrPhoneNumberController = TextEditingController();
//   String? _accountStatus;
//   final String baseUrl = 'http://localhost:3000';
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.account != null) {
//       _bankNameController.text = widget.account!['bankName'] ?? '';
//       _accountHolderNameController.text = widget.account!['accountHolderName'] ?? '';
//       _accountNumberController.text = widget.account!['accountNumber'] ?? '';
//       _phoneNumberController.text = widget.account!['phoneNumber'] ?? '';
//       //   _teleBirrPhoneNumberController.text = widget.account!['teleBirrPhoneNumber'] ?? '';
//       _accountStatus = widget.account!['accountStatus'] ?? 'Active';
//     } else {
//       _accountStatus = 'Active';
//     }
//   }

//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       final accountData = {
//         'bankName': _bankNameController.text,
//         'accountHolderName': _accountHolderNameController.text,
//         'accountNumber': _accountNumberController.text,
//         'phoneNumber': _phoneNumberController.text,
//         // 'teleBirrPhoneNumber': _teleBirrPhoneNumberController.text,
//         'accountStatus': _accountStatus,
//       };

//       try {
//         if (widget.account != null) {
//           // Update existing account
//           final response = await http.put(
//             Uri.parse('$baseUrl/adminAccount/${widget.account!['_id']}'),
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode(accountData),
//           );
//           if (response.statusCode == 200) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Account updated successfully')),
//             );
//             Navigator.pop(context);
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Failed to update account: ${response.body}')),
//             );
//           }
//         } else {
//           // Add new account
//           final response = await http.post(
//             Uri.parse('$baseUrl/adminAccount/add'),
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode(accountData),
//           );
//           if (response.statusCode == 201) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Account added successfully')),
//             );
//             Navigator.pop(context);
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Failed to add account: ${response.body}')),
//             );
//           }
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
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
//     _bankNameController.dispose();
//     _accountHolderNameController.dispose();
//     _accountNumberController.dispose();
//     _phoneNumberController.dispose();
//     // _teleBirrPhoneNumberController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple,
//         title: Text(
//           widget.account != null ? 'Edit Account' : 'Add Account',
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
//                 DropdownButtonFormField<String>(
//                   value: _bankNameController.text.isEmpty ? null : _bankNameController.text,
//                   decoration: InputDecoration(
//                     labelText: 'Select Bank',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   items: [
//                     'Commercial Bank of Ethiopia (CBE)',
//                     'Awash Bank',
//                     'Abay Bank',
//                     'Dashin Bank',
//                   ].map((bank) => DropdownMenuItem<String>(
//                         value: bank,
//                         child: Text(bank, style: GoogleFonts.poppins()),
//                       )).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _bankNameController.text = value ?? '';
//                     });
//                   },
//                   validator: (value) => value == null ? 'Select a bank' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _accountHolderNameController,
//                   decoration: InputDecoration(
//                     labelText: 'Account Holder Name',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) => value!.isEmpty ? 'Enter account holder name' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _accountNumberController,
//                   decoration: InputDecoration(
//                     labelText: 'Account Number',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) => value!.isEmpty ? 'Enter account number' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _phoneNumberController,
//                   decoration: InputDecoration(
//                     labelText: 'Phone Number',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) => value!.isEmpty ? 'Enter phone number' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 // TextFormField(
//                 //   controller: _teleBirrPhoneNumberController,
//                 //   decoration: InputDecoration(
//                 //     labelText: 'Tele Birr Phone Number',
//                 //     border: OutlineInputBorder(
//                 //       borderRadius: BorderRadius.circular(12),
//                 //     ),
//                 //   ),
//                 //   validator: (value) => value!.isEmpty ? 'Enter tele birr phone number' : null,
//                 // ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   value: _accountStatus,
//                   decoration: InputDecoration(
//                     labelText: 'Account Status',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   items: ['Active', 'Inactive'].map((status) => DropdownMenuItem<String>(
//                         value: status,
//                         child: Text(status, style: GoogleFonts.poppins()),
//                       )).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _accountStatus = value;
//                     });
//                   },
//                   validator: (value) => value == null ? 'Select account status' : null,
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _submitForm,
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
//                             widget.account != null ? 'Update Account' : 'Add Account',
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
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'baseurl.dart';

class AccountInfo extends StatefulWidget {
  const AccountInfo({super.key});

  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  List<dynamic> accounts = [];
  List<dynamic> filteredAccounts = [];
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();

  // Color scheme from checkout.dart
  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

  @override
  void initState() {
    super.initState();
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('$baseUrl/adminAccount/all'));
      if (response.statusCode == 200) {
        setState(() {
          accounts = jsonDecode(response.body);
          filteredAccounts = accounts;
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load accounts: ${response.body}')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching accounts: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteAccount(String accountId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Delete',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
        ),
        content: Text(
          'Are you sure you want to delete this account?',
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

    if (confirmDelete == true) {
      try {
        final response = await http.delete(Uri.parse('$baseUrl/adminAccount/$accountId'));
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully')),
          );
          fetchAccounts();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete account: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      }
    }
  }

  void filterAccounts(String query) {
    setState(() {
      filteredAccounts = accounts.where((account) =>
          account['bankName'].toLowerCase().contains(query.toLowerCase()) ||
          account['accountHolderName'].toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by bank name or account holder',
                      hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: primaryColor),
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
                    onChanged: filterAccounts,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEditAccountPage(),
                        ),
                      ).then((_) => fetchAccounts());
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
                : filteredAccounts.isEmpty
                    ? Center(child: Text('No accounts found', style: GoogleFonts.poppins(fontSize: 16)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        itemCount: filteredAccounts.length,
                        itemBuilder: (context, index) {
                          final account = filteredAccounts[index];
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
                              title: Text(
                                account['bankName'],
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
                              ),
                              subtitle: Text(
                                account['accountHolderName'],
                                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: account['accountStatus'] == 'Active' ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      account['accountStatus'],
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: primaryColor),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddEditAccountPage(account: account),
                                        ),
                                      ).then((_) => fetchAccounts());
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: primaryColor),
                                    onPressed: () => deleteAccount(account['_id']),
                                  ),
                                ],
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

class AddEditAccountPage extends StatefulWidget {
  final Map<String, dynamic>? account;

  const AddEditAccountPage({super.key, this.account});

  @override
  _AddEditAccountPageState createState() => _AddEditAccountPageState();
}

class _AddEditAccountPageState extends State<AddEditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _accountHolderNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String? _accountStatus;
  bool _isLoading = false;

  // Color scheme from checkout.dart
  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _bankNameController.text = widget.account!['bankName'] ?? '';
      _accountHolderNameController.text = widget.account!['accountHolderName'] ?? '';
      _accountNumberController.text = widget.account!['accountNumber'] ?? '';
      _phoneNumberController.text = widget.account!['phoneNumber'] ?? '';
      _accountStatus = widget.account!['accountStatus'] ?? 'Active';
    } else {
      _accountStatus = 'Active';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final accountData = {
        'bankName': _bankNameController.text,
        'accountHolderName': _accountHolderNameController.text,
        'accountNumber': _accountNumberController.text,
        'phoneNumber': _phoneNumberController.text,
        'accountStatus': _accountStatus,
      };

      try {
        if (widget.account != null) {
          // Update existing account
          final response = await http.put(
            Uri.parse('$baseUrl/adminAccount/${widget.account!['_id']}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(accountData),
          );
          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account updated successfully')),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update account: ${response.body}')),
            );
          }
        } else {
          // Add new account
          final response = await http.post(
            Uri.parse('$baseUrl/adminAccount/add'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(accountData),
          );
          if (response.statusCode == 201) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account added successfully')),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add account: ${response.body}')),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
    _bankNameController.dispose();
    _accountHolderNameController.dispose();
    _accountNumberController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          widget.account != null ? 'Edit Account' : 'Add Account',
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
                DropdownButtonFormField<String>(
                  value: _bankNameController.text.isEmpty ? null : _bankNameController.text,
                  decoration: InputDecoration(
                    labelText: 'Select Bank',
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
                  items: [
                    'Commercial Bank of Ethiopia (CBE)',
                    'Awash Bank',
                    'Abay Bank',
                    'Dashin Bank',
                  ].map((bank) => DropdownMenuItem<String>(
                        value: bank,
                        child: Text(bank, style: GoogleFonts.poppins(fontSize: 14)),
                      )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _bankNameController.text = value ?? '';
                    });
                  },
                  validator: (value) => value == null ? 'Select a bank' : null,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _accountHolderNameController,
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
                  validator: (value) => value!.isEmpty ? 'Enter account holder name' : null,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _accountNumberController,
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
                  validator: (value) => value!.isEmpty ? 'Enter account number' : null,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 16),
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
                  validator: (value) => value!.isEmpty ? 'Enter phone number' : null,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _accountStatus,
                  decoration: InputDecoration(
                    labelText: 'Account Status',
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
                  items: ['Active', 'Inactive'].map((status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(status, style: GoogleFonts.poppins(fontSize: 14)),
                      )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _accountStatus = value;
                    });
                  },
                  validator: (value) => value == null ? 'Select account status' : null,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
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
                            widget.account != null ? 'Update Account' : 'Add Account',
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