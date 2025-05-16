

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:provider/provider.dart';
// import 'client-state.dart';
// import 'chatpage.dart';

// class ProductDetailPage extends StatefulWidget {
//   final Map<String, dynamic> product;

//   const ProductDetailPage({super.key, required this.product});

//   @override
//   _ProductDetailPageState createState() => _ProductDetailPageState();
// }

// class _ProductDetailPageState extends State<ProductDetailPage> {
//   int _selectedRating = 0;
//   int _quantity = 1;
//   double? _negotiatedPrice; // Added to store the negotiated price
//   final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';
//   late Map<String, dynamic> _currentProduct;

//   @override
//   void initState() {
//     super.initState();
//     _currentProduct = Map<String, dynamic>.from(widget.product);
//     _fetchNegotiatedPrice(); // Fetch negotiated price on page load
//   }

//   Future<void> _fetchNegotiatedPrice() async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;

//     if (token == null || token.isEmpty) {
//       print('Token is null or empty, skipping negotiated price fetch');
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/discounts/${_currentProduct['_id']}'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('Fetch negotiated price response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _negotiatedPrice = data['negotiatedPrice']?.toDouble();
//         });
//       } else if (response.statusCode == 404) {
//         // No discount found for this user
//         setState(() {
//           _negotiatedPrice = null;
//         });
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         print('Failed to fetch negotiated price: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching negotiated price: $e');
//     }
//   }

//   Future<void> _submitRating(String productId, int rating) async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;

//     if (token == null || token.isEmpty) {
//       print('Token is null or empty, redirecting to login');
//       Navigator.pushReplacementNamed(context, '/login');
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/client-products/rate-product'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'productId': productId,
//           'rating': rating,
//         }),
//       );

//       print('Submit rating response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   const SnackBar(content: Text('Rating submitted successfully')),
//         // );

//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: const Text('Rating submitted successfully!'),
//       backgroundColor: Colors.green,  // Set the green background
//     ),
//   );

//         setState(() {
//           _selectedRating = rating;
//         });
//         await _fetchUpdatedProductDetails(productId);
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else if (response.statusCode == 404) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Product not found or rating service unavailable.'),
//           ),
//         );
//       } else {
//         String errorMessage = 'Unknown error';
//         try {
//           final errorBody = jsonDecode(response.body);
//           errorMessage = errorBody['error'] ?? 'Unknown error';
//         } catch (decodeError) {
//           print('Error decoding response body: $decodeError');
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to submit rating: $errorMessage')),
//         );
//       }
//     } catch (e) {
//       print('Error submitting rating: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error submitting rating: $e')),
//       );
//       if (e.toString().contains('Access token missing') || e.toString().contains('Invalid token')) {
//         Navigator.pushReplacementNamed(context, '/login');
//       }
//     }
//   }

//   Future<void> _fetchUpdatedProductDetails(String productId) async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/client-products?productId=$productId'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('Fetch updated product response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final List<dynamic> products = jsonDecode(response.body);
//         if (products.isNotEmpty) {
//           setState(() {
//             _currentProduct = products[0];
//           });
//         }
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch updated product details: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error fetching updated product details: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching updated product details: $e')),
//       );
//     }
//   }

//   Future<void> _initiateChat() async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;
//     final userId = clientState.userId;

//     print('Initiating chat - userId: $userId, token: $token, productId: ${widget.product['_id']}');

//     if (token == null || token.isEmpty) {
//       print('Token is null or empty, redirecting to login');
//       Navigator.pushReplacementNamed(context, '/login');
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/chat/initiate'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'productId': widget.product['_id']}),
//       );

