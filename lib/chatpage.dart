
// // version 1

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:provider/provider.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'client-state.dart';
// import 'package:intl/intl.dart';

// class ChatPage extends StatefulWidget {
//   final String chatId;
//   final String productName;
//   final String token;

//   const ChatPage({
//     super.key,
//     required this.chatId,
//     required this.productName,
//     required this.token,
//   });

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
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
//               'status': msg['status'] ?? 'sent', // Default to 'sent' if not present
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
//       print('Connected to Socket.io server');
//       socket.emit('joinChat', widget.chatId);
//       socket.emit('online', widget.chatId); // Notify online status
//     });

//     socket.on('receiveMessage', (data) {
//       final clientState = Provider.of<ClientState>(context, listen: false);
//       final clientId = clientState.userId;
//       if (data['senderId'] != clientId) {
//         setState(() {
//           _messages.add({
//             'senderId': data['senderId'],
//             'message': data['message'],
//             'timestamp': data['timestamp'],
//             'status': 'sent',
//             'isImage': data['isImage'] ?? false,
//           });
//         });
//         // Mark as seen when received
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
//       print('Disconnected from Socket.io server');
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

//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final clientId = clientState.userId;

//     if (clientId == null || widget.token == null) {
//       Navigator.pushReplacementNamed(context, '/login');
//       return;
//     }

//     final messageData = {
//       'chatId': widget.chatId,
//       'senderId': clientId,
//       'message': _messageController.text.trim(),
//       'timestamp': DateTime.now().toIso8601String(),
//       'isImage': false,
//     };

//     socket.emit('sendMessage', messageData);

//     setState(() {
//       _messages.add({
//         'senderId': clientId,
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
//         final clientState = Provider.of<ClientState>(context, listen: false);
//         final clientId = clientState.userId;

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
//             'senderId': clientId,
//             'message': imageUrl,
//             'timestamp': DateTime.now().toIso8601String(),
//             'isImage': true,
//           };

//           socket.emit('sendMessage', messageData);

//           setState(() {
//             _messages.add({
//               'senderId': clientId,
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
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final clientId = clientState.userId;

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
//                           final isSender = message['senderId'] == clientId;
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

//       // Add date header if the message is on a new day
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

// version 2  with seen and time setting 

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:provider/provider.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart';
// import 'client-state.dart';
// import 'package:intl/intl.dart';

// class ChatPage extends StatefulWidget {
//   final String chatId;
//   final String productName;
//   final String token;

//   const ChatPage({
//     super.key,
//     required this.chatId,
//     required this.productName,
//     required this.token,
//   });

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
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
//       print('Connected to Socket.io server');
//       socket.emit('joinChat', widget.chatId);
//       socket.emit('online', widget.chatId);
//     });

//     socket.on('receiveMessage', (data) {
//       final clientState = Provider.of<ClientState>(context, listen: false);
//       final clientId = clientState.userId;
//       if (data['senderId'] != clientId) {
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
//               if (timeDiff < 1000 && msg['senderId'] == Provider.of<ClientState>(context, listen: false).userId) {
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
//       print('Disconnected from Socket.io server');
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
//       if (msg['status'] == 'sent' && msg['senderId'] != Provider.of<ClientState>(context, listen: false).userId) {
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

//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final clientId = clientState.userId;

//     if (clientId == null || widget.token == null) {
//       Navigator.pushReplacementNamed(context, '/login');
//       return;
//     }

//     final messageData = {
//       'chatId': widget.chatId,
//       'senderId': clientId,
//       'message': _messageController.text.trim(),
//       'timestamp': DateTime.now().toIso8601String(),
//       'isImage': false,
//     };

//     socket.emit('sendMessage', messageData);

//     setState(() {
//       _messages.add({
//         'senderId': clientId,
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
//         final clientState = Provider.of<ClientState>(context, listen: false);
//         final clientId = clientState.userId;

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
//             'senderId': clientId,
//             'message': imageUrl,
//             'timestamp': DateTime.now().toIso8601String(),
//             'isImage': true,
//           };

//           socket.emit('sendMessage', messageData);

//           setState(() {
//             _messages.add({
//               'senderId': clientId,
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
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final clientId = clientState.userId;

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
//                           final isSender = message['senderId'] == clientId;
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

// version 3 discount with cart page

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'client-state.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String productName;
  final String token;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.productName,
    required this.token,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late IO.Socket socket;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  bool _isOnline = false;
  final String baseUrl = 'http://localhost:3000';
  double? _negotiatedPrice;
  String? _productId;

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
        });
        if (_productId != null) {
          _fetchNegotiatedPrice();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch chat details: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching chat details: $e')),
      );
    }
  }

  Future<void> _fetchNegotiatedPrice() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/discounts/$_productId'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _negotiatedPrice = data['negotiatedPrice']?.toDouble();
        });
      }
    } catch (e) {
      print('Error fetching negotiated price: $e');
    }
  }

  void _initializeSocket() {
    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected to Socket.io server');
      socket.emit('joinChat', widget.chatId);
      socket.emit('online', widget.chatId);
    });

    socket.on('receiveMessage', (data) {
      final clientState = Provider.of<ClientState>(context, listen: false);
      final clientId = clientState.userId;
      if (data['senderId'] != clientId) {
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
              if (timeDiff < 1000 && msg['senderId'] == Provider.of<ClientState>(context, listen: false).userId) {
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
      print('Disconnected from Socket.io server');
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
      if (msg['status'] == 'sent' && msg['senderId'] != Provider.of<ClientState>(context, listen: false).userId) {
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

    final clientState = Provider.of<ClientState>(context, listen: false);
    final clientId = clientState.userId;

    if (clientId == null || widget.token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final messageData = {
      'chatId': widget.chatId,
      'senderId': clientId,
      'message': _messageController.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
      'isImage': false,
    };

    socket.emit('sendMessage', messageData);

    setState(() {
      _messages.add({
        'senderId': clientId,
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
        final clientState = Provider.of<ClientState>(context, listen: false);
        final clientId = clientState.userId;

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
            'senderId': clientId,
            'message': imageUrl,
            'timestamp': DateTime.now().toIso8601String(),
            'isImage': true,
          };

          socket.emit('sendMessage', messageData);

          setState(() {
            _messages.add({
              'senderId': clientId,
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
    final clientState = Provider.of<ClientState>(context, listen: false);
    final clientId = clientState.userId;

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
          if (_negotiatedPrice != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Negotiated Price: $_negotiatedPrice ETB',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
                          final isSender = message['senderId'] == clientId;
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