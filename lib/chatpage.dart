


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
  String? _sellerId;
  String? _sellerName;
  String? _sellerProfileImage;
  bool _isLoadingSellerProfile = false;
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
          _sellerId = data['sellerId']?.toString();
        });
        if (_productId != null) {
          _fetchNegotiatedPrice();
        }
        if (_sellerId != null) {
          _fetchSellerProfile();
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

  Future<void> _fetchSellerProfile() async {
    if (_sellerId == null || _isProfileLoaded) {
      setState(() {
        _sellerName = 'Unknown Seller';
        _sellerProfileImage = null;
        _isLoadingSellerProfile = false;
        _profileImageUrl = '';
      });
      print('Skipping _fetchSellerProfile: sellerId null or profile loaded');
      return;
    }

    setState(() {
      _isLoadingSellerProfile = true;
    });

    try {
      print('Fetching seller profile for sellerId: $_sellerId');
      final response = await http.get(
        Uri.parse('$baseUrl/chatprofile/$_sellerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _sellerName = (data['firstName']?.isNotEmpty == true || data['lastName']?.isNotEmpty == true)
              ? '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim()
              : 'Unknown Seller';
          _sellerProfileImage = data['profilePicture'] ?? null;
          _profileImageUrl = _sellerProfileImage != null && _sellerProfileImage!.isNotEmpty
              ? '$baseUrl$_sellerProfileImage?t=${DateTime.now().millisecondsSinceEpoch}'
              : '';
          _isLoadingSellerProfile = false;
          _isProfileLoaded = true;
        });
      } else {
        setState(() {
          _sellerName = 'Unknown Seller';
          _sellerProfileImage = null;
          _profileImageUrl = '';
          _isLoadingSellerProfile = false;
          _isProfileLoaded = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load seller profile: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() {
        _sellerName = 'Unknown Seller';
        _sellerProfileImage = null;
        _profileImageUrl = '';
        _isLoadingSellerProfile = false;
        _isProfileLoaded = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching seller profile: $e')),
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
      _emitWithRetry('joinChat', widget.chatId);
      _emitWithRetry('online', widget.chatId);
    });

    socket.on('receiveMessage', (data) {
      final clientState = Provider.of<ClientState>(context, listen: false);
      final clientId = clientState.userId;
      if (data['senderId'] != clientId) {
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
              if (timeDiff < 5000 && msg['senderId'] == Provider.of<ClientState>(context, listen: false).userId) {
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
      print('Disconnected from Socket.io server');
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
      if (msg['status'] == 'sent' && msg['senderId'] != Provider.of<ClientState>(context, listen: false).userId) {
        _emitWithRetry('messageSeen', {
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

    _emitWithRetry('sendMessage', messageData);

    setState(() {
      _messages = [..._messages, {
        'senderId': clientId,
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
          print('Sent image URL: $imageUrl');

          final messageData = {
            'chatId': widget.chatId,
            'senderId': clientId,
            'message': imageUrl,
            'timestamp': DateTime.now().toIso8601String(),
            'isImage': true,
          };

          _emitWithRetry('sendMessage', messageData);

          setState(() {
            _messages = [..._messages, {
              'senderId': clientId,
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
    print('Building ChatPage');
    final clientState = Provider.of<ClientState>(context, listen: false);
    final clientId = clientState.userId;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 62, 62, 147),
        iconTheme: const IconThemeData(color: Colors.white),
        title: ProfileHeader(
          name: _sellerName ?? 'Unknown Seller',
          profileImage: _profileImageUrl,
          baseUrl: baseUrl,
          isOnline: _isOnline,
          isLoading: _isLoadingSellerProfile,
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
                          final isSender = message['senderId'] == clientId;
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