//       print('Chat initiation response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final chatId = data['chatId'];

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ChatPage(
//               chatId: chatId,
//               productName: widget.product['title'] ?? 'Unknown Product',
//               token: token,
//             ),
//           ),
//         );
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to initiate chat: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error initiating chat: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error initiating chat: $e')),
//       );
//       if (e.toString().contains('Access token missing') || e.toString().contains('Invalid token')) {
//         Navigator.pushReplacementNamed(context, '/login');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final clientState = Provider.of<ClientState>(context);
//     final imageUrl = _currentProduct['image'] != null
//         ? '$baseUrl${_currentProduct['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
//         : null;
//     final isInCart = clientState.cartProducts.any((p) => p['_id'] == _currentProduct['_id']);
//     final availableQuantity = _currentProduct['quantity']?.toInt() ?? 0;
//     final averageRating = _currentProduct['averageRating']?.toStringAsFixed(1) ?? '0.0';
//     final ratingCount = _currentProduct['ratingCount']?.toString() ?? '0';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Product Details',
//           style: GoogleFonts.poppins(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 300,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 image: imageUrl != null
//                     ? DecorationImage(
//                         image: NetworkImage(imageUrl),
//                         fit: BoxFit.cover,
//                         onError: (exception, stackTrace) {
//                           print('Error loading product image: $exception');
//                         },
//                       )
//                     : null,
//               ),
//               child: imageUrl == null
//                   ? const Center(
//                       child: Text(
//                         'No Image',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     )
//                   : null,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _currentProduct['title'] ?? 'Unknown Product',
//                     style: GoogleFonts.poppins(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.star,
//                         color: Colors.yellow,
//                         size: 20,
//                       ),
//                       Text(
//                         '$averageRating ($ratingCount)',
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '\$${_currentProduct['price']?.toStringAsFixed(2) ?? '0.00'}',
//                     style: GoogleFonts.poppins(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   if (_negotiatedPrice != null) ...[
//                     const SizedBox(height: 4),
//                     Text(
//                       'Negotiated Price: \$${_negotiatedPrice!.toStringAsFixed(2)}',
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 16),
//                   Text(
//                     'Rate this product',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: List.generate(5, (index) {
//                       return IconButton(
//                         icon: Icon(
//                           index < _selectedRating ? Icons.star : Icons.star_border,
//                           color: Colors.yellow,
//                           size: 30,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _selectedRating = index + 1;
//                           });
//                           _submitRating(_currentProduct['_id'], _selectedRating);
//                         },
//                       );
//                     }),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Description',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     _currentProduct['description'] ?? 'No description available',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Quantity',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.remove),
//                         onPressed: () {
//                           setState(() {
//                             if (_quantity > 1) {
//                               _quantity--;
//                             }
//                           });
//                         },
//                       ),
//                       Text(
//                         '$_quantity',
//                         style: GoogleFonts.poppins(fontSize: 16),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.add),
//                         onPressed: () {
//                           setState(() {
//                             if (_quantity < availableQuantity) {
//                               _quantity++;
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Cannot exceed available quantity'),
//                                 ),
//                               );
//                             }
//                           });
//                         },
//                       ),
//                       const SizedBox(width: 16),
//                       Text(
//                         'Available: $availableQuantity',
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () {
//                       if (_quantity > availableQuantity) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Selected quantity exceeds available stock'),
//                           ),
//                         );
//                         return;
//                       }
//                       final productWithQuantity = {
//                         ..._currentProduct,
//                         'selectedQuantity': _quantity,
//                         'negotiatedPrice': _negotiatedPrice, // Include negotiated price
//                       };
//                       clientState.toggleCart(productWithQuantity);
//                       if (!isInCart) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('${_currentProduct['title']} added to cart!'),
//                             backgroundColor: Colors.green,  // Set the green background
//                           ),
//                         );


                        
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: isInCart ? Colors.grey : Colors.black,
//                       foregroundColor: Colors.white,
//                       minimumSize: const Size(double.infinity, 48),
//                     ),
//                     child: Text(
//                       isInCart ? 'Added to Cart' : 'Add to Cart',
//                       style: GoogleFonts.poppins(fontSize: 16),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: _initiateChat,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey[300],
//                       foregroundColor: Colors.black,
//                       minimumSize: const Size(double.infinity, 48),
//                     ),
//                     child: Text(
//                       'Contact Seller',
//                       style: GoogleFonts.poppins(fontSize: 16),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// new version to add sold products status 

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:provider/provider.dart';
// import 'client-state.dart';
// import 'chatpage.dart';

// class ProductDetailPage extends StatefulWidget {
//   final Map<String, dynamic> product;

//   const ProductDetailPage({super.key, required this.product});

//   @override
//   _ProductDetailPageState createState() => _ProductDetailPageState();
// }

// class _ProductDetailPageState extends State<ProductDetailPage> {
//   int _selectedRating = 0;
//   int _quantity = 1;
//   double? _negotiatedPrice; // Added to store the negotiated price
//   final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';
//   late Map<String, dynamic> _currentProduct;

//   @override
//   void initState() {
//     super.initState();
//     _currentProduct = Map<String, dynamic>.from(widget.product);
//     _fetchNegotiatedPrice(); // Fetch negotiated price on page load
//   }

//   Future<void> _fetchNegotiatedPrice() async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;

//     if (token == null || token.isEmpty) {
//       print('Token is null or empty, skipping negotiated price fetch');
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/discounts/${_currentProduct['_id']}'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('Fetch negotiated price response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _negotiatedPrice = data['negotiatedPrice']?.toDouble();
//         });
//       } else if (response.statusCode == 404) {
//         // No discount found for this user
//         setState(() {
//           _negotiatedPrice = null;
//         });
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         print('Failed to fetch negotiated price: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching negotiated price: $e');
//     }
//   }

//   Future<void> _submitRating(String productId, int rating) async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;

//     if (token == null || token.isEmpty) {
//       print('Token is null or empty, redirecting to login');
//       Navigator.pushReplacementNamed(context, '/login');
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/client-products/rate-product'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'productId': productId,
//           'rating': rating,
//         }),
//       );

//       print('Submit rating response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Rating submitted successfully!'),
//             backgroundColor: Colors.green,  // Set the green background
//           ),
//         );
//         setState(() {
//           _selectedRating = rating;
//         });
//         await _fetchUpdatedProductDetails(productId);
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else if (response.statusCode == 404) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Product not found or rating service unavailable.'),
//           ),
//         );
//       } else {
//         String errorMessage = 'Unknown error';
//         try {
//           final errorBody = jsonDecode(response.body);
//           errorMessage = errorBody['error'] ?? 'Unknown error';
//         } catch (decodeError) {
//           print('Error decoding response body: $decodeError');
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to submit rating: $errorMessage')),
//         );
//       }
//     } catch (e) {
//       print('Error submitting rating: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error submitting rating: $e')),
//       );
//       if (e.toString().contains('Access token missing') || e.toString().contains('Invalid token')) {
//         Navigator.pushReplacementNamed(context, '/login');
//       }
//     }
//   }

//   Future<void> _fetchUpdatedProductDetails(String productId) async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/client-products?productId=$productId'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('Fetch updated product response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final List<dynamic> products = jsonDecode(response.body);
//         if (products.isNotEmpty) {
//           setState(() {
//             _currentProduct = products[0];
//           });
//         }
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch updated product details: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error fetching updated product details: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching updated product details: $e')),
//       );
//     }
//   }

//   Future<void> _initiateChat() async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;
//     final userId = clientState.userId;

//     print('Initiating chat - userId: $userId, token: $token, productId: ${widget.product['_id']}');

//     if (token == null || token.isEmpty) {
//       print('Token is null or empty, redirecting to login');
//       Navigator.pushReplacementNamed(context, '/login');
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/chat/initiate'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'productId': widget.product['_id']}),
//       );

//       print('Chat initiation response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final chatId = data['chatId'];

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ChatPage(
//               chatId: chatId,
//               productName: widget.product['title'] ?? 'Unknown Product',
//               token: token,
//             ),
//           ),
//         );
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to initiate chat: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error initiating chat: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error initiating chat: $e')),
//       );
//       if (e.toString().contains('Access token missing') || e.toString().contains('Invalid token')) {
//         Navigator.pushReplacementNamed(context, '/login');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final clientState = Provider.of<ClientState>(context);
//     final imageUrl = _currentProduct['image'] != null
//         ? '$baseUrl${_currentProduct['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
//         : null;
//     final isInCart = clientState.cartProducts.any((p) => p['_id'] == _currentProduct['_id']);
//     final availableQuantity = _currentProduct['quantity']?.toInt() ?? 0;
//     final averageRating = _currentProduct['averageRating']?.toStringAsFixed(1) ?? '0.0';
//     final ratingCount = _currentProduct['ratingCount']?.toString() ?? '0';
//     final isSold = _currentProduct['productStatus'] == 'sold';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Product Details',
//           style: GoogleFonts.poppins(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 300,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 image: imageUrl != null
//                     ? DecorationImage(
//                         image: NetworkImage(imageUrl),
//                         fit: BoxFit.cover,
//                         onError: (exception, stackTrace) {
//                           print('Error loading product image: $exception');
//                         },
//                       )
//                     : null,
//               ),
//               child: imageUrl == null
//                   ? const Center(
//                       child: Text(
//                         'No Image',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     )
//                   : null,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _currentProduct['title'] ?? 'Unknown Product',
//                     style: GoogleFonts.poppins(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.star,
//                         color: Colors.yellow,
//                         size: 20,
//                       ),
//                       Text(
//                         '$averageRating ($ratingCount)',
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '\$${_currentProduct['price']?.toStringAsFixed(2) ?? '0.00'}',
//                     style: GoogleFonts.poppins(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   if (_negotiatedPrice != null) ...[
//                     const SizedBox(height: 4),
//                     Text(
//                       'Negotiated Price: \$${_negotiatedPrice!.toStringAsFixed(2)}',
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 16),
//                   Text(
//                     'Rate this product',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: List.generate(5, (index) {
//                       return IconButton(
//                         icon: Icon(
//                           index < _selectedRating ? Icons.star : Icons.star_border,
//                           color: Colors.yellow,
//                           size: 30,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _selectedRating = index + 1;
//                           });
//                           _submitRating(_currentProduct['_id'], _selectedRating);
//                         },
//                       );
//                     }),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Description',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     _currentProduct['description'] ?? 'No description available',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Quantity',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.remove),
//                         onPressed: () {
//                           setState(() {
//                             if (_quantity > 1) {
//                               _quantity--;
//                             }
//                           });
//                         },
//                       ),
//                       Text(
//                         '$_quantity',
//                         style: GoogleFonts.poppins(fontSize: 16),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.add),
//                         onPressed: () {
//                           setState(() {
//                             if (_quantity < availableQuantity) {
//                               _quantity++;
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Cannot exceed available quantity'),
//                                 ),
//                               );
//                             }
//                           });
//                         },
//                       ),
//                       const SizedBox(width: 16),
//                       Text(
//                         'Available: $availableQuantity',
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () {
//                       if (isSold) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Product sold out'),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                         return;
//                       }
//                       if (_quantity > availableQuantity) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Selected quantity exceeds available stock'),
//                           ),
//                         );
//                         return;
//                       }
//                       final productWithQuantity = {
//                         ..._currentProduct,
//                         'selectedQuantity': _quantity,
//                         'negotiatedPrice': _negotiatedPrice, // Include negotiated price
//                       };
//                       clientState.toggleCart(productWithQuantity);
//                       if (!isInCart) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('${_currentProduct['title']} added to cart!'),
//                             backgroundColor: Colors.green, // Set the green background
//                           ),
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: isSold ? Colors.grey[400] : (isInCart ? Colors.grey : Colors.black),
//                       foregroundColor: Colors.white,
//                       minimumSize: const Size(double.infinity, 48),
//                     ),
//                     child: Text(
//                       isSold ? 'Sold Out' : (isInCart ? 'Added to Cart' : 'Add to Cart'),
//                       style: GoogleFonts.poppins(fontSize: 16),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: _initiateChat,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey[300],
//                       foregroundColor: Colors.black,
//                       minimumSize: const Size(double.infinity, 48),
//                     ),
//                     child: Text(
//                       'Contact Seller',
//                       style: GoogleFonts.poppins(fontSize: 16),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// new version to add rating 

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:provider/provider.dart';
// import 'client-state.dart';
// import 'chatpage.dart';
// import 'clientreview.dart';

// class ProductDetailPage extends StatefulWidget {
//   final Map<String, dynamic> product;

//   const ProductDetailPage({super.key, required this.product});

//   @override
//   _ProductDetailPageState createState() => _ProductDetailPageState();
// }

// class _ProductDetailPageState extends State<ProductDetailPage> {
//   int _selectedRating = 0;
//   int _quantity = 1;
//   double? _negotiatedPrice;
//   final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';
//   late Map<String, dynamic> _currentProduct;

//   @override
//   void initState() {
//     super.initState();
//     _currentProduct = Map<String, dynamic>.from(widget.product);
//     _fetchNegotiatedPrice();
//     _fetchUserRating();
//   }

//   Future<void> _fetchUserRating() async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;

//     if (token == null || token.isEmpty) {
//       print('Token is null or empty, skipping user rating fetch');
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/client-products/rating/${_currentProduct['_id']}'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('Fetch user rating response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _selectedRating = data['rating']?.toInt() ?? 0;
//         });
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         print('Failed to fetch user rating: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching user rating: $e');
//     }
//   }

//   Future<void> _fetchNegotiatedPrice() async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;

//     if (token == null || token.isEmpty) {
//       print('Token is null or empty, skipping negotiated price fetch');
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/discounts/${_currentProduct['_id']}'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('Fetch negotiated price response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _negotiatedPrice = data['negotiatedPrice']?.toDouble();
//         });
//       } else if (response.statusCode == 404) {
//         setState(() {
//           _negotiatedPrice = null;
//         });
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         print('Failed to fetch negotiated price: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching negotiated price: $e');
//     }
//   }

//   Future<void> _submitRating(String productId, int rating) async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;

//     if (token == null || token.isEmpty) {
//       print('Token is null or empty, redirecting to login');
//       Navigator.pushReplacementNamed(context, '/login');
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/client-products/rate-product'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'productId': productId,
//           'rating': rating,
//         }),
//       );

//       print('Submit rating response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Rating submitted successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         setState(() {
//           _selectedRating = rating;
//         });
//         await _fetchUpdatedProductDetails(productId);
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else if (response.statusCode == 404) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Product not found or rating service unavailable.'),
//           ),
//         );
//       } else {
//         String errorMessage = 'Unknown error';
//         try {
//           final errorBody = jsonDecode(response.body);
//           errorMessage = errorBody['error'] ?? 'Unknown error';
//         } catch (decodeError) {
//           print('Error decoding response body: $decodeError');
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to submit rating: $errorMessage')),
//         );
//       }
//     } catch (e) {
//       print('Error submitting rating: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error submitting rating: $e')),
//       );
//       if (e.toString().contains('Access token missing') || e.toString().contains('Invalid token')) {
//         Navigator.pushReplacementNamed(context, '/login');
//       }
//     }
//   }

//   Future<void> _fetchUpdatedProductDetails(String productId) async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/client-products?productId=$productId'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('Fetch updated product response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final List<dynamic> products = jsonDecode(response.body);
//         if (products.isNotEmpty) {
//           setState(() {
//             _currentProduct = products[0];
//           });
//         }
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch updated product details: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error fetching updated product details: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching updated product details: $e')),
//       );
//     }
//   }

//   Future<void> _initiateChat() async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;
//     final userId = clientState.userId;

//     print('Initiating chat - userId: $userId, token: $token, productId: ${widget.product['_id']}');

//     if (token == null || token.isEmpty) {
//       print('Token is null or empty, redirecting to login');
//       Navigator.pushReplacementNamed(context, '/login');
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/chat/initiate'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'productId': widget.product['_id']}),
//       );

//       print('Chat initiation response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final chatId = data['chatId'];

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ChatPage(
//               chatId: chatId,
//               productName: widget.product['title'] ?? 'Unknown Product',
//               token: token,
//             ),
//           ),
//         );
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to initiate chat: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error initiating chat: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error initiating chat: $e')),
//       );
//       if (e.toString().contains('Access token missing') || e.toString().contains('Invalid token')) {
//         Navigator.pushReplacementNamed(context, '/login');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final clientState = Provider.of<ClientState>(context);
//     final imageUrl = _currentProduct['image'] != null
//         ? '$baseUrl${_currentProduct['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
//         : null;
//     final isInCart = clientState.cartProducts.any((p) => p['_id'] == _currentProduct['_id']);
//     final availableQuantity = _currentProduct['quantity']?.toInt() ?? 0;
//     final averageRating = _currentProduct['averageRating']?.toStringAsFixed(1) ?? '0.0';
//     final ratingCount = _currentProduct['ratingCount']?.toString() ?? '0';
//     final isSold = _currentProduct['productStatus'] == 'sold';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Product Details',
//           style: GoogleFonts.poppins(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 300,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 image: imageUrl != null
//                     ? DecorationImage(
//                         image: NetworkImage(imageUrl),
//                         fit: BoxFit.cover,
//                         onError: (exception, stackTrace) {
//                           print('Error loading product image: $exception');
//                         },
//                       )
//                     : null,
//               ),
//               child: imageUrl == null
//                   ? const Center(
//                       child: Text(
//                         'No Image',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     )
//                   : null,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _currentProduct['title'] ?? 'Unknown Product',
//                     style: GoogleFonts.poppins(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.star,
//                         color: Colors.amber,
//                         size: 20,
//                       ),
//                       Text(
//                         '$averageRating ($ratingCount)',
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '\$${_currentProduct['price']?.toStringAsFixed(2) ?? '0.00'}',
//                     style: GoogleFonts.poppins(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   if (_negotiatedPrice != null) ...[
//                     const SizedBox(height: 4),
//                     Text(
//                       'Negotiated Price: \$${_negotiatedPrice!.toStringAsFixed(2)}',
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 16),
//                   Text(
//                     'Rate this product',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: List.generate(5, (index) {
//                       return IconButton(
//                         icon: Icon(
//                           index < _selectedRating ? Icons.star : Icons.star_border,
//                           color: Colors.amber,
//                           size: 30,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _selectedRating = index + 1;
//                           });
//                           _submitRating(_currentProduct['_id'], _selectedRating);
//                         },
//                       );
//                     }),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Description',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     _currentProduct['description'] ?? 'No description available',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Quantity',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.remove),
//                         onPressed: () {
//                           setState(() {
//                             if (_quantity > 1) {
//                               _quantity--;
//                             }
//                           });
//                         },
//                       ),
//                       Text(
//                         '$_quantity',
//                         style: GoogleFonts.poppins(fontSize: 16),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.add),
//                         onPressed: () {
//                           setState(() {
//                             if (_quantity < availableQuantity) {
//                               _quantity++;
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Cannot exceed available quantity'),
//                                 ),
//                               );
//                             }
//                           });
//                         },
//                       ),
//                       const SizedBox(width: 16),
//                       Text(
//                         'Available: $availableQuantity',
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       const Spacer(),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ReviewPage(
//                                 productId: _currentProduct['_id'],
//                                 userRating: _selectedRating > 0 ? _selectedRating : null,
//                               ),
//                             ),
//                           );
//                         },
//                         child: Text(
//                           'Reviews',
//                           style: GoogleFonts.poppins(
//                             fontSize: 14,
//                             color: Colors.blue,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () {
//                       if (isSold) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Product sold out'),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                         return;
//                       }
//                       if (_quantity > availableQuantity) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Selected quantity exceeds available stock'),
//                           ),
//                         );
//                         return;
//                       }
//                       final productWithQuantity = {
//                         ..._currentProduct,
//                         'selectedQuantity': _quantity,
//                         'negotiatedPrice': _negotiatedPrice,
//                       };
//                       clientState.toggleCart(productWithQuantity);
//                       if (!isInCart) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('${_currentProduct['title']} added to cart!'),
//                             backgroundColor: Colors.green,
//                           ),
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: isSold ? Colors.grey[400] : (isInCart ? Colors.grey : Colors.black),
//                       foregroundColor: Colors.white,
//                       minimumSize: const Size(double.infinity, 48),
//                     ),
//                     child: Text(
//                       isSold ? 'Sold Out' : (isInCart ? 'Added to Cart' : 'Add to Cart'),
//                       style: GoogleFonts.poppins(fontSize: 16),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: _initiateChat,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey[300],
//                       foregroundColor: Colors.black,
//                       minimumSize: const Size(double.infinity, 48),
//                     ),
//                     child: Text(
//                       'Contact Seller',
//                       style: GoogleFonts.poppins(fontSize: 16),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// version to fix quantity issue

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_fonts/google_fonts.dart';
// // import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:provider/provider.dart';
// import 'client-state.dart';
// import 'chatpage.dart';
// import 'clientreview.dart';
// import 'baseurl.dart';

// class ProductDetailPage extends StatefulWidget {
//   final Map<String, dynamic> product;

//   const ProductDetailPage({super.key, required this.product});

//   @override
//   _ProductDetailPageState createState() => _ProductDetailPageState();
// }

// class _ProductDetailPageState extends State<ProductDetailPage> {
//   int _selectedRating = 0;
//   int _quantity = 1;
//   double? _negotiatedPrice;
//   // final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';
//   late Map<String, dynamic> _currentProduct;

//   @override
//   void initState() {
//     super.initState();
//     _currentProduct = Map<String, dynamic>.from(widget.product);
//     _fetchNegotiatedPrice();
//     _fetchUserRating();
//     _fetchUpdatedProductDetails(_currentProduct['_id']);
//   }

//   Future<void> _fetchUserRating() async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;

//     if (token == null || token.isEmpty) {
//       print('Token is null or empty, skipping user rating fetch');
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/client-products/rating/${_currentProduct['_id']}'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('Fetch user rating response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _selectedRating = data['rating']?.toInt() ?? 0;
//         });
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         print('Failed to fetch user rating: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching user rating: $e');
//     }
//   }

//   Future<void> _fetchNegotiatedPrice() async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;

//     if (token == null || token.isEmpty) {
//       print('Token is null or empty, skipping negotiated price fetch');
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/discounts/${_currentProduct['_id']}'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('Fetch negotiated price response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _negotiatedPrice = data['negotiatedPrice']?.toDouble();
//         });
//       } else if (response.statusCode == 404) {
//         setState(() {
//           _negotiatedPrice = null;
//         });
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         print('Failed to fetch negotiated price: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching negotiated price: $e');
//     }
//   }

//   Future<void> _submitRating(String productId, int rating) async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;

//     if (token == null || token.isEmpty) {
//       print('Token is null or empty, redirecting to login');
//       Navigator.pushReplacementNamed(context, '/login');
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/client-products/rate-product'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'productId': productId,
//           'rating': rating,
//         }),
//       );

//       print('Submit rating response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Rating submitted successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         setState(() {
//           _selectedRating = rating;
//         });
//         await _fetchUpdatedProductDetails(productId);
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else if (response.statusCode == 404) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Product not found or rating service unavailable.'),
//           ),
//         );
//       } else {
//         String errorMessage = 'Unknown error';
//         try {
//           final errorBody = jsonDecode(response.body);
//           errorMessage = errorBody['error'] ?? 'Unknown error';
//         } catch (decodeError) {
//           print('Error decoding response body: $decodeError');
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to submit rating: $errorMessage')),
//         );
//       }
//     } catch (e) {
//       print('Error submitting rating: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error submitting rating: $e')),
//       );
//       if (e.toString().contains('Access token missing') || e.toString().contains('Invalid token')) {
//         Navigator.pushReplacementNamed(context, '/login');
//       }
//     }
//   }

//   Future<void> _fetchUpdatedProductDetails(String productId) async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/client-products?productId=$productId'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('Fetch updated product response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final List<dynamic> products = jsonDecode(response.body);
//         if (products.isNotEmpty) {
//           setState(() {
//             _currentProduct = products[0];
//             // Reset selected quantity if it exceeds available quantity
//             if (_quantity > (_currentProduct['quantity']?.toInt() ?? 0)) {
//               _quantity = _currentProduct['quantity']?.toInt() ?? 1;
//             }
//           });
//         }
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch updated product details: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error fetching updated product details: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching updated product details: $e')),
//       );
//     }
//   }

//   Future<void> _initiateChat() async {
//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;
//     final userId = clientState.userId;

//     print('Initiating chat - userId: $userId, token: $token, productId: ${widget.product['_id']}');

//     if (token == null || token.isEmpty) {
//       print('Token is null or empty, redirecting to login');
//       Navigator.pushReplacementNamed(context, '/login');
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/chat/initiate'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'productId': widget.product['_id']}),
//       );

//       print('Chat initiation response: ${response.statusCode} - ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final chatId = data['chatId'];

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ChatPage(
//               chatId: chatId,
//               productName: widget.product['title'] ?? 'Unknown Product',
//               token: token,
//             ),
//           ),
//         );
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         print('Authentication error (${response.statusCode}), redirecting to login');
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to initiate chat: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error initiating chat: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error initiating chat: $e')),
//       );
//       if (e.toString().contains('Access token missing') || e.toString().contains('Invalid token')) {
//         Navigator.pushReplacementNamed(context, '/login');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final clientState = Provider.of<ClientState>(context);
//     final imageUrl = _currentProduct['image'] != null
//         ? '$baseUrl${_currentProduct['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
//         : null;
//     final isInCart = clientState.cartProducts.any((p) => p['_id'] == _currentProduct['_id']);
//     final availableQuantity = _currentProduct['quantity']?.toInt() ?? 0;
//     final averageRating = _currentProduct['averageRating']?.toStringAsFixed(1) ?? '0.0';
//     final ratingCount = _currentProduct['ratingCount']?.toString() ?? '0';
//     final isSold = _currentProduct['productStatus'] == 'sold' || availableQuantity == 0;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Product Details',
//           style: GoogleFonts.poppins(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 300,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 image: imageUrl != null
//                     ? DecorationImage(
//                         image: NetworkImage(imageUrl),
//                         fit: BoxFit.cover,
//                         onError: (exception, stackTrace) {
//                           print('Error loading product image: $exception');
//                         },
//                       )
//                     : null,
//               ),
//               child: imageUrl == null
//                   ? const Center(
//                       child: Text(
//                         'No Image',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     )
//                   : null,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _currentProduct['title'] ?? 'Unknown Product',
//                     style: GoogleFonts.poppins(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.star,
//                         color: Colors.amber,
//                         size: 20,
//                       ),
//                       Text(
//                         '$averageRating ($ratingCount)',
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '${_currentProduct['price']?.toStringAsFixed(2) ?? '0.00'} ETB',
//                     style: GoogleFonts.poppins(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   if (_negotiatedPrice != null) ...[
//                     const SizedBox(height: 4),
//                     Text(
//                       'Negotiated Price: ${_negotiatedPrice!.toStringAsFixed(2)} ETB',
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 16),
//                   Text(
//                     'Rate this product',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: List.generate(5, (index) {
//                       return IconButton(
//                         icon: Icon(
//                           index < _selectedRating ? Icons.star : Icons.star_border,
//                           color: Colors.amber,
//                           size: 30,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _selectedRating = index + 1;
//                           });
//                           _submitRating(_currentProduct['_id'], _selectedRating);
//                         },
//                       );
//                     }),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Description',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     _currentProduct['description'] ?? 'No description available',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Quantity',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.remove),
//                         onPressed: () {
//                           setState(() {
//                             if (_quantity > 1) {
//                               _quantity--;
//                             }
//                           });
//                         },
//                       ),
//                       Text(
//                         '$_quantity',
//                         style: GoogleFonts.poppins(fontSize: 16),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.add),
//                         onPressed: () {
//                           setState(() {
//                             if (_quantity < availableQuantity) {
//                               _quantity++;
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Cannot exceed available quantity'),
//                                 ),
//                               );
//                             }
//                           });
//                         },
//                       ),
//                       const SizedBox(width: 16),
//                       Text(
//                         'Available: $availableQuantity',
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       const Spacer(),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ReviewPage(
//                                 productId: _currentProduct['_id'],
//                                 userRating: _selectedRating > 0 ? _selectedRating : null,
//                               ),
//                             ),
//                           );
//                         },
//                         child: Text(
//                           'Reviews',
//                           style: GoogleFonts.poppins(
//                             fontSize: 14,
//                             color: Colors.blue,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () {
//                       if (isSold) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Product sold out'),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                         return;
//                       }
//                       if (_quantity > availableQuantity) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Selected quantity exceeds available stock'),
//                           ),
//                         );
//                         return;
//                       }
//                       final productWithQuantity = {
//                         ..._currentProduct,
//                         'selectedQuantity': _quantity,
//                         'negotiatedPrice': _negotiatedPrice,
//                       };
//                       clientState.toggleCart(productWithQuantity);
//                       if (!isInCart) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('${_currentProduct['title']} added to cart!'),
//                             backgroundColor: Colors.green,
//                           ),
//                         );
//                       }
//                       // Refresh product details after adding to cart
//                       _fetchUpdatedProductDetails(_currentProduct['_id']);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: isSold ? Colors.grey[400] : (isInCart ? Colors.grey : Colors.black),
//                       foregroundColor: Colors.white,
//                       minimumSize: const Size(double.infinity, 48),
//                     ),
//                     child: Text(
//                       isSold ? 'Sold Out' : (isInCart ? 'Added to Cart' : 'Add to Cart'),
//                       style: GoogleFonts.poppins(fontSize: 16),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: _initiateChat,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey[300],
//                       foregroundColor: Colors.black,
//                       minimumSize: const Size(double.infinity, 48),
//                     ),
//                     child: Text(
//                       'Contact Seller',
//                       style: GoogleFonts.poppins(fontSize: 16),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// version to add cart icon 


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'client-state.dart';
import 'chatpage.dart';
import 'clientreview.dart';
import 'clientcart.dart';
import 'baseurl.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedRating = 0;
  int _quantity = 1;
  double? _negotiatedPrice;
  late Map<String, dynamic> _currentProduct;
  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147); // Match clienthomepage.dart
  final Color accentColor = const Color(0xFFFFD700); // Match clienthomepage.dart

  @override
  void initState() {
    super.initState();
    _currentProduct = Map<String, dynamic>.from(widget.product);
    _fetchNegotiatedPrice();
    _fetchUserRating();
    _fetchUpdatedProductDetails(_currentProduct['_id']);
  }

  Future<void> _fetchUserRating() async {
    final clientState = Provider.of<ClientState>(context, listen: false);
    final token = clientState.token;

    if (token == null || token.isEmpty) {
      print('Token is null or empty, skipping user rating fetch');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/client-products/rating/${_currentProduct['_id']}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Fetch user rating response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _selectedRating = data['rating']?.toInt() ?? 0;
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Authentication error (${response.statusCode}), redirecting to login');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        print('Failed to fetch user rating: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user rating: $e');
    }
  }

  Future<void> _fetchNegotiatedPrice() async {
    final clientState = Provider.of<ClientState>(context, listen: false);
    final token = clientState.token;

    if (token == null || token.isEmpty) {
      print('Token is null or empty, skipping negotiated price fetch');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/discounts/${_currentProduct['_id']}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Fetch negotiated price response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _negotiatedPrice = data['negotiatedPrice']?.toDouble();
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _negotiatedPrice = null;
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Authentication error (${response.statusCode}), redirecting to login');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        print('Failed to fetch negotiated price: ${response.body}');
      }
    } catch (e) {
      print('Error fetching negotiated price: $e');
    }
  }

  Future<void> _submitRating(String productId, int rating) async {
    final clientState = Provider.of<ClientState>(context, listen: false);
    final token = clientState.token;

    if (token == null || token.isEmpty) {
      print('Token is null or empty, redirecting to login');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/client-products/rate-product'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productId': productId,
          'rating': rating,
        }),
      );

      print('Submit rating response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Rating submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedRating = rating;
        });
        await _fetchUpdatedProductDetails(productId);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Authentication error (${response.statusCode}), redirecting to login');
        Navigator.pushReplacementNamed(context, '/login');
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product not found or rating service unavailable.'),
          ),
        );
      } else {
        String errorMessage = 'Unknown error';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['error'] ?? 'Unknown error';
        } catch (decodeError) {
          print('Error decoding response body: $decodeError');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit rating: $errorMessage')),
        );
      }
    } catch (e) {
      print('Error submitting rating: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating: $e')),
      );
      if (e.toString().contains('Access token missing') || e.toString().contains('Invalid token')) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _fetchUpdatedProductDetails(String productId) async {
    final clientState = Provider.of<ClientState>(context, listen: false);
    final token = clientState.token;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/client-products?productId=$productId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Fetch updated product response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> products = jsonDecode(response.body);
        if (products.isNotEmpty) {
          setState(() {
            _currentProduct = products[0];
            // Reset selected quantity if it exceeds available quantity
            if (_quantity > (_currentProduct['quantity']?.toInt() ?? 0)) {
              _quantity = _currentProduct['quantity']?.toInt() ?? 1;
            }
          });
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Authentication error (${response.statusCode}), redirecting to login');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch updated product details: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error fetching updated product details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching updated product details: $e')),
      );
    }
  }

  Future<void> _initiateChat() async {
    final clientState = Provider.of<ClientState>(context, listen: false);
    final token = clientState.token;
    final userId = clientState.userId;

    print('Initiating chat - userId: $userId, token: $token, productId: ${widget.product['_id']}');

    if (token == null || token.isEmpty) {
      print('Token is null or empty, redirecting to login');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/initiate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'productId': widget.product['_id']}),
      );

      print('Chat initiation response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final chatId = data['chatId'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatId: chatId,
              productName: widget.product['title'] ?? 'Unknown Product',
              token: token,
            ),
          ),
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Authentication error (${response.statusCode}), redirecting to login');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initiate chat: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error initiating chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initiating chat: $e')),
      );
      if (e.toString().contains('Access token missing') || e.toString().contains('Invalid token')) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientState = Provider.of<ClientState>(context);
    final imageUrl = _currentProduct['image'] != null
        ? '$baseUrl${_currentProduct['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
        : null;
    final isInCart = clientState.cartProducts.any((p) => p['_id'] == _currentProduct['_id']);
    final availableQuantity = _currentProduct['quantity']?.toInt() ?? 0;
    final averageRating = _currentProduct['averageRating']?.toStringAsFixed(1) ?? '0.0';
    final ratingCount = _currentProduct['ratingCount']?.toString() ?? '0';
    final isSold = _currentProduct['productStatus'] == 'sold' || availableQuantity == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Details',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              print('Error loading product image: $exception');
                            },
                          )
                        : null,
                  ),
                  child: imageUrl == null
                      ? const Center(
                          child: Text(
                            'No Image',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.shopping_cart, color: primaryColor),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ClientCartPage()),
                          );
                        },
                      ),
                      if (clientState.cartProducts.isNotEmpty)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${clientState.cartProducts.length}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentProduct['title'] ?? 'Unknown Product',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      Text(
                        '$averageRating ($ratingCount)',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentProduct['price']?.toStringAsFixed(2) ?? '0.00'} ETB',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      // color: Colors.black,
                      color:primaryColor,
                    ),
                  ),
                  if (_negotiatedPrice != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Negotiated Price: ${_negotiatedPrice!.toStringAsFixed(2)} ETB',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Rate this product',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedRating = index + 1;
                          });
                          _submitRating(_currentProduct['_id'], _selectedRating);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentProduct['description'] ?? 'No description available',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quantity',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (_quantity > 1) {
                              _quantity--;
                            }
                          });
                        },
                      ),
                      Text(
                        '$_quantity',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            if (_quantity < availableQuantity) {
                              _quantity++;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cannot exceed available quantity'),
                                ),
                              );
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Available: $availableQuantity',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewPage(
                                productId: _currentProduct['_id'],
                                userRating: _selectedRating > 0 ? _selectedRating : null,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Reviews',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (isSold) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Product sold out'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            if (_quantity > availableQuantity) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Selected quantity exceeds available stock'),
                                ),
                              );
                              return;
                            }
                            final productWithQuantity = {
                              ..._currentProduct,
                              'selectedQuantity': _quantity,
                              'negotiatedPrice': _negotiatedPrice,
                            };
                            clientState.toggleCart(productWithQuantity);
                            if (!isInCart) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${_currentProduct['title']} added to cart!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                            // Refresh product details after adding to cart
                            _fetchUpdatedProductDetails(_currentProduct['_id']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSold ? Colors.grey[400] : (isInCart ? Colors.grey : primaryColor),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                            shadowColor: Colors.grey.withOpacity(0.5),
                          ),
                          child: Text(
                            isSold ? 'Sold Out' : (isInCart ? 'Added to Cart' : 'Add to Cart'),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _initiateChat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: primaryColor),
                            ),
                            elevation: 5,
                            shadowColor: Colors.grey.withOpacity(0.5),
                          ),
                          child: Text(
                            'Contact Seller',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}