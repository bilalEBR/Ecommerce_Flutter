


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
//   final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchMessages();
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

//         // Mark messages as seen
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
//         socket.emit('messageSeen', {
//           'chatId': widget.chatId,
//           'messageTimestamp': data['timestamp'],
//         });
//       }
//     });

//     socket.on('messageSeen', (data) {
//       setState(() {
//         _messages = _messages.map((msg) {
//           if (msg['timestamp'] == data['messageTimestamp']) {
//             return {...msg, 'status': 'seen'};
//           }
//           return msg;
//         }).toList();
//       });
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
//   }

//   void _markMessagesAsSeen() {
//     for (var msg in _messages) {
//       if (msg['status'] == 'sent') {
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
//         backgroundColor: Colors.purple,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Chat - ${widget.productName}',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
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
//                             child: Container(
//                               margin: const EdgeInsets.symmetric(vertical: 4.0),
//                               padding: const EdgeInsets.all(12.0),
//                               decoration: BoxDecoration(
//                                 color: isSender ? Colors.purple : Colors.grey[300],
//                                 borderRadius: BorderRadius.circular(12.0),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: isSender
//                                     ? CrossAxisAlignment.end
//                                     : CrossAxisAlignment.start,
//                                 children: [
//                                   if (message['isImage'] == true)
//                                     Image.network(
//                                       '$baseUrl${message['message']}',
//                                       width: 150,
//                                       height: 150,
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (context, error, stackTrace) =>
//                                           const Text('Error loading image'),
//                                     )
//                                   else
//                                     Text(
//                                       message['message'],
//                                       style: GoogleFonts.poppins(
//                                         color: isSender ? Colors.white : Colors.black,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   const SizedBox(height: 4),
//                                   Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         _formatDateTime(message['timestamp']),
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 10,
//                                           color: isSender ? Colors.white70 : Colors.black54,
//                                         ),
//                                       ),
//                                       if (isSender) ...[
//                                         const SizedBox(width: 5),
//                                         Icon(
//                                           message['status'] == 'seen'
//                                               ? Icons.done_all
//                                               : Icons.done,
//                                           size: 14,
//                                           color: message['status'] == 'seen'
//                                               ? Colors.blue
//                                               : Colors.grey,
//                                         ),
//                                       ],
//                                     ],
//                                   ),
//                                 ],
//                               ),
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
//                   icon: const Icon(Icons.attach_file, color: Colors.purple),
//                   onPressed: _sendImage,
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
//                   icon: const Icon(Icons.send, color: Colors.purple),
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
//     final now = DateTime.now();
//     final difference = now.difference(date);
//     final timeString = DateFormat('hh:mm a').format(date);

//     if (difference.inDays > 0) {
//       return '$timeString, ${difference.inDays}d ago';
//     } else if (difference.inHours > 0) {
//       return '$timeString, ${difference.inHours}h ago';
//     } else if (difference.inMinutes > 0) {
//       return '$timeString, ${difference.inMinutes}m ago';
//     } else {
//       return '$timeString, Just now';
//     }
//   }
// }


// version 2

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
//   final String baseUrl = 'http://localhost:3000';

//   @override
//   void initState() {
//     super.initState();
//     _fetchMessages();
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

//         // Mark messages as seen
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
//         backgroundColor: Colors.purple,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Chat - ${widget.productName}',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
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
//                                     color: isSender ? Colors.purple : Colors.grey[300],
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
//                   icon: const Icon(Icons.attach_file, color: Colors.purple),
//                   onPressed: _sendImage,
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
//                   icon: const Icon(Icons.send, color: Colors.purple),
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

// version 3  with discount and cart 


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
//   bool _isChatDetailsLoaded = false; // Track if chat details are loaded
//   final String baseUrl = 'http://localhost:3000';
//   double? _negotiatedPrice;
//   String? _productId;
//   String? _buyerId;

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
//           _buyerId = data['clientId']?.toString(); // Changed from buyerId to clientId
//           _isChatDetailsLoaded = _productId != null && _buyerId != null;
//         });
//         print('Fetched productId: $_productId, buyerId: $_buyerId');
//         if (_productId == null || _buyerId == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Chat details missing productId or clientId')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch chat details: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error fetching chat details: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching chat details: $e')),
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
//         // Notify buyer in chat
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
//         content: TextField(
//           keyboardType: TextInputType.number,
//           decoration: const InputDecoration(
//             labelText: 'Price (ETB)',
//             border: OutlineInputBorder(),
//           ),
//           onChanged: (value) {
//             _negotiatedPrice = double.tryParse(value);
//           },
//         ),
//         actions: [
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
//         backgroundColor: Colors.purple,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Chat - ${widget.productName}',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
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
//                                     color: isSender ? Colors.purple : Colors.grey[300],
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
//                   icon: const Icon(Icons.attach_file, color: Colors.purple),
//                   onPressed: _sendImage,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.discount, color: Colors.purple),
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
//                   icon: const Icon(Icons.send, color: Colors.purple),
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


