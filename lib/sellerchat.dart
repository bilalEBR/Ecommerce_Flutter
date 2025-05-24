

// version to update chat 

// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:intl/intl.dart';

// class SellerChatPage extends StatefulWidget {
//   final String chatId;
//   final String productName;
//   final String sellerId;
//   final String token;

//   const SellerChatPage({
//     super.key,
//     required this.chatId,
//     required this.productName,
//     required this.sellerId,
//     required this.token,
//   });

//   @override
//   _SellerChatPageState createState() => _SellerChatPageState();
// }

// class _SellerChatPageState extends State<SellerChatPage> {
//   late IO.Socket socket;
//   final TextEditingController _messageController = TextEditingController();
//   List<Map<String, dynamic>> _messages = [];
//   bool _isLoading = true;
//   bool _isTyping = false;
//   bool _isOnline = false;
//   bool _isChatDetailsLoaded = false;
//   final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';
//   double? _negotiatedPrice;
//   String? _productId;
//   String? _buyerId;
//   double? _originalPrice;
//   Map<String, dynamic>? _currentDiscount;
//   String? _clientName;
//   String? _clientProfileImage;
//   bool _isLoadingClientProfile = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchMessages();
//     _fetchChatDetails();
//     _initializeSocket();
//   }

//   Future<void> _fetchMessages() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/chat/${widget.chatId}'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _messages = List<Map<String, dynamic>>.from(data['messages'] ?? []).map((msg) {
//             return {
//               ...msg,
//               'status': msg['status'] ?? 'sent',
//             };
//           }).toList();
//           _isLoading = false;
//         });

//         _markMessagesAsSeen();
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load messages: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching messages: $e')),
//       );
//     }
//   }

//   Future<void> _fetchChatDetails() async {
//     try {
//       print('Fetching chat details for chatId: ${widget.chatId}');
//       final response = await http.get(
//         Uri.parse('$baseUrl/chat/${widget.chatId}'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       print('Chat details response status: ${response.statusCode}');
//       print('Chat details response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _productId = data['productId']?.toString();
//           _buyerId = data['clientId']?.toString();
//           _isChatDetailsLoaded = _productId != null && _buyerId != null;
//         });
//         print('Fetched productId: $_productId, buyerId: $_buyerId');
//         if (_productId == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Chat details missing productId')),
//           );
//         }
//         if (_buyerId == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Chat details missing clientId')),
//           );
//         }
//         if (_isChatDetailsLoaded) {
//           await _fetchProductDetails();
//           await _fetchCurrentDiscount();
//           await _fetchClientProfile();
//         } else {
//           setState(() {
//             _clientName = 'Unknown Client';
//             _clientProfileImage = null;
//             _isLoadingClientProfile = false;
//           });
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch chat details: ${response.body}')),
//         );
//         setState(() {
//           _clientName = 'Unknown Client';
//           _clientProfileImage = null;
//           _isLoadingClientProfile = false;
//         });
//       }
//     } catch (e) {
//       print('Error fetching chat details: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching chat details: $e')),
//       );
//       setState(() {
//         _clientName = 'Unknown Client';
//         _clientProfileImage = null;
//         _isLoadingClientProfile = false;
//       });
//     }
//   }

//   Future<void> _fetchClientProfile() async {
//     if (_buyerId == null) {
//       print('No buyerId provided');
//       setState(() {
//         _clientName = 'Unknown Client';
//         _clientProfileImage = null;
//         _isLoadingClientProfile = false;
//       });
//       return;
//     }

//     setState(() {
//       _isLoadingClientProfile = true;
//     });

//     try {
//       print('Fetching profile for buyerId: $_buyerId');
//       print('Request URL: $baseUrl/chatprofile/user/$_buyerId');
//       print('Token: ${widget.token.substring(0, 10)}...');
//       final response = await http.get(
//         Uri.parse('$baseUrl/chatprofile/user/$_buyerId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       print('Client profile response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _clientName = (data['firstName']?.isNotEmpty == true || data['lastName']?.isNotEmpty == true)
//               ? '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim()
//               : 'Unknown Client';
//           _clientProfileImage = data['profilePicture'] ?? null;
//           _isLoadingClientProfile = false;
//         });
//         print('Fetched client name: $_clientName, profilePicture: $_clientProfileImage');
//       } else {
//         print('Failed to load client profile: ${response.statusCode} - ${response.body}');
//         setState(() {
//           _clientName = 'Unknown Client';
//           _clientProfileImage = null;
//           _isLoadingClientProfile = false;
//         });
//         String errorMessage;
//         try {
//           final errorBody = jsonDecode(response.body);
//           errorMessage = response.statusCode == 404
//               ? 'User not found'
//               : errorBody['message'] ?? 'Failed to load user profile';
//         } catch (e) {
//           print('Error parsing response body: $e');
//           errorMessage = response.statusCode == 404
//               ? 'User not found'
//               : 'Invalid response from server';
//         }
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(errorMessage)),
//           );
//         }
//       }
//     } catch (e) {
//       print('Error fetching client profile: $e');
//       setState(() {
//         _clientName = 'Unknown Client';
//         _clientProfileImage = null;
//         _isLoadingClientProfile = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching client profile: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _fetchProductDetails() async {
//     if (_productId == null) return;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/client-products?productId=$_productId'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       print('Fetch product details response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data is List && data.isNotEmpty && data[0]['price'] != null) {
//           setState(() {
//             _originalPrice = double.tryParse(data[0]['price'].toString());
//           });
//           if (_originalPrice == null) {
//             print('Failed to parse price from data: ${data[0]['price']}');
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Failed to parse product price')),
//             );
//           } else {
//             print('Fetched original price: $_originalPrice');
//           }
//         } else {
//           print('Product data not found or invalid format: $data');
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Product data not found or invalid format')),
//           );
//         }
//       } else {
//         print('Failed to fetch product details: ${response.body}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch product details: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error fetching product details: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching product details: $e')),
//       );
//     }
//   }

//   Future<void> _fetchCurrentDiscount() async {
//     if (_productId == null || _buyerId == null) return;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/discounts/$_productId/$_buyerId'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       print('Fetch current discount response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           if (data == null || (data is Map && data.isEmpty)) {
//             _currentDiscount = null;
//           } else {
//             _currentDiscount = Map<String, dynamic>.from(data);
//             if (_currentDiscount!['negotiatedPrice'] != null) {
//               _currentDiscount!['negotiatedPrice'] = double.tryParse(_currentDiscount!['negotiatedPrice'].toString()) ?? _currentDiscount!['negotiatedPrice'];
//             }
//           }
//         });
//         print('Fetched current discount: $_currentDiscount');
//       } else {
//         print('Failed to fetch current discount: ${response.body}');
//         setState(() {
//           _currentDiscount = null;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch current discount: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error fetching current discount: $e');
//       setState(() {
//         _currentDiscount = null;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching current discount: $e')),
//       );
//     }
//   }

//   Future<void> _saveDiscount(double price) async {
//     if (_productId == null || _buyerId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error: Product or buyer information missing')),
//       );
//       return;
//     }

//     try {
//       final requestBody = {
//         'productId': _productId,
//         'userId': _buyerId,
//         'negotiatedPrice': price,
//         'chatId': widget.chatId,
//         'expiry': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
//       };
//       print('Sending discount request: $requestBody');

