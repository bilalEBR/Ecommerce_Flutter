// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart'; // Added for date formatting
// import 'client-state.dart';
// import 'loginpage.dart';

// class ClientOrdersPage extends StatefulWidget {
//   const ClientOrdersPage({super.key});

//   @override
//   _ClientOrdersPageState createState() => _ClientOrdersPageState();
// }

// class _ClientOrdersPageState extends State<ClientOrdersPage> {
//   final String baseUrl = 'http://localhost:3000';
//   List<Map<String, dynamic>> _orders = [];
//   bool _isLoading = true;
//   String? _errorMessage;
//   final Map<String, bool> _expandedOrders = {};

//   @override
//   void initState() {
//     super.initState();
//     _fetchClientOrders();
//   }

//   Future<void> _fetchClientOrders() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;
//     final userId = clientState.userId;

//     if (token == null || userId == null) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Authentication error: Please log in again.';
//       });
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/client/orders/$userId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           _orders = data.cast<Map<String, dynamic>>();
//           _isLoading = false;
//           for (var order in _orders) {
//             _expandedOrders[order['_id']] = false;
//           }
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to fetch orders: ${response.body}';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error fetching orders: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'My Orders',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage != null
//               ? Center(
//                   child: Text(
//                     _errorMessage!,
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       color: Colors.red,
//                     ),
//                   ),
//                 )
//               : _orders.isEmpty
//                   ? Center(
//                       child: Text(
//                         'No orders found.',
//                         style: GoogleFonts.poppins(fontSize: 16),
//                       ),
//                     )
//                   : ListView.separated(
//                       padding: const EdgeInsets.all(16.0),
//                       itemCount: _orders.length,
//                       separatorBuilder: (context, index) => const Divider(),
//                       itemBuilder: (context, index) {
//                         final order = _orders[index];
//                         final isExpanded = _expandedOrders[order['_id']] ?? false;

//                         // Format dates
//                         final orderDate = DateTime.parse(order['orderDate']);
//                         final deliveryDate = DateTime.parse(order['deliveryDate']);
//                         final formattedOrderDate = DateFormat('MMM dd, yyyy').format(orderDate);
//                         final formattedDeliveryDate = DateFormat('MMM dd, yyyy').format(deliveryDate);

//                         // Determine status background color
//                         Color statusColor;
//                         switch (order['status']) {
//                           case 'pending':
//                             statusColor = Colors.yellow;
//                             break;
//                           case 'completed':
//                             statusColor = Colors.green;
//                             break;
//                           case 'canceled':
//                             statusColor = Colors.red;
//                             break;
//                           default:
//                             statusColor = Colors.grey;
//                         }