// version 4 discount with original price and delete option

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
//   bool _isChatDetailsLoaded = false; // Track if chat details are loaded
//   final String baseUrl = 'http://localhost:3000';
//   double? _negotiatedPrice;
//   String? _productId;
//   String? _buyerId;
//   double? _originalPrice; // Added to store the original price
//   Map<String, dynamic>? _currentDiscount; // Added to store the current discount

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
//         if (_productId == null || _buyerId == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Chat details missing productId or clientId')),
//           );
//         } else {
//           // Fetch product details and current discount after getting productId and buyerId
//           await _fetchProductDetails();
//           await _fetchCurrentDiscount();
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch chat details: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error fetching chat details: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching chat details: $e')),
//       );
//     }
//   }

//   Future<void> _fetchProductDetails() async {
//     if (_productId == null) return;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/seller-products?productId=$_productId'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       print('Fetch product details response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data is List && data.isNotEmpty) {
//           setState(() {
//             _originalPrice = data[0]['price']?.toDouble();
//           });
//           print('Fetched original price: $_originalPrice');
//         } else {
//           print('Product data not found or invalid format');
//         }
//       } else {
//         print('Failed to fetch product details: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching product details: $e');
//     }
//   }

//   Future<void> _fetchCurrentDiscount() async {
//     if (_productId == null || _buyerId == null) return;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/discounts/$_productId'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       print('Fetch current discount response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _currentDiscount = data.isNotEmpty ? data : null;
//         });
//         print('Fetched current discount: $_currentDiscount');
//       } else {
//         print('Failed to fetch current discount: ${response.body}');
//         setState(() {
//           _currentDiscount = null;
//         });
//       }
//     } catch (e) {
//       print('Error fetching current discount: $e');
//       setState(() {
//         _currentDiscount = null;
//       });
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
//         // Notify buyer in chat
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
//           // Update current discount
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
//         // Notify buyer in chat
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
//           _currentDiscount = null; // Clear the current discount
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

//    showDialog(
//   context: context,
//   builder: (context) => AlertDialog(
//     title: const Text('Set Negotiated Price'),
//     content: Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (_originalPrice != null)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8.0),
//             child: Text(
//               'Original Price: ${_originalPrice!.toStringAsFixed(2)} ETB',
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ),
//         if (_currentDiscount != null)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8.0),
//             child: Text(
//               'Current Discount: ${_currentDiscount!['negotiatedPrice'].toStringAsFixed(2)} ETB',
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 color: Colors.green,
//               ),
//             ),
//           ),
//         TextField(
//           keyboardType: TextInputType.number,
//           decoration: const InputDecoration(
//             labelText: 'New Price (ETB)',
//             border: OutlineInputBorder(),
//           ),
//           onChanged: (value) {
//             _negotiatedPrice = double.tryParse(value);
//           },
//         ),
//       ],
//     ),
//     actions: [
//       if (_currentDiscount != null)
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//             _deleteDiscount();
//           },
//           child: const Text(
//             'Delete Discount',
//             style: TextStyle(color: Colors.red),
//           ),
//         ),
//       TextButton(
//         onPressed: () => Navigator.pop(context),
//         child: const Text('Cancel'),
//       ),
//       TextButton(
//         onPressed: () {
//           if (_negotiatedPrice != null && _negotiatedPrice! > 0) {
//             _saveDiscount(_negotiatedPrice!);
//             Navigator.pop(context);
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Please enter a valid positive price')),
//             );
//           }
//         },
//         child: const Text('Confirm'),
//       ),
//     ],
//   ),
// );
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
//         backgroundColor: Colors.purple,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Chat - ${widget.productName}',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
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
//                                     color: isSender ? Colors.purple : Colors.grey[300],
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
//                   icon: const Icon(Icons.attach_file, color: Colors.purple),
//                   onPressed: _sendImage,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.discount, color: Colors.purple),
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
//                   icon: const Icon(Icons.send, color: Colors.purple),
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

