import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'baseurl.dart';

class SellerOrderController {
  static Future<List<dynamic>> fetchOrders(String sellerId, String token) async {
    try {
      final headers = <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final response = await http.get(
        Uri.parse('$baseUrl/seller/orders/$sellerId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to load orders: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }
}

class PendingOrdersController {
  static List<dynamic> filterPendingOrders(List<dynamic> orders) {
    return orders.where((order) => order['status'] == 'pending').toList();
  }
}

class CompletedOrdersController {
  static List<dynamic> filterCompletedOrders(List<dynamic> orders) {
    return orders.where((order) => order['status'] == 'completed').toList();
  }
}

class CancelledOrdersController {
  static List<dynamic> filterCancelledOrders(List<dynamic> orders) {
    return orders.where((order) => order['status'] == 'canceled').toList();
  }
}

class SoldBalanceController {
  static Map<String, Map<String, dynamic>> calculateSoldBalances(List<dynamic> orders) {
    final balances = <String, Map<String, dynamic>>{}; // Map of order ID to details
    final completedOrders = CompletedOrdersController.filterCompletedOrders(orders);
    double netBalance = 0.0;

    print('Processing ${completedOrders.length} completed orders for Sold Balance');

    for (var order in completedOrders) {
      final orderId = order['_id']?.toString() ?? 'unknown';
      double orderTotalOriginalPrice = 0.0;
      double orderTotalCommission = 0.0;
      double orderTotalNetPrice = 0.0;

      // Calculate based on individual product prices
      for (var item in order['items']) {
        double price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
        int quantity = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
        double productTotalPrice = price * quantity;
        double commission = productTotalPrice * 0.05; // 5% commission per product
        double netPrice = productTotalPrice * 0.95; // Net price after commission
        orderTotalOriginalPrice += productTotalPrice;
        orderTotalCommission += commission;
        orderTotalNetPrice += netPrice;
      }

      balances[orderId] = {
        'originalPrice': orderTotalOriginalPrice,
        'commission': orderTotalCommission,
        'netPrice': orderTotalNetPrice,
      };
      netBalance += orderTotalNetPrice;
      print('Order $orderId: Original Price = $orderTotalOriginalPrice, Commission = $orderTotalCommission, Net Price = $orderTotalNetPrice');
    }

    balances['netBalance'] = {'value': netBalance};
    return balances;
  }
}

class ClientOrdersPage extends StatefulWidget {
  final String sellerId;
  final String token;

  const ClientOrdersPage({super.key, required this.sellerId, required this.token});

  @override
  _ClientOrdersPageState createState() => _ClientOrdersPageState();
}

class _ClientOrdersPageState extends State<ClientOrdersPage> with SingleTickerProviderStateMixin {
  List<dynamic> _orders = [];
  List<dynamic> _pendingOrders = [];
  List<dynamic> _completedOrders = [];
  List<dynamic> _cancelledOrders = [];
  bool _isLoading = true;
  Map<String, Map<String, dynamic>> _soldBalances = {};
  late TabController _tabController;
  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);
  final Color accentColor = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await SellerOrderController.fetchOrders(widget.sellerId, widget.token);
      setState(() {
        _orders = orders;
        _pendingOrders = PendingOrdersController.filterPendingOrders(_orders);
        _completedOrders = CompletedOrdersController.filterCompletedOrders(_orders);
        _cancelledOrders = CancelledOrdersController.filterCancelledOrders(_orders);
        _soldBalances = SoldBalanceController.calculateSoldBalances(_orders);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      });
    }
  }

  String _formatDateTime(String? dateTime, {bool relative = false}) {
    if (dateTime == null) {
      return 'Not Set';
    }
    final date = DateTime.parse(dateTime);
    if (relative) {
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  Widget _buildOrderCard(dynamic order) {
    final orderDate = DateTime.parse(order['createdAt']);
    final deliveryDate = order['deliveryDate'] != null ? DateTime.parse(order['deliveryDate']) : null;
    final formattedOrderDate = DateFormat('MMM dd, yyyy').format(orderDate);
    final formattedDeliveryDate = deliveryDate != null ? DateFormat('MMM dd, yyyy').format(deliveryDate) : 'Not Set';

    Color statusColor;
    Color statusTextColor;
    switch (order['status'] ?? 'unknown') {
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        childrenPadding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
        title: Text(
          'Order #${order['_id']}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Status: ${order['status'].toString().capitalize()}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: statusColor,
              ),
            ),
            Text(
              'Order Date: $formattedOrderDate',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Date: $formattedDeliveryDate',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Items:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                ...order['items'].map<Widget>((item) {
                  // Debug log to confirm sellerId
                  print('Item in Order #${order['_id']}: sellerId = ${item['sellerId']}, expected = ${widget.sellerId}');
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
                                item['title'] ?? 'Unknown Product',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                'Qty: ${item['quantity']}',
                                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                              ),
                              Text(
                                'Price: ${(item['price'] * (item['quantity'] ?? 1)).toStringAsFixed(2)} ETB',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders) {
    return ListView.separated(
      padding: const EdgeInsets.all(12.0),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  Widget _buildSoldBalanceList() {
    final orderBalances = _soldBalances.entries
        .where((entry) => entry.key != 'netBalance')
        .toList();
    final netBalance = (_soldBalances['netBalance']?['value'] as double?) ?? 0.0;

    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        ...orderBalances.map((entry) {
          final orderId = entry.key;
          final originalPrice = entry.value['originalPrice'] as double;
          final commission = entry.value['commission'] as double;
          final netPrice = entry.value['netPrice'] as double;

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #$orderId',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Original Price: ${originalPrice.toStringAsFixed(2)} ETB',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '- 5% Commission: ${commission.toStringAsFixed(2)} ETB',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: Text(
                      'Net: ${netPrice.toStringAsFixed(2)} ETB',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: primaryColor, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Net Balance:',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Text(
                '${netBalance.toStringAsFixed(2)} ETB',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
        Container(
  color: primaryColor,  // This sets the background color
  child: TabBar(
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
      Tab(text: 'Sold Balance', icon: Icon(Icons.attach_money, size: 20)),
    ],
  ),
),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
                : _orders.isEmpty
                    ? Center(
                        child: Text(
                          'No orders available',
                          style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
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
                          _completedOrders.isEmpty
                              ? Center(
                                  child: Text(
                                    'No sold balances available',
                                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                                  ),
                                )
                              : _buildSoldBalanceList(),
                        ],
                      ),
          ),
        ],
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     backgroundColor: primaryColor,
    //     // title: Text(
    //     //   'Orders',
    //     //   style: GoogleFonts.poppins(
    //     //     fontSize: 20,
    //     //     fontWeight: FontWeight.bold,
    //     //     color: Colors.white,
    //     //   ),
    //     // ),
    //     bottom: TabBar(
    //       controller: _tabController,
    //       indicatorColor: accentColor,
    //       indicatorWeight: 3,
    //       labelColor: accentColor,
    //       unselectedLabelColor: Colors.white70,
    //       labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
    //       unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
    //       tabs: const [
    //         Tab(text: 'Pending', icon: Icon(Icons.pending, size: 20)),
    //         Tab(text: 'Completed', icon: Icon(Icons.check_circle, size: 20)),
    //         Tab(text: 'Cancelled', icon: Icon(Icons.cancel, size: 20)),
    //         Tab(text: 'Sold Balance', icon: Icon(Icons.attach_money, size: 20)),
    //       ],
    //     ),
    //   ),
    //   body: _isLoading
    //       ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))
    //       : _orders.isEmpty
    //           ? Center(
    //               child: Text(
    //                 'No orders available',
    //                 style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
    //               ),
    //             )
    //           : TabBarView(
    //               controller: _tabController,
    //               children: [
    //                 _pendingOrders.isEmpty
    //                     ? Center(
    //                         child: Text(
    //                           'No pending orders',
    //                           style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
    //                         ),
    //                       )
    //                     : _buildOrderList(_pendingOrders),
    //                 _completedOrders.isEmpty
    //                     ? Center(
    //                         child: Text(
    //                           'No completed orders',
    //                           style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
    //                         ),
    //                       )
    //                     : _buildOrderList(_completedOrders),
    //                 _cancelledOrders.isEmpty
    //                     ? Center(
    //                         child: Text(
    //                           'No cancelled orders',
    //                           style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
    //                         ),
    //                       )
    //                     : _buildOrderList(_cancelledOrders),
    //                 _completedOrders.isEmpty
    //                     ? Center(
    //                         child: Text(
    //                           'No sold balances available',
    //                           style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
    //                         ),
    //                       )
    //                     : _buildSoldBalanceList(),
    //               ],
    //             ),
    // );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}