//       final response = await http.post(
//         Uri.parse('$baseUrl/discounts'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${widget.token}',
//         },
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Discount of $price ETB set successfully')),
//         );
//         final messageData = {
//           'chatId': widget.chatId,
//           'senderId': widget.sellerId,
//           'message': 'Discount set to $price ETB!',
//           'timestamp': DateTime.now().toIso8601String(),
//           'isImage': false,
//         };
//         socket.emit('sendMessage', messageData);
//         setState(() {
//           _messages.add({
//             'senderId': widget.sellerId,
//             'message': 'Discount set to $price ETB!',
//             'timestamp': messageData['timestamp'],
//             'status': 'sent',
//             'isImage': false,
//           });
//           _currentDiscount = {
//             'productId': _productId,
//             'userId': _buyerId,
//             'negotiatedPrice': price,
//             'chatId': widget.chatId,
//             'expiry': requestBody['expiry'],
//           };
//         });
//       } else {
//         final errorData = jsonDecode(response.body);
//         String errorMessage = errorData['error'] ?? 'Failed to set discount';
//         if (errorData['missing'] != null) {
//           errorMessage += ': ' + errorData['missing'].entries
//               .where((entry) => entry.value)
//               .map((entry) => entry.key)
//               .join(', ');
//         } else if (errorData['invalid'] != null) {
//           errorMessage += ': ' + errorData['invalid'].entries
//               .where((entry) => entry.value)
//               .map((entry) => entry.key)
//               .join(', ');
//         } else if (errorData['userId'] != null) {
//           errorMessage += ' (userId: ${errorData['userId']})';
//         } else if (errorData['productId'] != null) {
//           errorMessage += ' (productId: ${errorData['productId']})';
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage)),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error setting discount: $e')),
//       );
//     }
//   }

//   Future<void> _deleteDiscount() async {
//     if (_productId == null || _buyerId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error: Product or buyer information missing')),
//       );
//       return;
//     }

//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/discounts/$_productId/$_buyerId'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       print('Delete discount response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Discount deleted successfully')),
//         );
//         final messageData = {
//           'chatId': widget.chatId,
//           'senderId': widget.sellerId,
//           'message': 'Discount has been removed.',
//           'timestamp': DateTime.now().toIso8601String(),
//           'isImage': false,
//         };
//         socket.emit('sendMessage', messageData);
//         setState(() {
//           _messages.add({
//             'senderId': widget.sellerId,
//             'message': 'Discount has been removed.',
//             'timestamp': messageData['timestamp'],
//             'status': 'sent',
//             'isImage': false,
//           });
//           _currentDiscount = null;
//         });
//       } else {
//         final errorData = jsonDecode(response.body);
//         final errorMessage = errorData['error'] ?? 'Failed to delete discount';
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage)),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting discount: $e')),
//       );
//     }
//   }

//   void _initializeSocket() {
//     socket = IO.io(baseUrl, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });

//     socket.connect();

//     socket.onConnect((_) {
//       print('Seller connected to Socket.io server');
//       socket.emit('joinChat', widget.chatId);
//       socket.emit('online', widget.chatId);
//     });

//     socket.on('receiveMessage', (data) {
//       if (data['senderId'] != widget.sellerId) {
//         setState(() {
//           _messages.add({
//             'senderId': data['senderId'],
//             'message': data['message'],
//             'timestamp': data['timestamp'],
//             'status': 'sent',
//             'isImage': data['isImage'] ?? false,
//           });
//         });
//         print('Emitting messageSeen for timestamp: ${data['timestamp']}');
//         socket.emit('messageSeen', {
//           'chatId': widget.chatId,
//           'messageTimestamp': data['timestamp'],
//         });
//       }
//     });

//     socket.on('messageSeen', (data) {
//       print('Received messageSeen: $data');
//       if (data['messageTimestamp'] != null && data['chatId'] == widget.chatId) {
//         try {
//           final receivedTime = DateTime.parse(data['messageTimestamp']);
//           setState(() {
//             _messages = _messages.map((msg) {
//               final msgTime = DateTime.parse(msg['timestamp']);
//               final timeDiff = receivedTime.difference(msgTime).inMilliseconds.abs();
//               print('Comparing msgTimestamp: ${msg['timestamp']} with receivedTimestamp: ${data['messageTimestamp']} (diff: $timeDiff ms)');
//               if (timeDiff < 1000 && msg['senderId'] == widget.sellerId) {
//                 return {...msg, 'status': 'seen'};
//               }
//               return msg;
//             }).toList();
//           });
//         } catch (e) {
//           print('Error parsing messageSeen timestamp: $e');
//         }
//       } else {
//         print('Invalid messageSeen data: $data');
//       }
//     });

//     socket.on('typing', (data) {
//       setState(() {
//         _isTyping = true;
//       });
//       Future.delayed(const Duration(seconds: 3), () {
//         if (mounted) {
//           setState(() {
//             _isTyping = false;
//           });
//         }
//       });
//     });

//     socket.on('online', (_) {
//       setState(() {
//         _isOnline = true;
//       });
//     });

//     socket.on('offline', (_) {
//       setState(() {
//         _isOnline = false;
//       });
//     });

//     socket.onDisconnect((_) {
//       print('Seller disconnected from Socket.io server');
//       socket.emit('offline', widget.chatId);
//     });

//     socket.onError((error) {
//       print('Socket.io error: $error');
//     });

//     socket.onAny((event, data) {
//       print('Socket event: $event, data: $data');
//     });
//   }

//   void _markMessagesAsSeen() {
//     for (var msg in _messages) {
//       if (msg['status'] == 'sent' && msg['senderId'] != widget.sellerId) {
//         print('Marking message as seen on load: ${msg['timestamp']}');
//         socket.emit('messageSeen', {
//           'chatId': widget.chatId,
//           'messageTimestamp': msg['timestamp'],
//         });
//       }
//     }
//   }

//   void _sendMessage() {
//     if (_messageController.text.trim().isEmpty) return;

//     final messageData = {
//       'chatId': widget.chatId,
//       'senderId': widget.sellerId,
//       'message': _messageController.text.trim(),
//       'timestamp': DateTime.now().toIso8601String(),
//       'isImage': false,
//     };

//     socket.emit('sendMessage', messageData);

//     setState(() {
//       _messages.add({
//         'senderId': widget.sellerId,
//         'message': _messageController.text.trim(),
//         'timestamp': messageData['timestamp'],
//         'status': 'sent',
//         'isImage': false,
//       });
//     });

//     _messageController.clear();
//   }

//   Future<void> _sendImage() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.image,
//         allowMultiple: false,
//       );
//       if (result != null && result.files.isNotEmpty) {
//         final file = result.files.first;

//         final request = http.MultipartRequest(
//           'POST',
//           Uri.parse('$baseUrl/upload'),
//         );
//         request.headers['Authorization'] = 'Bearer ${widget.token}';
//         final bytes = file.bytes ?? await file.readStream!.first;
//         request.files.add(
//           http.MultipartFile.fromBytes(
//             'file',
//             bytes,
//             filename: file.name,
//             contentType: MediaType('image', file.extension ?? 'jpeg'),
//           ),
//         );

//         final response = await request.send();
//         final responseBody = await http.Response.fromStream(response);

//         if (response.statusCode == 200) {
//           final data = jsonDecode(responseBody.body);
//           final imageUrl = data['filePath'];

//           final messageData = {
//             'chatId': widget.chatId,
//             'senderId': widget.sellerId,
//             'message': imageUrl,
//             'timestamp': DateTime.now().toIso8601String(),
//             'isImage': true,
//           };

//           socket.emit('sendMessage', messageData);

//           setState(() {
//             _messages.add({
//               'senderId': widget.sellerId,
//               'message': imageUrl,
//               'timestamp': messageData['timestamp'],
//               'status': 'sent',
//               'isImage': true,
//             });
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to upload image: ${responseBody.body}')),
//           );
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error uploading image: $e')),
//       );
//     }
//   }