// version 5 afternoon

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

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
  bool _isChatDetailsLoaded = false; // Track if chat details are loaded
  final String baseUrl = 'http://localhost:3000';
  double? _negotiatedPrice;
  String? _productId;
  String? _buyerId;
  double? _originalPrice; // Added to store the original price
  Map<String, dynamic>? _currentDiscount; // Added to store the current discount

  @override
  void initState() {
    super.initState();
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
            return {
              ...msg,
              'status': msg['status'] ?? 'sent',
            };
          }).toList();
          _isLoading = false;
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
    try {
      print('Fetching chat details for chatId: ${widget.chatId}');
      final response = await http.get(
        Uri.parse('$baseUrl/chat/${widget.chatId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      print('Chat details response status: ${response.statusCode}');
      print('Chat details response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _productId = data['productId']?.toString();
          _buyerId = data['clientId']?.toString();
          _isChatDetailsLoaded = _productId != null && _buyerId != null;
        });
        print('Fetched productId: $_productId, buyerId: $_buyerId');
        if (_productId == null || _buyerId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chat details missing productId or clientId')),
          );
        } else {
          // Fetch product details and current discount after getting productId and buyerId
          await _fetchProductDetails();
          await _fetchCurrentDiscount();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch chat details: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error fetching chat details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching chat details: $e')),
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

      print('Fetch product details response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty && data[0]['price'] != null) {
          setState(() {
            _originalPrice = double.tryParse(data[0]['price'].toString());
          });
          if (_originalPrice == null) {
            print('Failed to parse price from data: ${data[0]['price']}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to parse product price')),
            );
          } else {
            print('Fetched original price: $_originalPrice');
          }
        } else {
          print('Product data not found or invalid format: $data');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product data not found or invalid format')),
          );
        }
      } else {
        print('Failed to fetch product details: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch product details: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error fetching product details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching product details: $e')),
      );
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

      print('Fetch current discount response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // Check if data is an empty object or null, otherwise assume it's a valid discount object
          if (data == null || (data is Map && data.isEmpty)) {
            _currentDiscount = null;
          } else {
            _currentDiscount = Map<String, dynamic>.from(data);
            // Ensure negotiatedPrice is a double
            if (_currentDiscount!['negotiatedPrice'] != null) {
              _currentDiscount!['negotiatedPrice'] = double.tryParse(_currentDiscount!['negotiatedPrice'].toString()) ?? _currentDiscount!['negotiatedPrice'];
            }
          }
        });
        print('Fetched current discount: $_currentDiscount');
      } else {
        print('Failed to fetch current discount: ${response.body}');
        setState(() {
          _currentDiscount = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch current discount: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error fetching current discount: $e');
      setState(() {
        _currentDiscount = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching current discount: $e')),
      );
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
      print('Sending discount request: $requestBody');

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
        // Notify buyer in chat
        final messageData = {
          'chatId': widget.chatId,
          'senderId': widget.sellerId,
          'message': 'Discount set to $price ETB!',
          'timestamp': DateTime.now().toIso8601String(),
          'isImage': false,
        };
        socket.emit('sendMessage', messageData);
        setState(() {
          _messages.add({
            'senderId': widget.sellerId,
            'message': 'Discount set to $price ETB!',
            'timestamp': messageData['timestamp'],
            'status': 'sent',
            'isImage': false,
          });
          // Update current discount
          _currentDiscount = {
            'productId': _productId,
            'userId': _buyerId,
            'negotiatedPrice': price,
            'chatId': widget.chatId,
            'expiry': requestBody['expiry'],
          };
        });
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['error'] ?? 'Failed to set discount';
        if (errorData['missing'] != null) {
          errorMessage += ': ' + errorData['missing'].entries
              .where((entry) => entry.value)
              .map((entry) => entry.key)
              .join(', ');
        } else if (errorData['invalid'] != null) {
          errorMessage += ': ' + errorData['invalid'].entries
              .where((entry) => entry.value)
              .map((entry) => entry.key)
              .join(', ');
        } else if (errorData['userId'] != null) {
          errorMessage += ' (userId: ${errorData['userId']})';
        } else if (errorData['productId'] != null) {
          errorMessage += ' (productId: ${errorData['productId']})';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
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

      print('Delete discount response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Discount deleted successfully')),
        );
        // Notify buyer in chat
        final messageData = {
          'chatId': widget.chatId,
          'senderId': widget.sellerId,
          'message': 'Discount has been removed.',
          'timestamp': DateTime.now().toIso8601String(),
          'isImage': false,
        };
        socket.emit('sendMessage', messageData);
        setState(() {
          _messages.add({
            'senderId': widget.sellerId,
            'message': 'Discount has been removed.',
            'timestamp': messageData['timestamp'],
            'status': 'sent',
            'isImage': false,
          });
          _currentDiscount = null; // Clear the current discount
        });
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error'] ?? 'Failed to delete discount';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
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
      socket.emit('joinChat', widget.chatId);
      socket.emit('online', widget.chatId);
    });

    socket.on('receiveMessage', (data) {
      if (data['senderId'] != widget.sellerId) {
        setState(() {
          _messages.add({
            'senderId': data['senderId'],
            'message': data['message'],
            'timestamp': data['timestamp'],
            'status': 'sent',
            'isImage': data['isImage'] ?? false,
          });
        });
        print('Emitting messageSeen for timestamp: ${data['timestamp']}');
        socket.emit('messageSeen', {
          'chatId': widget.chatId,
          'messageTimestamp': data['timestamp'],
        });
      }
    });

    socket.on('messageSeen', (data) {
      print('Received messageSeen: $data');
      if (data['messageTimestamp'] != null && data['chatId'] == widget.chatId) {
        try {
          final receivedTime = DateTime.parse(data['messageTimestamp']);
          setState(() {
            _messages = _messages.map((msg) {
              final msgTime = DateTime.parse(msg['timestamp']);
              final timeDiff = receivedTime.difference(msgTime).inMilliseconds.abs();
              print('Comparing msgTimestamp: ${msg['timestamp']} with receivedTimestamp: ${data['messageTimestamp']} (diff: $timeDiff ms)');
              if (timeDiff < 1000 && msg['senderId'] == widget.sellerId) {
                return {...msg, 'status': 'seen'};
              }
              return msg;
            }).toList();
          });
        } catch (e) {
          print('Error parsing messageSeen timestamp: $e');
        }
      } else {
        print('Invalid messageSeen data: $data');
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

    socket.onDisconnect((_) {
      print('Seller disconnected from Socket.io server');
      socket.emit('offline', widget.chatId);
    });

    socket.onError((error) {
      print('Socket.io error: $error');
    });

    socket.onAny((event, data) {
      print('Socket event: $event, data: $data');
    });
  }

  void _markMessagesAsSeen() {
    for (var msg in _messages) {
      if (msg['status'] == 'sent' && msg['senderId'] != widget.sellerId) {
        print('Marking message as seen on load: ${msg['timestamp']}');
        socket.emit('messageSeen', {
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

    socket.emit('sendMessage', messageData);

    setState(() {
      _messages.add({
        'senderId': widget.sellerId,
        'message': _messageController.text.trim(),
        'timestamp': messageData['timestamp'],
        'status': 'sent',
        'isImage': false,
      });
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

          final messageData = {
            'chatId': widget.chatId,
            'senderId': widget.sellerId,
            'message': imageUrl,
            'timestamp': DateTime.now().toIso8601String(),
            'isImage': true,
          };

          socket.emit('sendMessage', messageData);

          setState(() {
            _messages.add({
              'senderId': widget.sellerId,
              'message': imageUrl,
              'timestamp': messageData['timestamp'],
              'status': 'sent',
              'isImage': true,
            });
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
    socket.emit('offline', widget.chatId);
    socket.disconnect();
    socket.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Chat - ${widget.productName}',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isOnline ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
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
                                    color: isSender ? Colors.purple : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isSender
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      if (message['isImage'] == true)
                                        Image.network(
                                          '$baseUrl${message['message']}',
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Text('Error loading image'),
                                        )
                                      else
                                        Text(
                                          message['message'],
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
                  icon: const Icon(Icons.attach_file, color: Colors.purple),
                  onPressed: _sendImage,
                ),
                IconButton(
                  icon: const Icon(Icons.discount, color: Colors.purple),
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
                      socket.emit('typing', widget.chatId);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.purple),
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