//                         return Card(
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Column(
//                             children: [
//                               ListTile(
//                                 title: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Order #${order['_id']}',
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       'Order Date: $formattedOrderDate',
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 14,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       'Delivery Date: $formattedDeliveryDate',
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 14,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       'Total: ${order['total'].toStringAsFixed(2)} ETB',
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 trailing: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                       decoration: BoxDecoration(
//                                         color: statusColor,
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Text(
//                                         order['status'].toString().capitalize(),
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 12,
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Icon(
//                                       isExpanded
//                                           ? Icons.arrow_drop_up
//                                           : Icons.arrow_drop_down,
//                                       size: 24,
//                                     ),
//                                   ],
//                                 ),
//                                 onTap: () {
//                                   setState(() {
//                                     _expandedOrders[order['_id']] = !isExpanded;
//                                   });
//                                 },
//                               ),
//                               if (isExpanded) ...[
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 16.0, vertical: 8.0),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'Items:',
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       ...order['items'].map<Widget>((item) {
//                                         return Padding(
//                                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                                           child: Row(
//                                             children: [
//                                               Container(
//                                                 width: 50,
//                                                 height: 50,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius: BorderRadius.circular(8),
//                                                   image: item['image'] != null
//                                                       ? DecorationImage(
//                                                           image: NetworkImage('$baseUrl${item['image']}'),
//                                                           fit: BoxFit.cover,
//                                                         )
//                                                       : null,
//                                                 ),
//                                                 child: item['image'] == null
//                                                     ? const Center(child: Text('No Image'))
//                                                     : null,
//                                               ),
//                                               const SizedBox(width: 8),
//                                               Expanded(
//                                                 child: Text(
//                                                   'Qty ${item['quantity']} - ${(item['price'] * item['quantity']).toStringAsFixed(2)} ETB',
//                                                   style: GoogleFonts.poppins(fontSize: 14),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       }).toList(),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         'Shipping Address:',
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       Text(
//                                         order['shippingAddress'] != null
//                                             ? 'Full Name: ${order['shippingAddress']['fullName']}\n'
//                                               'Email: ${order['shippingAddress']['email']}\n'
//                                               'Phone: ${order['shippingAddress']['phoneNumber']}\n'
//                                               'Region: ${order['shippingAddress']['region']}\n'
//                                               'Postal Code: ${order['shippingAddress']['postalCode']}\n'
//                                               'City: ${order['shippingAddress']['city']}'
//                                             : 'Not Provided',
//                                         style: GoogleFonts.poppins(fontSize: 14),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         'Payment Method: ${order['paymentMethod']}',
//                                         style: GoogleFonts.poppins(fontSize: 14),
//                                       ),
//                                       Text(
//                                         'Transaction ID: ${order['transactionId']}',
//                                         style: GoogleFonts.poppins(fontSize: 14),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       if (order['recipientScreenshot'] != null)
//                                         Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'Recipient Screenshot:',
//                                               style: GoogleFonts.poppins(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             const SizedBox(height: 4),
//                                             Image.network(
//                                               '$baseUrl${order['recipientScreenshot']}',
//                                               height: 100,
//                                               fit: BoxFit.cover,
//                                               errorBuilder: (context, error, stackTrace) {
//                                                 return const Text('Error loading image');
//                                               },
//                                             ),
//                                           ],
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//     );
//   }
// }

// // Extension to capitalize the first letter of a string
// extension StringExtension on String {
//   String capitalize() {
//     return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
//   }
// }

// version to add tab comtroller 

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'client-state.dart';
// import 'loginpage.dart';
// import 'baseurl.dart';

// class ClientOrdersPage extends StatefulWidget {
//   const ClientOrdersPage({super.key});

//   @override
//   _ClientOrdersPageState createState() => _ClientOrdersPageState();
// }

// class _ClientOrdersPageState extends State<ClientOrdersPage> with SingleTickerProviderStateMixin {
//   // final String baseUrl = 'http://localhost:3000';
//   List<Map<String, dynamic>> _orders = [];
//   List<Map<String, dynamic>> _pendingOrders = [];
//   List<Map<String, dynamic>> _completedOrders = [];
//   List<Map<String, dynamic>> _cancelledOrders = [];
//   bool _isLoading = true;
//   String? _errorMessage;
//   final Map<String, bool> _expandedOrders = {};
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _fetchClientOrders();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchClientOrders() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;
//     final userId = clientState.userId;

//     if (token == null || userId == null) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Authentication error: Please log in again.';
//       });
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/client/orders/$userId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           _orders = data.cast<Map<String, dynamic>>();
//           _pendingOrders = _orders.where((order) => order['status'] == 'pending').toList();
//           _completedOrders = _orders.where((order) => order['status'] == 'completed').toList();
//           _cancelledOrders = _orders.where((order) => order['status'] == 'canceled').toList();
//           _isLoading = false;
//           for (var order in _orders) {
//             _expandedOrders[order['_id']] = false;
//           }
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to fetch orders: ${response.body}';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error fetching orders: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   Widget _buildOrderCard(Map<String, dynamic> order) {
//     final isExpanded = _expandedOrders[order['_id']] ?? false;
//     final orderDate = DateTime.parse(order['orderDate']);
//     final deliveryDate = DateTime.parse(order['deliveryDate']);
//     final formattedOrderDate = DateFormat('MMM dd, yyyy').format(orderDate);
//     final formattedDeliveryDate = DateFormat('MMM dd, yyyy').format(deliveryDate);

//     Color statusColor;
//     switch (order['status']) {
//       case 'pending':
//         statusColor = Colors.yellow;
//         break;
//       case 'completed':
//         statusColor = Colors.green;
//         break;
//       case 'canceled':
//         statusColor = Colors.red;
//         break;
//       default:
//         statusColor = Colors.grey;
//     }

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           ListTile(
//             title: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Order #${order['_id']}',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Order Date: $formattedOrderDate',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Delivery Date: $formattedDeliveryDate',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Total: ${order['total'].toStringAsFixed(2)} ETB',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: statusColor,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     order['status'].toString().capitalize(),
//                     style: GoogleFonts.poppins(
//                       fontSize: 12,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Icon(
//                   isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
//                   size: 24,
//                 ),
//               ],
//             ),
//             onTap: () {
//               setState(() {
//                 _expandedOrders[order['_id']] = !isExpanded;
//               });
//             },
//           ),
//           if (isExpanded) ...[
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Items:',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   ...order['items'].map<Widget>((item) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4.0),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                               image: item['image'] != null
//                                   ? DecorationImage(
//                                       image: NetworkImage('$baseUrl${item['image']}'),
//                                       fit: BoxFit.cover,
//                                     )
//                                   : null,
//                             ),
//                             child: item['image'] == null
//                                 ? const Center(child: Text('No Image'))
//                                 : null,
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               'Qty ${item['quantity']} - ${(item['price'] * item['quantity']).toStringAsFixed(2)} ETB',
//                               style: GoogleFonts.poppins(fontSize: 14),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Shipping Address:',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     order['shippingAddress'] != null
//                         ? 'Full Name: ${order['shippingAddress']['fullName']}\n'
//                           'Email: ${order['shippingAddress']['email']}\n'
//                           'Phone: ${order['shippingAddress']['phoneNumber']}\n'
//                           'Region: ${order['shippingAddress']['region']}\n'
//                           'Postal Code: ${order['shippingAddress']['postalCode']}\n'
//                           'City: ${order['shippingAddress']['city']}'
//                         : 'Not Provided',
//                     style: GoogleFonts.poppins(fontSize: 14),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Payment Method: ${order['paymentMethod']}',
//                     style: GoogleFonts.poppins(fontSize: 14),
//                   ),
//                   Text(
//                     'Transaction ID: ${order['transactionId']}',
//                     style: GoogleFonts.poppins(fontSize: 14),
//                   ),
//                   const SizedBox(height: 8),
//                   if (order['recipientScreenshot'] != null)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Recipient Screenshot:',
//                           style: GoogleFonts.poppins(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Image.network(
//                           '$baseUrl${order['recipientScreenshot']}',
//                           height: 100,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return const Text('Error loading image');
//                           },
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderList(List<Map<String, dynamic>> orders) {
//     return ListView.separated(
//       padding: const EdgeInsets.all(16.0),
//       itemCount: orders.length,
//       separatorBuilder: (context, index) => const Divider(),
//       itemBuilder: (context, index) => _buildOrderCard(orders[index]),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'My Orders',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'Pending', icon: Icon(Icons.pending)),
//             Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
//             Tab(text: 'Cancelled', icon: Icon(Icons.cancel)),
//           ],
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage != null
//               ? Center(
//                   child: Text(
//                     _errorMessage!,
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       color: Colors.red,
//                     ),
//                   ),
//                 )
//               : TabBarView(
//                   controller: _tabController,
//                   children: [
//                     _pendingOrders.isEmpty
//                         ? Center(child: Text('No pending orders', style: GoogleFonts.poppins()))
//                         : _buildOrderList(_pendingOrders),
//                     _completedOrders.isEmpty
//                         ? Center(child: Text('No completed orders', style: GoogleFonts.poppins()))
//                         : _buildOrderList(_completedOrders),
//                     _cancelledOrders.isEmpty
//                         ? Center(child: Text('No cancelled orders', style: GoogleFonts.poppins()))
//                         : _buildOrderList(_cancelledOrders),
//                   ],
//                 ),
//     );
//   }
// }

// extension StringExtension on String {
//   String capitalize() {
//     return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
//   }
// }

// version ui

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'client-state.dart';
// import 'loginpage.dart';
// import 'baseurl.dart';

// class ClientOrdersPage extends StatefulWidget {
//   const ClientOrdersPage({super.key});

//   @override
//   _ClientOrdersPageState createState() => _ClientOrdersPageState();
// }

// class _ClientOrdersPageState extends State<ClientOrdersPage> with SingleTickerProviderStateMixin {
//   List<Map<String, dynamic>> _orders = [];
//   List<Map<String, dynamic>> _pendingOrders = [];
//   List<Map<String, dynamic>> _completedOrders = [];
//   List<Map<String, dynamic>> _cancelledOrders = [];
//   bool _isLoading = true;
//   String? _errorMessage;
//   final Map<String, bool> _expandedOrders = {};
//   late TabController _tabController;

//   // Color scheme
//   final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);
//   final Color accentColor = const Color(0xFFFFD700);

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _fetchClientOrders();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchClientOrders() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;
//     final userId = clientState.userId;

//     if (token == null || userId == null) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Authentication error: Please log in again.';
//       });
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/client/orders/$userId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           _orders = data.cast<Map<String, dynamic>>();
//           _pendingOrders = _orders.where((order) => order['status'] == 'pending').toList();
//           _completedOrders = _orders.where((order) => order['status'] == 'completed').toList();
//           _cancelledOrders = _orders.where((order) => order['status'] == 'canceled').toList();
//           _isLoading = false;
//           for (var order in _orders) {
//             _expandedOrders[order['_id']] = false;
//           }
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to fetch orders: ${response.body}';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error fetching orders: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   Widget _buildOrderCard(Map<String, dynamic> order) {
//     final isExpanded = _expandedOrders[order['_id']] ?? false;
//     final orderDate = DateTime.parse(order['orderDate']);
//     final deliveryDate = DateTime.parse(order['deliveryDate']);
//     final formattedOrderDate = DateFormat('MMM dd, yyyy').format(orderDate);
//     final formattedDeliveryDate = DateFormat('MMM dd, yyyy').format(deliveryDate);

//     Color statusColor;
//     Color statusTextColor;
//     switch (order['status']) {
//       case 'pending':
//         statusColor = accentColor;
//         statusTextColor = Colors.black;
//         break;
//       case 'completed':
//         statusColor = Colors.green;
//         statusTextColor = Colors.white;
//         break;
//       case 'canceled':
//         statusColor = Colors.red;
//         statusTextColor = Colors.white;
//         break;
//       default:
//         statusColor = Colors.grey;
//         statusTextColor = Colors.black;
//     }

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey[200]!, width: 1),
//       ),
//       child: Column(
//         children: [
//           ListTile(
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             title: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Order #${order['_id']}',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: primaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Order Date: $formattedOrderDate',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Delivery Date: $formattedDeliveryDate',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Total: ${order['total'].toStringAsFixed(2)} ETB',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: primaryColor,
//                   ),
//                 ),
//               ],
//             ),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: statusColor,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.3),
//                         spreadRadius: 1,
//                         blurRadius: 3,
//                         offset: const Offset(0, 1),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     order['status'].toString().capitalize(),
//                     style: GoogleFonts.poppins(
//                       fontSize: 12,
//                       color: statusTextColor,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Icon(
//                   isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
//                   size: 24,
//                   color: primaryColor,
//                 ),
//               ],
//             ),
//             onTap: () {
//               setState(() {
//                 _expandedOrders[order['_id']] = !isExpanded;
//               });
//             },
//           ),
//           if (isExpanded) ...[
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Items:',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: primaryColor,
//                     ),
//                   ),
//                   ...order['items'].map<Widget>((item) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 6.0),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 60,
//                             height: 60,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: Colors.grey[300]!),
//                               image: item['image'] != null
//                                   ? DecorationImage(
//                                       image: NetworkImage('$baseUrl${item['image']}'),
//                                       fit: BoxFit.cover,
//                                     )
//                                   : null,
//                             ),
//                             child: item['image'] == null
//                                 ? const Center(child: Text('No Image', style: TextStyle(fontSize: 12)))
//                                 : null,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Qty ${item['quantity']}',
//                                   style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
//                                 ),
//                                 Text(
//                                   '${(item['price'] * item['quantity']).toStringAsFixed(2)} ETB',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: primaryColor,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                   const SizedBox(height: 12),
//                   Text(
//                     'Shipping Address:',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: primaryColor,
//                     ),
//                   ),
//                   Text(
//                     order['shippingAddress'] != null
//                         ? 'Full Name: ${order['shippingAddress']['fullName']}\n'
//                           'Email: ${order['shippingAddress']['email']}\n'
//                           'Phone: ${order['shippingAddress']['phoneNumber']}\n'
//                           'Region: ${order['shippingAddress']['region']}\n'
//                           'Postal Code: ${order['shippingAddress']['postalCode']}\n'
//                           'City: ${order['shippingAddress']['city']}'
//                         : 'Not Provided',
//                     style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     'Payment Method: ${order['paymentMethod']}',
//                     style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
//                   ),
//                   Text(
//                     'Transaction ID: ${order['transactionId']}',
//                     style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
//                   ),
//                   const SizedBox(height: 12),
//                   if (order['recipientScreenshot'] != null)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Recipient Screenshot:',
//                           style: GoogleFonts.poppins(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: primaryColor,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: Image.network(
//                             '$baseUrl${order['recipientScreenshot']}',
//                             height: 120,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return const Text('Error loading image', style: TextStyle(color: Colors.red));
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderList(List<Map<String, dynamic>> orders) {
//     return ListView.separated(
//       padding: const EdgeInsets.all(12.0),
//       itemCount: orders.length,
//       separatorBuilder: (context, index) => const SizedBox(height: 12),
//       itemBuilder: (context, index) => _buildOrderCard(orders[index]),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: Text(
//           'My Orders',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 2,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: accentColor,
//           indicatorWeight: 3,
//           labelColor: accentColor,
//           unselectedLabelColor: Colors.white70,
//           labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
//           unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
//           tabs: const [
//             Tab(text: 'Pending', icon: Icon(Icons.pending, size: 20)),
//             Tab(text: 'Completed', icon: Icon(Icons.check_circle, size: 20)),
//             Tab(text: 'Cancelled', icon: Icon(Icons.cancel, size: 20)),
//           ],
//         ),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
//           : _errorMessage != null
//               ? Center(
//                   child: Text(
//                     _errorMessage!,
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       color: Colors.red,
//                     ),
//                   ),
//                 )
//               : TabBarView(
//                   controller: _tabController,
//                   children: [
//                     _pendingOrders.isEmpty
//                         ? Center(
//                             child: Text(
//                               'No pending orders',
//                               style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
//                             ),
//                           )
//                         : _buildOrderList(_pendingOrders),
//                     _completedOrders.isEmpty
//                         ? Center(
//                             child: Text(
//                               'No completed orders',
//                               style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
//                             ),
//                           )
//                         : _buildOrderList(_completedOrders),
//                     _cancelledOrders.isEmpty
//                         ? Center(
//                             child: Text(
//                               'No cancelled orders',
//                               style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
//                             ),
//                           )
//                         : _buildOrderList(_cancelledOrders),
//                   ],
//                 ),
//     );
//   }
// }

// extension StringExtension on String {
//   String capitalize() {
//     return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
//   }
// }

// version to update order(successfully)

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'client-state.dart';
// import 'loginpage.dart';
// import 'baseurl.dart';

// class ClientOrdersPage extends StatefulWidget {
//   const ClientOrdersPage({super.key});

//   @override
//   _ClientOrdersPageState createState() => _ClientOrdersPageState();
// }

// class _ClientOrdersPageState extends State<ClientOrdersPage> with SingleTickerProviderStateMixin {
//   List<Map<String, dynamic>> _orders = [];
//   List<Map<String, dynamic>> _pendingOrders = [];
//   List<Map<String, dynamic>> _completedOrders = [];
//   List<Map<String, dynamic>> _cancelledOrders = [];
//   bool _isLoading = true;
//   String? _errorMessage;
//   final Map<String, bool> _expandedOrders = {};
//   late TabController _tabController;

//   final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);
//   final Color accentColor = const Color(0xFFFFD700);

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _fetchClientOrders();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchClientOrders() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     final clientState = Provider.of<ClientState>(context, listen: false);
//     final token = clientState.token;
//     final userId = clientState.userId;

//     if (token == null || userId == null) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Authentication error: Please log in again.';
//       });
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/client/orders/$userId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           _orders = data.cast<Map<String, dynamic>>();
//           _pendingOrders = _orders.where((order) => order['status'] == 'pending').toList();
//           _completedOrders = _orders.where((order) => order['status'] == 'completed').toList();
//           _cancelledOrders = _orders.where((order) => order['status'] == 'canceled').toList();
//           _isLoading = false;
//           for (var order in _orders) {
//             _expandedOrders[order['_id']] = false;
//           }
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to fetch orders: ${response.body}';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error fetching orders: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   Widget _buildOrderCard(Map<String, dynamic> order) {
//     final isExpanded = _expandedOrders[order['_id']] ?? false;
//     final orderDate = DateTime.parse(order['orderDate']);
//     final deliveryDate = order['deliveryDate'] != null ? DateTime.parse(order['deliveryDate']) : null;
//     final formattedOrderDate = DateFormat('MMM dd, yyyy').format(orderDate);
//     final formattedDeliveryDate = deliveryDate != null ? DateFormat('MMM dd, yyyy').format(deliveryDate) : 'Not Set';

//     Color statusColor;
//     Color statusTextColor;
//     switch (order['status']) {
//       case 'pending':
//         statusColor = accentColor;
//         statusTextColor = Colors.black;
//         break;
//       case 'completed':
//         statusColor = Colors.green;
//         statusTextColor = Colors.white;
//         break;
//       case 'canceled':
//         statusColor = Colors.red;
//         statusTextColor = Colors.white;
//         break;
//       default:
//         statusColor = Colors.grey;
//         statusTextColor = Colors.black;
//     }

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey[200]!, width: 1),
//       ),
//       child: Column(
//         children: [
//           ListTile(
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             title: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Order #${order['_id']}',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: primaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Order Date: $formattedOrderDate',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Delivery Date: $formattedDeliveryDate',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Total: ${order['total'].toStringAsFixed(2)} ETB',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: primaryColor,
//                   ),
//                 ),
//               ],
//             ),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: statusColor,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.3),
//                         spreadRadius: 1,
//                         blurRadius: 3,
//                         offset: const Offset(0, 1),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     order['status'].toString().capitalize(),
//                     style: GoogleFonts.poppins(
//                       fontSize: 12,
//                       color: statusTextColor,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Icon(
//                   isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
//                   size: 24,
//                   color: primaryColor,
//                 ),
//               ],
//             ),
//             onTap: () {
//               setState(() {
//                 _expandedOrders[order['_id']] = !isExpanded;
//               });
//             },
//           ),
//           if (isExpanded) ...[
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Items:',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: primaryColor,
//                     ),
//                   ),
//                   ...order['items'].map<Widget>((item) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 6.0),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 60,
//                             height: 60,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: Colors.grey[300]!),
//                               image: item['image'] != null
//                                   ? DecorationImage(
//                                       image: NetworkImage('$baseUrl${item['image']}'),
//                                       fit: BoxFit.cover,
//                                     )
//                                   : null,
//                             ),
//                             child: item['image'] == null
//                                 ? const Center(child: Text('No Image', style: TextStyle(fontSize: 12)))
//                                 : null,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Qty ${item['quantity']}',
//                                   style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
//                                 ),
//                                 Text(
//                                   '${(item['price'] * item['quantity']).toStringAsFixed(2)} ETB',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: primaryColor,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                   const SizedBox(height: 12),
//                   Text(
//                     'Shipping Address:',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: primaryColor,
//                     ),
//                   ),
//                   Text(
//                     order['shippingAddress'] != null
//                         ? 'Full Name: ${order['shippingAddress']['fullName']}\n'
//                           'Email: ${order['shippingAddress']['email']}\n'
//                           'Phone: ${order['shippingAddress']['phoneNumber']}\n'
//                           'Region: ${order['shippingAddress']['region']}\n'
//                           'Postal Code: ${order['shippingAddress']['postalCode']}\n'
//                           'City: ${order['shippingAddress']['city']}'
//                         : 'Not Provided',
//                     style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     'Payment Method: ${order['paymentMethod']}',
//                     style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
//                   ),
//                   Text(
//                     'Transaction ID: ${order['transactionId']}',
//                     style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
//                   ),
//                   const SizedBox(height: 12),
//                   if (order['recipientScreenshot'] != null)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Recipient Screenshot:',
//                           style: GoogleFonts.poppins(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: primaryColor,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: Image.network(
//                             '$baseUrl${order['recipientScreenshot']}',
//                             height: 120,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return const Text('Error loading image', style: TextStyle(color: Colors.red));
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderList(List<Map<String, dynamic>> orders) {
//     return ListView.separated(
//       padding: const EdgeInsets.all(12.0),
//       itemCount: orders.length,
//       separatorBuilder: (context, index) => const SizedBox(height: 12),
//       itemBuilder: (context, index) => _buildOrderCard(orders[index]),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: Text(
//           'My Orders',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 2,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: accentColor,
//           indicatorWeight: 3,
//           labelColor: accentColor,
//           unselectedLabelColor: Colors.white70,
//           labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
//           unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
//           tabs: const [
//             Tab(text: 'Pending', icon: Icon(Icons.pending, size: 20)),
//             Tab(text: 'Completed', icon: Icon(Icons.check_circle, size: 20)),
//             Tab(text: 'Cancelled', icon: Icon(Icons.cancel, size: 20)),
//           ],
//         ),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
//           : _errorMessage != null
//               ? Center(
//                   child: Text(
//                     _errorMessage!,
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       color: Colors.red,
//                     ),
//                   ),
//                 )
//               : TabBarView(
//                   controller: _tabController,
//                   children: [
//                     _pendingOrders.isEmpty
//                         ? Center(
//                             child: Text(
//                               'No pending orders',
//                               style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
//                             ),
//                           )
//                         : _buildOrderList(_pendingOrders),
//                     _completedOrders.isEmpty
//                         ? Center(
//                             child: Text(
//                               'No completed orders',
//                               style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
//                             ),
//                           )
//                         : _buildOrderList(_completedOrders),
//                     _cancelledOrders.isEmpty
//                         ? Center(
//                             child: Text(
//                               'No cancelled orders',
//                               style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
//                             ),
//                           )
//                         : _buildOrderList(_cancelledOrders),
//                   ],
//                 ),
//     );
//   }
// }

// extension StringExtension on String {
//   String capitalize() {
//     return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
//   }
// }

// version to sort 

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'client-state.dart';
import 'loginpage.dart';
import 'baseurl.dart';

class ClientOrdersPage extends StatefulWidget {
  const ClientOrdersPage({super.key});

  @override
  _ClientOrdersPageState createState() => _ClientOrdersPageState();
}

class _ClientOrdersPageState extends State<ClientOrdersPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _pendingOrders = [];
  List<Map<String, dynamic>> _completedOrders = [];
  List<Map<String, dynamic>> _cancelledOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, bool> _expandedOrders = {};
  late TabController _tabController;

  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);
  final Color accentColor = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchClientOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchClientOrders() async {
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/client/orders/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _orders = data.cast<Map<String, dynamic>>();
          _orders.sort((a, b) => DateTime.parse(b['orderDate']).compareTo(DateTime.parse(a['orderDate'])));
          _pendingOrders = _orders.where((order) => order['status'] == 'pending').toList();
          _completedOrders = _orders.where((order) => order['status'] == 'completed').toList();
          _cancelledOrders = _orders.where((order) => order['status'] == 'canceled').toList();
          _isLoading = false;
          for (var order in _orders) {
            _expandedOrders[order['_id']] = false;
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch orders: ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching orders: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final isExpanded = _expandedOrders[order['_id']] ?? false;
    final orderDate = DateTime.parse(order['orderDate']);
    final deliveryDate = order['deliveryDate'] != null ? DateTime.parse(order['deliveryDate']) : null;
    final formattedOrderDate = DateFormat('MMM dd, yyyy').format(orderDate);
    final formattedDeliveryDate = deliveryDate != null ? DateFormat('MMM dd, yyyy').format(deliveryDate) : 'Not Set';

    Color statusColor;
    Color statusTextColor;
    switch (order['status']) {
      case 'pending':
        statusColor = accentColor;
        statusTextColor = Colors.black;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusTextColor = Colors.white;
        break;
      case 'canceled':
        statusColor = Colors.red;
        statusTextColor = Colors.white;
        break;
      default:
        statusColor = Colors.grey;
        statusTextColor = Colors.black;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order['_id']}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order Date: $formattedOrderDate',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Delivery Date: $formattedDeliveryDate',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: ${order['total'].toStringAsFixed(2)} ETB',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    order['status'].toString().capitalize(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: statusTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 24,
                  color: primaryColor,
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _expandedOrders[order['_id']] = !isExpanded;
              });
            },
          ),
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  ...order['items'].map<Widget>((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[300]!),
                              image: item['image'] != null
                                  ? DecorationImage(
                                      image: NetworkImage('$baseUrl${item['image']}'),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: item['image'] == null
                                ? const Center(child: Text('No Image', style: TextStyle(fontSize: 12)))
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Qty ${item['quantity']}',
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                                ),
                                Text(
                                  '${(item['price'] * item['quantity']).toStringAsFixed(2)} ETB',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 12),
                  Text(
                    'Shipping Address:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    order['shippingAddress'] != null
                        ? 'Full Name: ${order['shippingAddress']['fullName']}\n'
                          'Email: ${order['shippingAddress']['email']}\n'
                          'Phone: ${order['shippingAddress']['phoneNumber']}\n'
                          'Region: ${order['shippingAddress']['region']}\n'
                          'Postal Code: ${order['shippingAddress']['postalCode']}\n'
                          'City: ${order['shippingAddress']['city']}'
                        : 'Not Provided',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Payment Method: ${order['paymentMethod']}',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                  ),
                  Text(
                    'Transaction ID: ${order['transactionId']}',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 12),
                  if (order['recipientScreenshot'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recipient Screenshot:',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            '$baseUrl${order['recipientScreenshot']}',
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text('Error loading image', style: TextStyle(color: Colors.red));
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders) {
    return ListView.separated(
      padding: const EdgeInsets.all(12.0),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentColor,
          indicatorWeight: 3,
          labelColor: accentColor,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
          tabs: const [
            Tab(text: 'Pending', icon: Icon(Icons.pending, size: 20)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle, size: 20)),
            Tab(text: 'Cancelled', icon: Icon(Icons.cancel, size: 20)),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _pendingOrders.isEmpty
                        ? Center(
                            child: Text(
                              'No pending orders',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                            ),
                          )
                        : _buildOrderList(_pendingOrders),
                    _completedOrders.isEmpty
                        ? Center(
                            child: Text(
                              'No completed orders',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                            ),
                          )
                        : _buildOrderList(_completedOrders),
                    _cancelledOrders.isEmpty
                        ? Center(
                            child: Text(
                              'No cancelled orders',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                            ),
                          )
                        : _buildOrderList(_cancelledOrders),
                  ],
                ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}