//   void _showDiscountDialog() {
//     if (!_isChatDetailsLoaded) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please wait, loading chat details...')),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Set Negotiated Price'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (_originalPrice != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: Text(
//                   'Original Price: ${_originalPrice!.toStringAsFixed(2)} ETB',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ),
//             if (_currentDiscount != null && _currentDiscount!['negotiatedPrice'] != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: Text(
//                   'Current Discount: ${_currentDiscount!['negotiatedPrice'].toStringAsFixed(2)} ETB',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     color: Colors.green,
//                   ),
//                 ),
//               ),
//             TextField(
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'New Price (ETB)',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (value) {
//                 _negotiatedPrice = double.tryParse(value);
//               },
//             ),
//           ],
//         ),
//         actions: [
//           if (_currentDiscount != null && _currentDiscount!['negotiatedPrice'] != null)
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _deleteDiscount();
//               },
//               child: const Text(
//                 'Delete Discount',
//                 style: TextStyle(color: Colors.red),
//               ),
//             ),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               if (_negotiatedPrice != null && _negotiatedPrice! > 0) {
//                 _saveDiscount(_negotiatedPrice!);
//                 Navigator.pop(context);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Please enter a valid positive price')),
//                 );
//               }
//             },
//             child: const Text('Confirm'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     socket.emit('offline', widget.chatId);
//     socket.disconnect();
//     socket.dispose();
//     _messageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color.fromARGB(255, 62, 62, 147),
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundImage: _clientProfileImage != null && _clientProfileImage!.isNotEmpty
//                       ? NetworkImage('$baseUrl$_clientProfileImage')
//                       : null,
//                   backgroundColor: Colors.grey[300],
//                   child: _clientProfileImage == null || _clientProfileImage!.isEmpty
//                       ? const Icon(Icons.person, color: Colors.grey, size: 30)
//                       : null,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   _isLoadingClientProfile
//                       ? 'Loading...'
//                       : (_clientName ?? 'Unknown Client'),
//                   style: GoogleFonts.poppins(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Container(
//                   width: 10,
//                   height: 10,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: _isOnline ? Colors.green : Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(width: 5),
//                 Text(
//                   _isOnline ? 'Online' : 'Offline',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.white70,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _messages.isEmpty
//                     ? const Center(
//                         child: Text(
//                           'No messages yet',
//                           style: TextStyle(fontSize: 18, color: Colors.grey),
//                         ),
//                       )
//                     : ListView.builder(
//                         padding: const EdgeInsets.all(16.0),
//                         itemCount: _buildMessageItems().length,
//                         itemBuilder: (context, index) {
//                           final item = _buildMessageItems()[index];
//                           if (item['type'] == 'date') {
//                             return Center(
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                                 child: Text(
//                                   item['date'],
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }

//                           final message = item['message'];
//                           final isSender = message['senderId'] == widget.sellerId;
//                           return Align(
//                             alignment: isSender
//                                 ? Alignment.centerRight
//                                 : Alignment.centerLeft,
//                             child: Column(
//                               crossAxisAlignment: isSender
//                                   ? CrossAxisAlignment.end
//                                   : CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   margin: const EdgeInsets.symmetric(vertical: 4.0),
//                                   padding: const EdgeInsets.all(12.0),
//                                   decoration: BoxDecoration(
//                                     color: isSender ? Color.fromARGB(255, 62, 62, 147) : Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(12.0),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: isSender
//                                         ? CrossAxisAlignment.end
//                                         : CrossAxisAlignment.start,
//                                     children: [
//                                       if (message['isImage'] == true)
//                                         Image.network(
//                                           '$baseUrl${message['message']}',
//                                           width: 150,
//                                           height: 150,
//                                           fit: BoxFit.cover,
//                                           errorBuilder: (context, error, stackTrace) =>
//                                               const Text('Error loading image'),
//                                         )
//                                       else
//                                         Text(
//                                           message['message'],
//                                           style: GoogleFonts.poppins(
//                                             color: isSender ? Colors.white : Colors.black,
//                                             fontSize: 14,
//                                           ),
//                                         ),
//                                       if (isSender)
//                                         Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Icon(
//                                               message['status'] == 'seen'
//                                                   ? Icons.done_all
//                                                   : Icons.done,
//                                               size: 14,
//                                               color: message['status'] == 'seen'
//                                                   ? Colors.blue
//                                                   : Colors.grey,
//                                             ),
//                                           ],
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 2.0),
//                                   child: Text(
//                                     _formatDateTime(message['timestamp']),
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 10,
//                                       color: Colors.black54,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//           ),
//           if (_isTyping)
//             Padding(
//               padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'Typing...',
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.attach_file, color: Color.fromARGB(255, 62, 62, 147)),
//                   onPressed: _sendImage,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.discount, color: Color.fromARGB(255, 62, 62, 147)),
//                   onPressed: _isChatDetailsLoaded ? _showDiscountDialog : null,
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onChanged: (value) {
//                       socket.emit('typing', widget.chatId);
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: Color.fromARGB(255, 62, 62, 147)),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<Map<String, dynamic>> _buildMessageItems() {
//     List<Map<String, dynamic>> items = [];
//     DateTime? lastDate;

//     for (var message in _messages) {
//       final messageDate = DateTime.parse(message['timestamp']).toLocal();
//       final now = DateTime.now();
//       final messageDay = DateTime(messageDate.year, messageDate.month, messageDate.day);
//       final today = DateTime(now.year, now.month, now.day);

//       if (lastDate == null || messageDay != lastDate) {
//         String dateLabel;
//         if (messageDay == today) {
//           dateLabel = 'Today';
//         } else {
//           dateLabel = DateFormat('MMMM d, yyyy').format(messageDay);
//         }
//         items.add({'type': 'date', 'date': dateLabel});
//         lastDate = messageDay;
//       }

//       items.add({'type': 'message', 'message': message});
//     }

//     return items;
//   }

//   String _formatDateTime(String dateTime) {
//     final date = DateTime.parse(dateTime).toLocal();
//     return DateFormat('hh:mm a').format(date);
//   }
// }



// version to update some ui



// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:intl/intl.dart';

// class SellerChatPage extends StatefulWidget {
//   final String chatId;
//   final String productName;
//   final String sellerId;
//   final String token;

//   const SellerChatPage({
//     super.key,
//     required this.chatId,
//     required this.productName,
//     required this.sellerId,
//     required this.token,
//   });

//   @override
//   _SellerChatPageState createState() => _SellerChatPageState();
// }

// class _SellerChatPageState extends State<SellerChatPage> {
//   late IO.Socket socket;
//   final TextEditingController _messageController = TextEditingController();
//   List<Map<String, dynamic>> _messages = [];
//   bool _isLoading = true;
//   bool _isTyping = false;
//   bool _isOnline = false;
//   bool _isChatDetailsLoaded = false;
//   final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';
//   double? _negotiatedPrice;
//   String? _productId;
//   String? _buyerId;
//   double? _originalPrice;
//   Map<String, dynamic>? _currentDiscount;
//   String? _clientName;
//   String? _clientProfileImage;
//   bool _isLoadingClientProfile = false;
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _fetchMessages();
//     _fetchChatDetails();
//     _initializeSocket();
//   }

//   Future<void> _fetchMessages() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/chat/${widget.chatId}'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _messages = List<Map<String, dynamic>>.from(data['messages'] ?? []).map((msg) {
//             final messageContent = msg['message']?.toString() ?? '';
//             final isImage = msg['isImage'] ??
//                 (messageContent.startsWith('/upload/') ||
//                     RegExp(r'\.(jpg|jpeg|png|gif)$', caseSensitive: false).hasMatch(messageContent));
//             print('Fetched message: $messageContent, isImage: $isImage');
//             return {
//               ...msg,
//               'status': msg['status'] ?? 'sent',
//               'isImage': isImage,
//             };
//           }).toList();
//           _isLoading = false;
//         });

//         // Scroll to the bottom after messages are loaded
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (_scrollController.hasClients) {
//             _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//           }
//         });

//         _markMessagesAsSeen();
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load messages: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching messages: $e')),
//       );
//     }
//   }

//   Future<void> _fetchChatDetails() async {
//     try {
//       print('Fetching chat details for chatId: ${widget.chatId}');
//       final response = await http.get(
//         Uri.parse('$baseUrl/chat/${widget.chatId}'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       print('Chat details response status: ${response.statusCode}');
//       print('Chat details response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _productId = data['productId']?.toString();
//           _buyerId = data['clientId']?.toString();
//           _isChatDetailsLoaded = _productId != null && _buyerId != null;
//         });
//         print('Fetched productId: $_productId, buyerId: $_buyerId');
//         if (_productId == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Chat details missing productId')),
//           );
//         }
//         if (_buyerId == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Chat details missing clientId')),
//           );
//         }
//         if (_isChatDetailsLoaded) {
//           await _fetchProductDetails();
//           await _fetchCurrentDiscount();
//           await _fetchClientProfile();
//         } else {
//           setState(() {
//             _clientName = 'Unknown Client';
//             _clientProfileImage = null;
//             _isLoadingClientProfile = false;
//           });
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch chat details: ${response.body}')),
//         );
//         setState(() {
//           _clientName = 'Unknown Client';
//           _clientProfileImage = null;
//           _isLoadingClientProfile = false;
//         });
//       }
//     } catch (e) {
//       print('Error fetching chat details: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching chat details: $e')),
//       );
//       setState(() {
//         _clientName = 'Unknown Client';
//         _clientProfileImage = null;
//         _isLoadingClientProfile = false;
//       });
//     }
//   }

//   Future<void> _fetchClientProfile() async {
//     if (_buyerId == null) {
//       print('No buyerId provided');
//       setState(() {
//         _clientName = 'Unknown Client';
//         _clientProfileImage = null;
//         _isLoadingClientProfile = false;
//       });
//       return;
//     }

//     setState(() {
//       _isLoadingClientProfile = true;
//     });

//     try {
//       print('Fetching profile for buyerId: $_buyerId');
//       print('Request URL: $baseUrl/chatprofile/user/$_buyerId');
//       print('Token: ${widget.token.substring(0, 10)}...');
//       final response = await http.get(
//         Uri.parse('$baseUrl/chatprofile/user/$_buyerId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       print('Client profile response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _clientName = (data['firstName']?.isNotEmpty == true || data['lastName']?.isNotEmpty == true)
//               ? '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim()
//               : 'Unknown Client';
//           _clientProfileImage = data['profilePicture'] ?? null;
//           _isLoadingClientProfile = false;
//         });
//         print('Fetched client name: $_clientName, profilePicture: $_clientProfileImage');
//       } else {
//         print('Failed to load client profile: ${response.statusCode} - ${response.body}');
//         setState(() {
//           _clientName = 'Unknown Client';
//           _clientProfileImage = null;
//           _isLoadingClientProfile = false;
//         });
//         String errorMessage;
//         try {
//           final errorBody = jsonDecode(response.body);
//           errorMessage = response.statusCode == 404
//               ? 'User not found'
//               : errorBody['message'] ?? 'Failed to load user profile';
//         } catch (e) {
//           print('Error parsing response body: $e');
//           errorMessage = response.statusCode == 404
//               ? 'User not found'
//               : 'Invalid response from server';
//         }
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(errorMessage)),
//           );
//         }
//       }
//     } catch (e) {
//       print('Error fetching client profile: $e');
//       setState(() {
//         _clientName = 'Unknown Client';
//         _clientProfileImage = null;
//         _isLoadingClientProfile = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching client profile: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _fetchProductDetails() async {
//     if (_productId == null) return;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/client-products?productId=$_productId'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       print('Fetch product details response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data is List && data.isNotEmpty && data[0]['price'] != null) {
//           setState(() {
//             _originalPrice = double.tryParse(data[0]['price'].toString());
//           });
//           if (_originalPrice == null) {
//             print('Failed to parse price from data: ${data[0]['price']}');
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Failed to parse product price')),
//             );
//           } else {
//             print('Fetched original price: $_originalPrice');
//           }
//         } else {
//           print('Product data not found or invalid format: $data');
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Product data not found or invalid format')),
//           );
//         }
//       } else {
//         print('Failed to fetch product details: ${response.body}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch product details: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error fetching product details: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching product details: $e')),
//       );
//     }
//   }

//   Future<void> _fetchCurrentDiscount() async {
//     if (_productId == null || _buyerId == null) return;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/discounts/$_productId/$_buyerId'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       print('Fetch current discount response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           if (data == null || (data is Map && data.isEmpty)) {
//             _currentDiscount = null;
//           } else {
//             _currentDiscount = Map<String, dynamic>.from(data);
//             if (_currentDiscount!['negotiatedPrice'] != null) {
//               _currentDiscount!['negotiatedPrice'] = double.tryParse(_currentDiscount!['negotiatedPrice'].toString()) ?? _currentDiscount!['negotiatedPrice'];
//             }
//           }
//         });
//         print('Fetched current discount: $_currentDiscount');
//       } else {
//         print('Failed to fetch current discount: ${response.body}');
//         setState(() {
//           _currentDiscount = null;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch current discount: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error fetching current discount: $e');
//       setState(() {
//         _currentDiscount = null;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching current discount: $e')),
//       );
//     }
//   }

//   Future<void> _saveDiscount(double price) async {
//     if (_productId == null || _buyerId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error: Product or buyer information missing')),
//       );
//       return;
//     }

//     try {
//       final requestBody = {
//         'productId': _productId,
//         'userId': _buyerId,
//         'negotiatedPrice': price,
//         'chatId': widget.chatId,
//         'expiry': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
//       };
//       print('Sending discount request: $requestBody');

//       final response = await http.post(
//         Uri.parse('$baseUrl/discounts'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${widget.token}',
//         },
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Discount of $price ETB set successfully')),
//         );
//         final messageData = {
//           'chatId': widget.chatId,
//           'senderId': widget.sellerId,
//           'message': 'Discount set to $price ETB!',
//           'timestamp': DateTime.now().toIso8601String(),
//           'isImage': false,
//         };
//         socket.emit('sendMessage', messageData);
//         setState(() {
//           _messages.add({
//             'senderId': widget.sellerId,
//             'message': 'Discount set to $price ETB!',
//             'timestamp': messageData['timestamp'],
//             'status': 'sent',
//             'isImage': false,
//           });
//           _currentDiscount = {
//             'productId': _productId,
//             'userId': _buyerId,
//             'negotiatedPrice': price,
//             'chatId': widget.chatId,
//             'expiry': requestBody['expiry'],
//           };
//         });
//         // Scroll to the bottom after sending discount message
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (_scrollController.hasClients) {
//             _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//           }
//         });
//       } else {
//         final errorData = jsonDecode(response.body);
//         String errorMessage = errorData['error'] ?? 'Failed to set discount';
//         if (errorData['missing'] != null) {
//           errorMessage += ': ' + errorData['missing'].entries
//               .where((entry) => entry.value)
//               .map((entry) => entry.key)
//               .join(', ');
//         } else if (errorData['invalid'] != null) {
//           errorMessage += ': ' + errorData['invalid'].entries
//               .where((entry) => entry.value)
//               .map((entry) => entry.key)
//               .join(', ');
//         } else if (errorData['userId'] != null) {
//           errorMessage += ' (userId: ${errorData['userId']})';
//         } else if (errorData['productId'] != null) {
//           errorMessage += ' (productId: ${errorData['productId']})';
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage)),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error setting discount: $e')),
//       );
//     }
//   }

