
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'baseurl.dart';

class AdminOrdersPage extends StatefulWidget {
  final String adminId;

  const AdminOrdersPage({super.key, required this.adminId});

  @override
  _AdminOrdersPageState createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _pendingOrders = [];
  List<Map<String, dynamic>> _completedOrders = [];
  List<Map<String, dynamic>> _cancelledOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, bool> _expandedOrders = {};
  final TextEditingController _adminTransactionIdController =
      TextEditingController();
  final TextEditingController _deleteConfirmationController =
      TextEditingController();
  late TabController _tabController;

  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);
  final Color accentColor = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAllOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _adminTransactionIdController.dispose();
    _deleteConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/orders'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _orders = data.cast<Map<String, dynamic>>();
          _pendingOrders =
              _orders.where((order) => order['status'] == 'pending').toList();
          _completedOrders =
              _orders.where((order) => order['status'] == 'completed').toList();
          _cancelledOrders =
              _orders.where((order) => order['status'] == 'canceled').toList();
          _isLoading = false;
          for (var order in _orders) {
            _expandedOrders[order['_id']] = false;
          }
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to fetch orders: ${response.statusCode} - ${response.body}';
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

  Future<void> _updateOrderStatus(
    String orderId,
    String newStatus, {
    int retryCount = 0,
  }) async {
    if (!RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(orderId)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid order ID format')),
        );
      }
      return;
    }

    const maxRetries = 2;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/orders/$orderId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status': newStatus,
          if (newStatus == 'completed')
            'deliveryDate':
                DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (mounted) {
          setState(() {
            final orderIndex = _orders.indexWhere(
              (order) => order['_id'] == orderId,
            );
            if (orderIndex != -1) {
              _orders[orderIndex]['status'] = newStatus;
              if (newStatus == 'completed') {
                _orders[orderIndex]['deliveryDate'] =
                    DateTime.now()
                        .add(const Duration(days: 3))
                        .toIso8601String();
              }
            }
            _pendingOrders =
                _orders.where((order) => order['status'] == 'pending').toList();
            _completedOrders =
                _orders
                    .where((order) => order['status'] == 'completed')
                    .toList();
            _cancelledOrders =
                _orders
                    .where((order) => order['status'] == 'canceled')
                    .toList();
          });
        }
        await _fetchAllOrders();
      } else {
        String errorMessage = 'Unknown error';
        try {
          if (response.body.isNotEmpty) {
            final errorBody = jsonDecode(response.body);
            errorMessage = errorBody['message'] ?? response.body;
          } else {
            errorMessage = 'Empty response from server';
          }
        } catch (e) {
          errorMessage =
              response.body.isNotEmpty ? response.body : 'No response details';
        }
        if (response.statusCode >= 500 && retryCount < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
          return _updateOrderStatus(
            orderId,
            newStatus,
            retryCount: retryCount + 1,
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update order status: $errorMessage'),
            ),
          );
        }
      }
    } catch (e) {
      if (retryCount < maxRetries && e.toString().contains('SocketException')) {
        await Future.delayed(const Duration(milliseconds: 500));
        return _updateOrderStatus(
          orderId,
          newStatus,
          retryCount: retryCount + 1,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating order status: $e')),
        );
      }
    }
  }

  Future<void> _deleteOrder(String orderId, {int retryCount = 0}) async {
    if (!RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(orderId)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid order ID format')),
        );
      }
      return;
    }

    const maxRetries = 2;
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          await _fetchAllOrders();
        }
      } else {
        String errorMessage = 'Unknown error';
        try {
          if (response.body.isNotEmpty) {
            final errorBody = jsonDecode(response.body);
            errorMessage = errorBody['message'] ?? response.body;
          } else {
            errorMessage = 'Empty response from server';
          }
        } catch (e) {
          errorMessage =
              response.body.isNotEmpty ? response.body : 'No response details';
        }
        if (response.statusCode >= 500 && retryCount < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
          return _deleteOrder(orderId, retryCount: retryCount + 1);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete order: $errorMessage')),
          );
        }
      }
    } catch (e) {
      if (retryCount < maxRetries && e.toString().contains('SocketException')) {
        await Future.delayed(const Duration(milliseconds: 500));
        return _deleteOrder(orderId, retryCount: retryCount + 1);
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting order: $e')));
      }
    }
  }

  String? _validateTransactionId(String transactionId) {
    if (transactionId.isEmpty) {
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

  void _showVerificationDrawer(Map<String, dynamic> order) {
    _fetchAllOrders().then((_) {
      if (!_orders.any((o) => o['_id'] == order['_id'])) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order no longer exists')),
          );
        }
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (modalContext) {
          return _VerificationModalContent(
            order: order,
            adminTransactionIdController: _adminTransactionIdController,
            onVerify: (adminTransactionId) {
              if (adminTransactionId == order['transactionId']) {
                Navigator.pop(modalContext);
                _updateOrderStatus(order['_id'], 'completed').then((_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Order status updated to completed successfully',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                });
              } else {
                Navigator.pop(modalContext);
                _showCancelDialog(order);
              }
            },
          );
        },
      ).whenComplete(() {
        _adminTransactionIdController.clear();
      });
    });
  }

  void _showCancelDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Transaction ID Mismatch',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          content: Text(
            'Do you want to cancel the order?',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showVerificationDrawer(order);
              },
              child: Text(
                'Try Again',
                style: GoogleFonts.poppins(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateOrderStatus(order['_id'], 'canceled');
              },
              child: Text('Yes', style: GoogleFonts.poppins(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Order #${order['_id']}',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Type "DELETE" to confirm deletion of this order.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _deleteConfirmationController,
                decoration: InputDecoration(
                  labelText: 'Confirmation',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteConfirmationController.clear();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_deleteConfirmationController.text == 'DELETE') {
                  Navigator.pop(context);
                  _deleteOrder(order['_id']);
                  _deleteConfirmationController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please type "DELETE" to confirm'),
                    ),
                  );
                }
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final isExpanded = _expandedOrders[order['_id']] ?? false;
    final orderDate = DateTime.parse(order['orderDate']);
    final deliveryDate =
        order['deliveryDate'] != null
            ? DateTime.parse(order['deliveryDate'])
            : null;
    final formattedOrderDate = DateFormat('MMM dd, yyyy').format(orderDate);
    final formattedDeliveryDate =
        deliveryDate != null
            ? DateFormat('MMM dd, yyyy').format(deliveryDate)
            : 'Not Set';

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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 2,
            ),
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
                if (order['status'] == 'pending')
                  GestureDetector(
                    onTap: () => _showVerificationDrawer(order),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
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
                        'Verify',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (order['status'] == 'completed' ||
                    order['status'] == 'canceled') ...[
                  GestureDetector(
                    onTap: () => _showDeleteDialog(order),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
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
                        'Delete',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
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
                const SizedBox(width: 2),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
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
                              image:
                                  item['image'] != null
                                      ? DecorationImage(
                                        image: NetworkImage(
                                          '$baseUrl${item['image']}',
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                      : null,
                            ),
                            child:
                                item['image'] == null
                                    ? const Center(
                                      child: Text(
                                        'No Image',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Qty ${item['quantity']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                  ),
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
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Payment Method: ${order['paymentMethod']}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    'Transaction ID: ${order['transactionId']}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
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
                              return const Text(
                                'Error loading image',
                                style: TextStyle(color: Colors.red),
                              );
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
      padding: const EdgeInsets.fromLTRB(12.0, 2.0, 12.0, 12.0),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
  child: Scaffold(
    backgroundColor: Colors.grey[100],
    body: Column(
      children: [
        Container(
          color: primaryColor, // This sets the background color for the TabBar
          child: TabBar(
            controller: _tabController,
            indicatorColor: accentColor,
            indicatorWeight: 3,
            labelColor: accentColor,
            unselectedLabelColor: Colors.white70, // Changed to white for better contrast
            labelStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
            tabs: const [
              Tab(text: 'Pending', icon: Icon(Icons.pending, size: 20)),
              Tab(text: 'Completed', icon: Icon(Icons.check_circle, size: 20)),
              Tab(text: 'Cancelled', icon: Icon(Icons.cancel, size: 20)),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                )
              : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _pendingOrders.isEmpty
                            ? Center(
                                child: Text(
                                  'No pending orders',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            : _buildOrderList(_pendingOrders),
                        _completedOrders.isEmpty
                            ? Center(
                                child: Text(
                                  'No completed orders',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            : _buildOrderList(_completedOrders),
                        _cancelledOrders.isEmpty
                            ? Center(
                                child: Text(
                                  'No cancelled orders',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            : _buildOrderList(_cancelledOrders),
                      ],
                    ),
        ),
      ],
    ),
  ),
);
  }
}

class _VerificationModalContent extends StatefulWidget {
  final Map<String, dynamic> order;
  final TextEditingController adminTransactionIdController;
  final Function(String) onVerify;

  const _VerificationModalContent({
    required this.order,
    required this.adminTransactionIdController,
    required this.onVerify,
  });

  @override
  _VerificationModalContentState createState() =>
      _VerificationModalContentState();
}

class _VerificationModalContentState extends State<_VerificationModalContent> {
  String? _transactionError;
  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

  String? _validateTransactionId(String transactionId) {
    if (transactionId.isEmpty) {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verify Order #${widget.order['_id']}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.order['recipientScreenshot'] != null) ...[
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
                  '$baseUrl${widget.order['recipientScreenshot']}',
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'Error loading image',
                      style: TextStyle(color: Colors.red),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Transaction ID: ${widget.order['transactionId']}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.adminTransactionIdController,
              decoration: InputDecoration(
                labelText: 'Enter Transaction ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            if (_transactionError != null) ...[
              const SizedBox(height: 6),
              Text(
                _transactionError!,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final adminTransactionId =
                      widget.adminTransactionIdController.text;
                  final validationError = _validateTransactionId(
                    adminTransactionId,
                  );
                  setState(() {
                    _transactionError = validationError;
                  });
                  if (validationError == null) {
                    widget.onVerify(adminTransactionId);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  'Verify',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
