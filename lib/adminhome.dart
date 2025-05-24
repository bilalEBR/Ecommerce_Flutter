
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'baseurl.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});


  static const Color primaryColor = Color.fromARGB(255, 62, 62, 147);
  static const Color accentColor = Color(0xFFFFD700); 

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int totalUsers = 0;
  int totalSellers = 0;
  int totalOrders = 0;
  int completedOrders = 0;
  int pendingOrders = 0;
  int canceledOrders = 0;
  double totalBalance = 0.0;
  int totalProducts = 0;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSummaryStats();
  }

  Future<void> fetchSummaryStats() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    List<String> errors = [];

    try {
      // Fetch total users
      final usersResponse = await http.get(Uri.parse('$baseUrl/total-users'));
      if (usersResponse.statusCode == 200) {
        setState(() {
          totalUsers = jsonDecode(usersResponse.body)['totalUsers'] ?? 0;
        });
      } else {
        errors.add('Failed to fetch total users: Status ${usersResponse.statusCode}, Body: ${usersResponse.body}');
      }

      // Fetch total sellers
      final sellersResponse = await http.get(Uri.parse('$baseUrl/admin/sellers/total-sellers'));
      if (sellersResponse.statusCode == 200) {
        setState(() {
          totalSellers = jsonDecode(sellersResponse.body)['totalSellers'] ?? 0;
        });
      } else {
        errors.add('Failed to fetch total sellers: Status ${sellersResponse.statusCode}, Body: ${sellersResponse.body}');
      }

      // Fetch total orders
      final ordersResponse = await http.get(Uri.parse('$baseUrl/total-orders'));
      if (ordersResponse.statusCode == 200) {
        setState(() {
          totalOrders = jsonDecode(ordersResponse.body)['totalOrders'] ?? 0;
        });
      } else {
        errors.add('Failed to fetch total orders: Status ${ordersResponse.statusCode}, Body: ${ordersResponse.body}');
      }

      // Fetch order status breakdown
      final statusResponse = await http.get(Uri.parse('$baseUrl/order-status-breakdown'));
      if (statusResponse.statusCode == 200) {
        final data = jsonDecode(statusResponse.body);
        setState(() {
          completedOrders = data['completed'] ?? 0;
          pendingOrders = data['pending'] ?? 0;
          canceledOrders = data['canceled'] ?? 0;
        });
      } else {
        errors.add('Failed to fetch order status breakdown: Status ${statusResponse.statusCode}, Body: ${statusResponse.body}');
      }

      // Fetch completed orders stats (number and total price)
      final completedStatsResponse = await http.get(Uri.parse('$baseUrl/completed-orders-stats'));
      if (completedStatsResponse.statusCode == 200) {
        final data = jsonDecode(completedStatsResponse.body);
        setState(() {
          completedOrders = data['completedOrders'] ?? 0;
          totalBalance = (data['totalPrice'] ?? 0).toDouble();
        });
      } else {
        errors.add('Failed to fetch completed orders stats: Status ${completedStatsResponse.statusCode}, Body: ${completedStatsResponse.body}');
      }

      // Fetch total products
      final productsResponse = await http.get(Uri.parse('$baseUrl/products/total-products'));
      if (productsResponse.statusCode == 200) {
        setState(() {
          totalProducts = jsonDecode(productsResponse.body)['totalProducts'] ?? 0;
        });
      } else {
        errors.add('Failed to fetch total products: Status ${productsResponse.statusCode}, Body: ${productsResponse.body}');
      }
    } catch (e) {
      errors.add('Error fetching data: $e');
    }

    setState(() {
      isLoading = false;
      if (errors.isNotEmpty) {
        errorMessage = errors.join('\n');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          const SizedBox(height: 20),

          if (isLoading)
            Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AdminHomePage.primaryColor)))
          else ...[
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Text(
                      errorMessage!,
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: fetchSummaryStats,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminHomePage.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          shadowColor: Colors.grey.withOpacity(0.5),
                        ),
                        child: Text(
                          'Retry',
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

            // Summary Statistics
            if (totalUsers > 0 || totalSellers > 0 || totalOrders > 0 || totalProducts > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary Statistics',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AdminHomePage.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.8, // Increased to provide more vertical space
                    children: [
                      if (totalUsers > 0) _buildSummaryCard('Total Users', totalUsers.toString(), Icons.person),
                      if (totalSellers > 0) _buildSummaryCard('Total Sellers', totalSellers.toString(), Icons.store),
                      if (totalOrders > 0) _buildSummaryCard('Total Orders', totalOrders.toString(), Icons.shopping_cart),
                      if (completedOrders > 0) _buildSummaryCard('Completed Orders', completedOrders.toString(), Icons.check_circle),
                      if (pendingOrders > 0) _buildSummaryCard('Pending Orders', pendingOrders.toString(), Icons.pending),
                      if (canceledOrders > 0) _buildSummaryCard('Canceled Orders', canceledOrders.toString(), Icons.cancel),
                      if (totalBalance > 0) _buildSummaryCard('Total Balance', '${totalBalance.toStringAsFixed(2)} ETB', Icons.account_balance),
                      if (totalProducts > 0) _buildSummaryCard('Total Products', totalProducts.toString(), Icons.inventory),
                    ],
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon) {
    return Container(
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
      padding: const EdgeInsets.all(12.0), // Reduced padding slightly
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AdminHomePage.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AdminHomePage.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12, 
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: AdminHomePage.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}