//   Future<void> _deleteDiscount() async {
//     if (_productId == null || _buyerId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error: Product or buyer information missing')),
//       );
//       return;
//     }

//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/discounts/$_productId/$_buyerId'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       print('Delete discount response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Discount deleted successfully')),
//         );
//         final messageData = {
//           'chatId': widget.chatId,
//           'senderId': widget.sellerId,
//           'message': 'Discount has been removed.',
//           'timestamp': DateTime.now().toIso8601String(),
//           'isImage': false,
//         };
//         socket.emit('sendMessage', messageData);
//         setState(() {
//           _messages.add({
//             'senderId': widget.sellerId,
//             'message': 'Discount has been removed.',
//             'timestamp': messageData['timestamp'],
//             'status': 'sent',
//             'isImage': false,
//           });
//           _currentDiscount = null;
//         });
//         // Scroll to the bottom after sending discount message
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (_scrollController.hasClients) {
//             _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//           }
//         });
//       } else {
//         final errorData = jsonDecode(response.body);
//         final errorMessage = errorData['error'] ?? 'Failed to delete discount';
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage)),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting discount: $e')),
//       );
//     }
//   }

//   void _initializeSocket() {
//     socket = IO.io(baseUrl, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });

//     socket.connect();

//     socket.onConnect((_) {
//       print('Seller connected to Socket.io server');
//       socket.emit('joinChat', widget.chatId);
//       socket.emit('online', widget.chatId);
//     });

//     socket.on('receiveMessage', (data) {
//       if (data['senderId'] != widget.sellerId) {
//         final messageContent = data['message']?.toString() ?? '';
//         final isImage = data['isImage'] ??
//             (messageContent.startsWith('/upload/') ||
//                 RegExp(r'\.(jpg|jpeg|png|gif)$', caseSensitive: false).hasMatch(messageContent));
//         print('Received message: $messageContent, isImage: $isImage');
//         setState(() {
//           _messages.add({
//             'senderId': data['senderId'],
//             'message': messageContent,
//             'timestamp': data['timestamp'],
//             'status': 'sent',
//             'isImage': isImage,
//           });
//         });
//         // Scroll to the bottom when a new message is received
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (_scrollController.hasClients) {
//             _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//           }
//         });
//         print('Emitting messageSeen for timestamp: ${data['timestamp']}');
//         socket.emit('messageSeen', {
//           'chatId': widget.chatId,
//           'messageTimestamp': data['timestamp'],
//         });
//       }
//     });

//     socket.on('messageSeen', (data) {
//       print('Received messageSeen: $data');
//       if (data['messageTimestamp'] != null && data['chatId'] == widget.chatId) {
//         try {
//           final receivedTime = DateTime.parse(data['messageTimestamp']);
//           setState(() {
//             _messages = _messages.map((msg) {
//               final msgTime = DateTime.parse(msg['timestamp']);
//               final timeDiff = receivedTime.difference(msgTime).inMilliseconds.abs();
//               print('Comparing msgTimestamp: ${msg['timestamp']} with receivedTimestamp: ${data['messageTimestamp']} (diff: $timeDiff ms)');
//               if (timeDiff < 1000 && msg['senderId'] == widget.sellerId) {
//                 return {...msg, 'status': 'seen'};
//               }
//               return msg;
//             }).toList();
//           });
//         } catch (e) {
//           print('Error parsing messageSeen timestamp: $e');
//         }
//       } else {
//         print('Invalid messageSeen data: $data');
//       }
//     });

//     socket.on('typing', (data) {
//       setState(() {
//         _isTyping = true;
//       });
//       Future.delayed(const Duration(seconds: 3), () {
//         if (mounted) {
//           setState(() {
//             _isTyping = false;
//           });
//         }
//       });
//     });

//     socket.on('online', (_) {
//       setState(() {
//         _isOnline = true;
//       });
//     });

//     socket.on('offline', (_) {
//       setState(() {
//         _isOnline = false;
//       });
//     });

//     socket.onDisconnect((_) {
//       print('Seller disconnected from Socket.io server');
//       socket.emit('offline', widget.chatId);
//     });

//     socket.onError((error) {
//       print('Socket.io error: $error');
//     });

//     socket.onAny((event, data) {
//       print('Socket event: $event, data: $data');
//     });
//   }

//   void _markMessagesAsSeen() {
//     for (var msg in _messages) {
//       if (msg['status'] == 'sent' && msg['senderId'] != widget.sellerId) {
//         print('Marking message as seen on load: ${msg['timestamp']}');
//         socket.emit('messageSeen', {
//           'chatId': widget.chatId,
//           'messageTimestamp': msg['timestamp'],
//         });
//       }
//     }
//   }

//   void _sendMessage() {
//     if (_messageController.text.trim().isEmpty) return;

//     final messageData = {
//       'chatId': widget.chatId,
//       'senderId': widget.sellerId,
//       'message': _messageController.text.trim(),
//       'timestamp': DateTime.now().toIso8601String(),
//       'isImage': false,
//     };

//     socket.emit('sendMessage', messageData);

//     setState(() {
//       _messages.add({
//         'senderId': widget.sellerId,
//         'message': _messageController.text.trim(),
//         'timestamp': messageData['timestamp'],
//         'status': 'sent',
//         'isImage': false,
//       });
//     });

//     // Scroll to the bottom after sending a message
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//       }
//     });

//     _messageController.clear();
//   }

//   Future<void> _sendImage() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.image,
//         allowMultiple: false,
//       );
//       if (result != null && result.files.isNotEmpty) {
//         final file = result.files.first;

//         final request = http.MultipartRequest(
//           'POST',
//           Uri.parse('$baseUrl/upload'),
//         );
//         request.headers['Authorization'] = 'Bearer ${widget.token}';
//         final bytes = file.bytes ?? await file.readStream!.first;
//         request.files.add(
//           http.MultipartFile.fromBytes(
//             'file',
//             bytes,
//             filename: file.name,
//             contentType: MediaType('image', file.extension ?? 'jpeg'),
//           ),
//         );

//         final response = await request.send();
//         final responseBody = await http.Response.fromStream(response);

//         if (response.statusCode == 200) {
//           final data = jsonDecode(responseBody.body);
//           final imageUrl = data['filePath'];
//           print('Sent image URL: $imageUrl');

//           final messageData = {
//             'chatId': widget.chatId,
//             'senderId': widget.sellerId,
//             'message': imageUrl,
//             'timestamp': DateTime.now().toIso8601String(),
//             'isImage': true,
//           };

//           socket.emit('sendMessage', messageData);

//           setState(() {
//             _messages.add({
//               'senderId': widget.sellerId,
//               'message': imageUrl,
//               'timestamp': messageData['timestamp'],
//               'status': 'sent',
//               'isImage': true,
//             });
//           });

//           // Scroll to the bottom after sending an image
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (_scrollController.hasClients) {
//               _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//             }
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to upload image: ${responseBody.body}')),
//           );
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error uploading image: $e')),
//       );
//     }
//   }

//   void _showDiscountDialog() {
//     if (!_isChatDetailsLoaded) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please wait, loading chat details...')),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Set Negotiated Price'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (_originalPrice != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: Text(
//                   'Original Price: ${_originalPrice!.toStringAsFixed(2)} ETB',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ),
//             if (_currentDiscount != null && _currentDiscount!['negotiatedPrice'] != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: Text(
//                   'Current Discount: ${_currentDiscount!['negotiatedPrice'].toStringAsFixed(2)} ETB',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     color: Colors.green,
//                   ),
//                 ),
//               ),
//             TextField(
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'New Price (ETB)',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (value) {
//                 _negotiatedPrice = double.tryParse(value);
//               },
//             ),
//           ],
//         ),
//         actions: [
//           if (_currentDiscount != null && _currentDiscount!['negotiatedPrice'] != null)
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _deleteDiscount();
//               },
//               child: const Text(
//                 'Delete Discount',
//                 style: TextStyle(color: Colors.red),
//               ),
//             ),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               if (_negotiatedPrice != null && _negotiatedPrice! > 0) {
//                 _saveDiscount(_negotiatedPrice!);
//                 Navigator.pop(context);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Please enter a valid positive price')),
//                 );
//               }
//             },
//             child: const Text('Confirm'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     socket.emit('offline', widget.chatId);
//     socket.disconnect();
//     socket.dispose();
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color.fromARGB(255, 62, 62, 147),
//         iconTheme: IconThemeData(color: Colors.white), // Set back arrow to white
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundImage: _clientProfileImage != null && _clientProfileImage!.isNotEmpty
//                       ? NetworkImage('$baseUrl$_clientProfileImage?t=${DateTime.now().millisecondsSinceEpoch}')
//                       : null,
//                   backgroundColor: Colors.grey[300],
//                   child: _clientProfileImage == null || _clientProfileImage!.isEmpty
//                       ? const Icon(Icons.person, color: Colors.grey, size: 30)
//                       : null,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   _isLoadingClientProfile
//                       ? 'Loading...'
//                       : (_clientName ?? 'Unknown Client'),
//                   style: GoogleFonts.poppins(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Container(
//                   width: 10,
//                   height: 10,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: _isOnline ? Colors.green : Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(width: 5),
//                 Text(
//                   _isOnline ? 'Online' : 'Offline',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.white70,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _messages.isEmpty
//                     ? const Center(
//                         child: Text(
//                           'No messages yet',
//                           style: TextStyle(fontSize: 18, color: Colors.grey),
//                         ),
//                       )
//                     : ListView.builder(
//                         controller: _scrollController,
//                         padding: const EdgeInsets.all(16.0),
//                         itemCount: _buildMessageItems().length,
//                         itemBuilder: (context, index) {
//                           final item = _buildMessageItems()[index];
//                           if (item['type'] == 'date') {
//                             return Center(
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                                 child: Text(
//                                   item['date'],
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }

//                           final message = item['message'];
//                           final isSender = message['senderId'] == widget.sellerId;
//                           final messageContent = message['message']?.toString() ?? '';
//                           final imageUrl = '$baseUrl$messageContent?t=${DateTime.now().millisecondsSinceEpoch}';
//                           print('Rendering message: $messageContent, isImage: ${message['isImage']}, URL: $imageUrl');

//                           return Align(
//                             alignment: isSender
//                                 ? Alignment.centerRight
//                                 : Alignment.centerLeft,
//                             child: Column(
//                               crossAxisAlignment: isSender
//                                   ? CrossAxisAlignment.end
//                                   : CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   margin: const EdgeInsets.symmetric(vertical: 4.0),
//                                   padding: const EdgeInsets.all(12.0),
//                                   decoration: BoxDecoration(
//                                     color: isSender ? Color.fromARGB(255, 62, 62, 147) : Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(12.0),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: isSender
//                                         ? CrossAxisAlignment.end
//                                         : CrossAxisAlignment.start,
//                                     children: [
//                                       if (message['isImage'] == true)
//                                         Image.network(
//                                           imageUrl,
//                                           width: 150,
//                                           height: 150,
//                                           fit: BoxFit.cover,
//                                           errorBuilder: (context, error, stackTrace) {
//                                             print('Image load error for $imageUrl: $error');
//                                             return Text(
//                                               'Failed to load image: $messageContent',
//                                               style: GoogleFonts.poppins(
//                                                 color: isSender ? Colors.white : Colors.black,
//                                                 fontSize: 14,
//                                               ),
//                                             );
//                                           },
//                                         )
//                                       else
//                                         Text(
//                                           messageContent,
//                                           style: GoogleFonts.poppins(
//                                             color: isSender ? Colors.white : Colors.black,
//                                             fontSize: 14,
//                                           ),
//                                         ),
//                                       if (isSender)
//                                         Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Icon(
//                                               message['status'] == 'seen'
//                                                   ? Icons.done_all
//                                                   : Icons.done,
//                                               size: 14,
//                                               color: message['status'] == 'seen'
//                                                   ? Colors.blue
//                                                   : Colors.grey,
//                                             ),
//                                           ],
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 2.0),
//                                   child: Text(
//                                     _formatDateTime(message['timestamp']),
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 10,
//                                       color: Colors.black54,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//           ),
//           if (_isTyping)
//             Padding(
//               padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'Typing...',
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.attach_file, color: Color.fromARGB(255, 62, 62, 147)),
//                   onPressed: _sendImage,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.discount, color: Color.fromARGB(255, 62, 62, 147)),
//                   onPressed: _isChatDetailsLoaded ? _showDiscountDialog : null,
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onChanged: (value) {
//                       socket.emit('typing', widget.chatId);
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: Color.fromARGB(255, 62, 62, 147)),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<Map<String, dynamic>> _buildMessageItems() {
//     List<Map<String, dynamic>> items = [];
//     DateTime? lastDate;

//     for (var message in _messages) {
//       final messageDate = DateTime.parse(message['timestamp']).toLocal();
//       final now = DateTime.now();
//       final messageDay = DateTime(messageDate.year, messageDate.month, messageDate.day);
//       final today = DateTime(now.year, now.month, now.day);

//       if (lastDate == null || messageDay != lastDate) {
//         String dateLabel;
//         if (messageDay == today) {
//           dateLabel = 'Today';
//         } else {
//           dateLabel = DateFormat('MMMM d, yyyy').format(messageDay);
//         }
//         items.add({'type': 'date', 'date': dateLabel});
//         lastDate = messageDay;
//       }

//       items.add({'type': 'message', 'message': message});
//     }

//     return items;
//   }

//   String _formatDateTime(String dateTime) {
//     final date = DateTime.parse(dateTime).toLocal();
//     return DateFormat('hh:mm a').format(date);
//   }
// }

// refresh 

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String? profileImage;
  final String baseUrl;
  final bool isOnline;
  final bool isLoading;

  const ProfileHeader({
    Key? key,
    required this.name,
    this.profileImage,
    required this.baseUrl,
    required this.isOnline,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Building ProfileHeader for $name');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: profileImage != null && profileImage!.isNotEmpty
                  ? NetworkImage(profileImage!)
                  : null,
              backgroundColor: Colors.grey[300],
              child: profileImage == null || profileImage!.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey, size: 30)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              isLoading ? 'Loading...' : name,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              isOnline ? 'Online' : 'Offline',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SellerChatPage extends StatefulWidget {
  final String chatId;
  final String productName;
  final String sellerId;
  final String token;

  const SellerChatPage({
    super.key,
    required this.chatId,
    required this.productName,
    required this.sellerId,
    required this.token,
  });

  @override
  _SellerChatPageState createState() => _SellerChatPageState();
}

class _SellerChatPageState extends State<SellerChatPage> {
  late IO.Socket socket;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  bool _isOnline = false;
  bool _isChatDetailsLoaded = false;
  final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';
  double? _negotiatedPrice;
  String? _productId;
  String? _buyerId;
  double? _originalPrice;
  Map<String, dynamic>? _currentDiscount;
  String? _clientName;
  String? _clientProfileImage;
  bool _isLoadingClientProfile = false;
  bool _isProfileLoaded = false;
  final ScrollController _scrollController = ScrollController();
  late String _profileImageUrl; // Memoized profile image URL

  @override
  void initState() {
    super.initState();
    _profileImageUrl = '';
    _fetchMessages();
    _fetchChatDetails();
    _initializeSocket();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/${widget.chatId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages = List<Map<String, dynamic>>.from(data['messages'] ?? []).map((msg) {
            final messageContent = msg['message']?.toString() ?? '';
            final isImage = msg['isImage'] ??
                (messageContent.startsWith('/upload/') ||
                    RegExp(r'\.(jpg|jpeg|png|gif)$', caseSensitive: false).hasMatch(messageContent));
            print('Fetched message: $messageContent, isImage: $isImage');
            return {
              ...msg,
              'status': msg['status'] ?? 'sent',
              'isImage': isImage,
            };
          }).toList();
          _isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });

        _markMessagesAsSeen();
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load messages: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching messages: $e')),
      );
    }
  }

  Future<void> _fetchChatDetails() async {
    if (_isProfileLoaded) {
      print('Profile already loaded, skipping _fetchChatDetails');
      return;
    }
    try {
      print('Fetching chat details for chatId: ${widget.chatId}');
      final response = await http.get(
        Uri.parse('$baseUrl/chat/${widget.chatId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _productId = data['productId']?.toString();
          _buyerId = data['clientId']?.toString();
          _isChatDetailsLoaded = _productId != null && _buyerId != null;
        });
        if (_productId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chat details missing productId')),
          );
        }
        if (_buyerId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chat details missing clientId')),
          );
        }
        if (_isChatDetailsLoaded) {
          await _fetchProductDetails();
          await _fetchCurrentDiscount();
          await _fetchClientProfile();
        } else {
          setState(() {
            _clientName = 'Unknown Client';
            _clientProfileImage = null;
            _profileImageUrl = '';
            _isLoadingClientProfile = false;
            _isProfileLoaded = true;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch chat details: ${response.body}')),
        );
        setState(() {
          _clientName = 'Unknown Client';
          _clientProfileImage = null;
          _profileImageUrl = '';
          _isLoadingClientProfile = false;
          _isProfileLoaded = true;
        });
      }
    } catch (e) {
      print('Error fetching chat details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching chat details: $e')),
      );
      setState(() {
        _clientName = 'Unknown Client';
        _clientProfileImage = null;
        _profileImageUrl = '';
        _isLoadingClientProfile = false;
        _isProfileLoaded = true;
      });
    }
  }

  Future<void> _fetchClientProfile() async {
    if (_buyerId == null || _isProfileLoaded) {
      print('Skipping _fetchClientProfile: buyerId null or profile loaded');
      setState(() {
        _clientName = 'Unknown Client';
        _clientProfileImage = null;
        _profileImageUrl = '';
        _isLoadingClientProfile = false;
      });
      return;
    }

    setState(() {
      _isLoadingClientProfile = true;
    });

    try {
      print('Fetching profile for buyerId: $_buyerId');
      final response = await http.get(
        Uri.parse('$baseUrl/chatprofile/user/$_buyerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _clientName = (data['firstName']?.isNotEmpty == true || data['lastName']?.isNotEmpty == true)
              ? '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim()
              : 'Unknown Client';
          _clientProfileImage = data['profilePicture'] ?? null;
          _profileImageUrl = _clientProfileImage != null && _clientProfileImage!.isNotEmpty
              ? '$baseUrl$_clientProfileImage?t=${DateTime.now().millisecondsSinceEpoch}'
              : '';
          _isLoadingClientProfile = false;
          _isProfileLoaded = true;
        });
      } else {
        setState(() {
          _clientName = 'Unknown Client';
          _clientProfileImage = null;
          _profileImageUrl = '';
          _isLoadingClientProfile = false;
          _isProfileLoaded = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load client profile: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() {
        _clientName = 'Unknown Client';
        _clientProfileImage = null;
        _profileImageUrl = '';
        _isLoadingClientProfile = false;
        _isProfileLoaded = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching client profile: $e')),
      );
    }
  }

  Future<void> _fetchProductDetails() async {
    if (_productId == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/client-products?productId=$_productId'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty && data[0]['price'] != null) {
          setState(() {
            _originalPrice = double.tryParse(data[0]['price'].toString());
          });
        }
      }
    } catch (e) {
      print('Error fetching product details: $e');
    }
  }

  Future<void> _fetchCurrentDiscount() async {
    if (_productId == null || _buyerId == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/discounts/$_productId/$_buyerId'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data == null || (data is Map && data.isEmpty)) {
            _currentDiscount = null;
          } else {
            _currentDiscount = Map<String, dynamic>.from(data);
            if (_currentDiscount!['negotiatedPrice'] != null) {
              _currentDiscount!['negotiatedPrice'] = double.tryParse(_currentDiscount!['negotiatedPrice'].toString()) ?? _currentDiscount!['negotiatedPrice'];
            }
          }
        });
      } else {
        setState(() {
          _currentDiscount = null;
        });
      }
    } catch (e) {
      print('Error fetching current discount: $e');
      setState(() {
        _currentDiscount = null;
      });
    }
  }

  Future<void> _saveDiscount(double price) async {
    if (_productId == null || _buyerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Product or buyer information missing')),
      );
      return;
    }

    try {
      final requestBody = {
        'productId': _productId,
        'userId': _buyerId,
        'negotiatedPrice': price,
        'chatId': widget.chatId,
        'expiry': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/discounts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Discount of $price ETB set successfully')),
        );
        final messageData = {
          'chatId': widget.chatId,
          'senderId': widget.sellerId,
          'message': 'Discount set to $price ETB!',
          'timestamp': DateTime.now().toIso8601String(),
          'isImage': false,
        };
        _emitWithRetry('sendMessage', messageData);
        setState(() {
          _messages = [..._messages, {
            'senderId': widget.sellerId,
            'message': 'Discount set to $price ETB!',
            'timestamp': messageData['timestamp'],
            'status': 'sent',
            'isImage': false,
          }];
          _currentDiscount = {
            'productId': _productId,
            'userId': _buyerId,
            'negotiatedPrice': price,
            'chatId': widget.chatId,
            'expiry': requestBody['expiry'],
          };
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set discount: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting discount: $e')),
      );
    }
  }

  Future<void> _deleteDiscount() async {
    if (_productId == null || _buyerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Product or buyer information missing')),
      );
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/discounts/$_productId/$_buyerId'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Discount deleted successfully')),
        );
        final messageData = {
          'chatId': widget.chatId,
          'senderId': widget.sellerId,
          'message': 'Discount has been removed.',
          'timestamp': DateTime.now().toIso8601String(),
          'isImage': false,
        };
        _emitWithRetry('sendMessage', messageData);
        setState(() {
          _messages = [..._messages, {
            'senderId': widget.sellerId,
            'message': 'Discount has been removed.',
            'timestamp': messageData['timestamp'],
            'status': 'sent',
            'isImage': false,
          }];
          _currentDiscount = null;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete discount: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting discount: $e')),
      );
    }
  }

  void _initializeSocket() {
    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Seller connected to Socket.io server');
      _emitWithRetry('joinChat', widget.chatId);
      _emitWithRetry('online', widget.chatId);
    });

    socket.on('receiveMessage', (data) {
      if (data['senderId'] != widget.sellerId) {
        final messageContent = data['message']?.toString() ?? '';
        final isImage = data['isImage'] ??
            (messageContent.startsWith('/upload/') ||
                RegExp(r'\.(jpg|jpeg|png|gif)$', caseSensitive: false).hasMatch(messageContent));
        print('Received message: $messageContent, isImage: $isImage');
        setState(() {
          _messages = [..._messages, {
            'senderId': data['senderId'],
            'message': messageContent,
            'timestamp': data['timestamp'],
            'status': 'sent',
            'isImage': isImage,
          }];
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
        _emitWithRetry('messageSeen', {
          'chatId': widget.chatId,
          'messageTimestamp': data['timestamp'],
        });
      }
    });

    socket.on('messageSeen', (data) {
      if (data['messageTimestamp'] != null && data['chatId'] == widget.chatId) {
        try {
          final receivedTime = DateTime.parse(data['messageTimestamp']);
          setState(() {
            _messages = _messages.map((msg) {
              final msgTime = DateTime.parse(msg['timestamp']);
              final timeDiff = receivedTime.difference(msgTime).inMilliseconds.abs();
              if (timeDiff < 5000 && msg['senderId'] == widget.sellerId) {
                return {...msg, 'status': 'seen'};
              }
              return msg;
            }).toList();
          });
        } catch (e) {
          print('Error parsing messageSeen timestamp: $e');
        }
      }
    });

    socket.on('typing', (data) {
      setState(() {
        _isTyping = true;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
        }
      });
    });

    socket.on('online', (_) {
      setState(() {
        _isOnline = true;
      });
    });

    socket.on('offline', (_) {
      setState(() {
        _isOnline = false;
      });
    });

    socket.onReconnect((_) {
      print('Reconnected to Socket.io server');
      _emitWithRetry('joinChat', widget.chatId);
      _emitWithRetry('online', widget.chatId);
    });

    socket.onDisconnect((_) {
      print('Seller disconnected from Socket.io server');
      _emitWithRetry('offline', widget.chatId);
    });

    socket.onError((error) {
      print('Socket.io error: $error');
    });

    socket.onAny((event, data) {
      print('Socket event: $event, data: $data');
    });
  }

  void _emitWithRetry(String event, dynamic data) {
    if (socket.connected) {
      socket.emit(event, data);
      print('Emitted $event: $data');
    } else {
      print('Socket not connected, retrying $event in 1s');
      Future.delayed(const Duration(seconds: 1), () {
        if (socket.connected) {
          socket.emit(event, data);
          print('Retry emitted $event: $data');
        } else {
          print('Retry failed for $event: socket still disconnected');
        }
      });
    }
  }

  void _markMessagesAsSeen() {
    for (var msg in _messages) {
      if (msg['status'] == 'sent' && msg['senderId'] != widget.sellerId) {
        _emitWithRetry('messageSeen', {
          'chatId': widget.chatId,
          'messageTimestamp': msg['timestamp'],
        });
      }
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final messageData = {
      'chatId': widget.chatId,
      'senderId': widget.sellerId,
      'message': _messageController.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
      'isImage': false,
    };

    _emitWithRetry('sendMessage', messageData);

    setState(() {
      _messages = [..._messages, {
        'senderId': widget.sellerId,
        'message': _messageController.text.trim(),
        'timestamp': messageData['timestamp'],
        'status': 'sent',
        'isImage': false,
      }];
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    _messageController.clear();
  }

  Future<void> _sendImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/upload'),
        );
        request.headers['Authorization'] = 'Bearer ${widget.token}';
        final bytes = file.bytes ?? await file.readStream!.first;
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: file.name,
            contentType: MediaType('image', file.extension ?? 'jpeg'),
          ),
        );

        final response = await request.send();
        final responseBody = await http.Response.fromStream(response);

        if (response.statusCode == 200) {
          final data = jsonDecode(responseBody.body);
          final imageUrl = data['filePath'];
          print('Sent image URL: $imageUrl');

          final messageData = {
            'chatId': widget.chatId,
            'senderId': widget.sellerId,
            'message': imageUrl,
            'timestamp': DateTime.now().toIso8601String(),
            'isImage': true,
          };

          _emitWithRetry('sendMessage', messageData);

          setState(() {
            _messages = [..._messages, {
              'senderId': widget.sellerId,
              'message': imageUrl,
              'timestamp': messageData['timestamp'],
              'status': 'sent',
              'isImage': true,
            }];
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: ${responseBody.body}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  void _showDiscountDialog() {
    if (!_isChatDetailsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait, loading chat details...')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Negotiated Price'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_originalPrice != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Original Price: ${_originalPrice!.toStringAsFixed(2)} ETB',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            if (_currentDiscount != null && _currentDiscount!['negotiatedPrice'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Current Discount: ${_currentDiscount!['negotiatedPrice'].toStringAsFixed(2)} ETB',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Price (ETB)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _negotiatedPrice = double.tryParse(value);
              },
            ),
          ],
        ),
        actions: [
          if (_currentDiscount != null && _currentDiscount!['negotiatedPrice'] != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteDiscount();
              },
              child: const Text(
                'Delete Discount',
                style: TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_negotiatedPrice != null && _negotiatedPrice! > 0) {
                _saveDiscount(_negotiatedPrice!);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid positive price')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emitWithRetry('offline', widget.chatId);
    socket.disconnect();
    socket.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building SellerChatPage');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 62, 62, 147),
        iconTheme: const IconThemeData(color: Colors.white),
        title: ProfileHeader(
          name: _clientName ?? 'Unknown Client',
          profileImage: _profileImageUrl,
          baseUrl: baseUrl,
          isOnline: _isOnline,
          isLoading: _isLoadingClientProfile,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          'No messages yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _buildMessageItems().length,
                        itemBuilder: (context, index) {
                          final item = _buildMessageItems()[index];
                          if (item['type'] == 'date') {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  item['date'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }

                          final message = item['message'];
                          final isSender = message['senderId'] == widget.sellerId;
                          final messageContent = message['message']?.toString() ?? '';
                          final imageUrl = '$baseUrl$messageContent?t=${DateTime.now().millisecondsSinceEpoch}';
                          print('Rendering message: $messageContent, isImage: ${message['isImage']}, URL: $imageUrl');

                          return Align(
                            alignment: isSender
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: isSender
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: isSender ? const Color.fromARGB(255, 62, 62, 147) : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isSender
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      if (message['isImage'] == true)
                                        Image.network(
                                          imageUrl,
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            print('Image load error for $imageUrl: $error');
                                            return Text(
                                              'Failed to load image: $messageContent',
                                              style: GoogleFonts.poppins(
                                                color: isSender ? Colors.white : Colors.black,
                                                fontSize: 14,
                                              ),
                                            );
                                          },
                                        )
                                      else
                                        Text(
                                          messageContent,
                                          style: GoogleFonts.poppins(
                                            color: isSender ? Colors.white : Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                      if (isSender)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              message['status'] == 'seen'
                                                  ? Icons.done_all
                                                  : Icons.done,
                                              size: 14,
                                              color: message['status'] == 'seen'
                                                  ? Colors.blue
                                                  : Colors.grey,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    _formatDateTime(message['timestamp']),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Typing...',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Color.fromARGB(255, 62, 62, 147)),
                  onPressed: _sendImage,
                ),
                IconButton(
                  icon: const Icon(Icons.discount, color: Color.fromARGB(255, 62, 62, 147)),
                  onPressed: _isChatDetailsLoaded ? _showDiscountDialog : null,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      _emitWithRetry('typing', widget.chatId);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color.fromARGB(255, 62, 62, 147)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildMessageItems() {
    List<Map<String, dynamic>> items = [];
    DateTime? lastDate;

    for (var message in _messages) {
      final messageDate = DateTime.parse(message['timestamp']).toLocal();
      final now = DateTime.now();
      final messageDay = DateTime(messageDate.year, messageDate.month, messageDate.day);
      final today = DateTime(now.year, now.month, now.day);

      if (lastDate == null || messageDay != lastDate) {
        String dateLabel;
        if (messageDay == today) {
          dateLabel = 'Today';
        } else {
          dateLabel = DateFormat('MMMM d, yyyy').format(messageDay);
        }
        items.add({'type': 'date', 'date': dateLabel});
        lastDate = messageDay;
      }

      items.add({'type': 'message', 'message': message});
    }

    return items;
  }

  String _formatDateTime(String dateTime) {
    final date = DateTime.parse(dateTime).toLocal();
    return DateFormat('hh:mm a').format(date);
  }
}