// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_fonts/google_fonts.dart';
// import 'baseurl.dart';

// class AdminHomePage extends StatefulWidget {
//   const AdminHomePage({super.key});

//   @override
//   _AdminHomePageState createState() => _AdminHomePageState();
// }

// class _AdminHomePageState extends State<AdminHomePage> {
//   // final String baseUrl = 'http://localhost:3000';
//   List<Map<String, dynamic>> usersOverTime = [];
//   List<Map<String, dynamic>> sellersOverTime = [];
//   List<Map<String, dynamic>> ordersOverTime = [];
//   int totalUsers = 0;
//   int totalSellers = 0;
//   int totalOrders = 0;
//   int completedOrders = 0;
//   int pendingOrders = 0;
//   int canceledOrders = 0;
//   double totalBalance = 0.0;
//   int totalProducts = 0;
//   bool isLoading = true;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     fetchAllData();
//   }

//   Future<void> fetchAllData() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     List<String> errors = [];

//     await Future.wait([
//       fetchUsersOverTime().catchError((e) {
//         errors.add('Failed to fetch users over time: $e');
//         return;
//       }),
//       fetchSellersOverTime().catchError((e) {
//         errors.add('Failed to fetch sellers over time: $e');
//         return;
//       }),
//       fetchOrdersOverTime().catchError((e) {
//         errors.add('Failed to fetch orders over time: $e');
//         return;
//       }),
//       fetchSummaryStats().catchError((e) {
//         errors.add('Failed to fetch summary stats: $e');
//         return;
//       }),
//     ]);

//     setState(() {
//       isLoading = false;
//       if (errors.isNotEmpty) {
//         errorMessage = errors.join('\n');
//       }
//     });
//   }

//   Future<void> fetchUsersOverTime() async {
//     final response = await http.get(Uri.parse('$baseUrl/users-over-time'));
//     if (response.statusCode == 200) {
//       setState(() {
//         usersOverTime = List<Map<String, dynamic>>.from(jsonDecode(response.body));
//       });
//     } else {
//       throw Exception('Status ${response.statusCode}, Body: ${response.body}');
//     }
//   }

//   Future<void> fetchSellersOverTime() async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/admin/sellers/sellers-over-time'));
//       if (response.statusCode == 200) {
//         setState(() {
//           sellersOverTime = List<Map<String, dynamic>>.from(jsonDecode(response.body));
//         });
//       } else {
//         throw Exception('Status ${response.statusCode}, Body: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching sellers over time: $e');
//       rethrow;
//     }
//   }

//   Future<void> fetchOrdersOverTime() async {
//     final response = await http.get(Uri.parse('$baseUrl/orders-over-time'));
//     if (response.statusCode == 200) {
//       setState(() {
//         ordersOverTime = List<Map<String, dynamic>>.from(jsonDecode(response.body));
//       });
//     } else {
//       throw Exception('Status ${response.statusCode}, Body: ${response.body}');
//     }
//   }

//   Future<void> fetchSummaryStats() async {
//     // Fetch total users
//     final usersResponse = await http.get(Uri.parse('$baseUrl/total-users'));
//     if (usersResponse.statusCode == 200) {
//       setState(() {
//         totalUsers = jsonDecode(usersResponse.body)['totalUsers'] ?? 0;
//       });
//     } else {
//       throw Exception('Failed to fetch total users: Status ${usersResponse.statusCode}, Body: ${usersResponse.body}');
//     }

//     // Fetch total sellers
//     final sellersResponse = await http.get(Uri.parse('$baseUrl/admin/sellers/total-sellers'));
//     if (sellersResponse.statusCode == 200) {
//       setState(() {
//         totalSellers = jsonDecode(sellersResponse.body)['totalSellers'] ?? 0;
//       });
//     } else {
//       throw Exception('Failed to fetch total sellers: Status ${sellersResponse.statusCode}, Body: ${sellersResponse.body}');
//     }

//     // Fetch total orders
//     final ordersResponse = await http.get(Uri.parse('$baseUrl/total-orders'));
//     if (ordersResponse.statusCode == 200) {
//       setState(() {
//         totalOrders = jsonDecode(ordersResponse.body)['totalOrders'] ?? 0;
//       });
//     } else {
//       throw Exception('Failed to fetch total orders: Status ${ordersResponse.statusCode}, Body: ${ordersResponse.body}');
//     }

//     // Fetch order status breakdown
//     final statusResponse = await http.get(Uri.parse('$baseUrl/order-status-breakdown'));
//     if (statusResponse.statusCode == 200) {
//       final data = jsonDecode(statusResponse.body);
//       setState(() {
//         completedOrders = data['completed'] ?? 0;
//         pendingOrders = data['pending'] ?? 0;
//         canceledOrders = data['canceled'] ?? 0;
//       });
//     } else {
//       throw Exception('Failed to fetch order status breakdown: Status ${statusResponse.statusCode}, Body: ${statusResponse.body}');
//     }

//     // Fetch completed orders stats (number and total price)
//     final completedStatsResponse = await http.get(Uri.parse('$baseUrl/completed-orders-stats'));
//     if (completedStatsResponse.statusCode == 200) {
//       final data = jsonDecode(completedStatsResponse.body);
//       setState(() {
//         completedOrders = data['completedOrders'] ?? 0;
//         totalBalance = (data['totalPrice'] ?? 0).toDouble();
//       });
//     } else {
//       throw Exception('Failed to fetch completed orders stats: Status ${completedStatsResponse.statusCode}, Body: ${completedStatsResponse.body}');
//     }

//     // Fetch total products
//     final productsResponse = await http.get(Uri.parse('$baseUrl/products/total-products')); // Updated URL
//     if (productsResponse.statusCode == 200) {
//       setState(() {
//         totalProducts = jsonDecode(productsResponse.body)['totalProducts'] ?? 0;
//       });
//     } else {
//       throw Exception('Failed to fetch total products: Status ${productsResponse.statusCode}, Body: ${productsResponse.body}');
//     }
//   }

//   List<FlSpot> getSpots(List<Map<String, dynamic>> data, String key) {
//     return data.asMap().entries.map((entry) {
//       int index = entry.key;
//       double value = (entry.value[key] ?? 0).toDouble();
//       return FlSpot(index.toDouble(), value);
//     }).toList();
//   }

//   double getMaxY(List<Map<String, dynamic>> data, String key) {
//     if (data.isEmpty) return 10;
//     return data.map((item) => (item[key] ?? 0).toDouble()).reduce((a, b) => a > b ? a : b) * 1.2;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Title
//           Text(
//             'EthioMarket Dashboard',
//             style: GoogleFonts.poppins(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFFAB47BC),
//             ),
//           ),
//           const SizedBox(height: 20),

//           if (isLoading)
//             const Center(child: CircularProgressIndicator())
//           else ...[
//             if (errorMessage != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 20),
//                 child: Column(
//                   children: [
//                     Text(
//                       errorMessage!,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: fetchAllData,
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               ),

//             // EthioMarket Users Line Graph
//             if (usersOverTime.isNotEmpty)
//               _buildChartCard(
//                 title: 'EthioMarket Users',
//                 child: SizedBox(
//                   height: 250,
//                   child: LineChart(
//                     LineChartData(
//                       gridData: FlGridData(
//                         show: true,
//                         drawVerticalLine: false,
//                         horizontalInterval: getMaxY(usersOverTime, 'count') / 5,
//                         getDrawingHorizontalLine: (value) => const FlLine(
//                           color: Colors.grey,
//                           strokeWidth: 0.5,
//                           dashArray: [5, 5],
//                         ),
//                       ),
//                       titlesData: FlTitlesData(
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 40,
//                             getTitlesWidget: (value, meta) {
//                               if (value.toInt() >= 0 && value.toInt() < usersOverTime.length) {
//                                 return Padding(
//                                   padding: const EdgeInsets.only(top: 8.0),
//                                   child: Text(
//                                     usersOverTime[value.toInt()]['date'],
//                                     style: GoogleFonts.poppins(fontSize: 12),
//                                   ),
//                                 );
//                               }
//                               return const Text('');
//                             },
//                           ),
//                         ),
//                         leftTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 40,
//                             getTitlesWidget: (value, meta) => Text(
//                               value.toInt().toString(),
//                               style: GoogleFonts.poppins(fontSize: 12),
//                             ),
//                           ),
//                         ),
//                         topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                         rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                       ),
//                       borderData: FlBorderData(show: false),
//                       minX: 0,
//                       maxX: usersOverTime.isEmpty ? 1 : (usersOverTime.length - 1).toDouble(),
//                       minY: 0,
//                       maxY: getMaxY(usersOverTime, 'count'),
//                       lineBarsData: [
//                         LineChartBarData(
//                           spots: getSpots(usersOverTime, 'count'),
//                           isCurved: true,
//                           color: const Color(0xFF8A4B3A),
//                           dotData: FlDotData(
//                             getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
//                               radius: 4,
//                               color: const Color(0xFF8A4B3A),
//                               strokeWidth: 0,
//                             ),
//                           ),
//                           belowBarData: BarAreaData(
//                             show: true,
//                             color: const Color(0xFF8A4B3A).withOpacity(0.2),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 20),

//             // EthioMarket Sellers Line Graph
//             if (sellersOverTime.isNotEmpty)
//               _buildChartCard(
//                 title: 'EthioMarket Sellers',
//                 child: SizedBox(
//                   height: 250,
//                   child: LineChart(
//                     LineChartData(
//                       gridData: FlGridData(
//                         show: true,
//                         drawVerticalLine: false,
//                         horizontalInterval: getMaxY(sellersOverTime, 'count') / 5,
//                         getDrawingHorizontalLine: (value) => const FlLine(
//                           color: Colors.grey,
//                           strokeWidth: 0.5,
//                           dashArray: [5, 5],
//                         ),
//                       ),
//                       titlesData: FlTitlesData(
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 40,
//                             getTitlesWidget: (value, meta) {
//                               if (value.toInt() >= 0 && value.toInt() < sellersOverTime.length) {
//                                 return Padding(
//                                   padding: const EdgeInsets.only(top: 8.0),
//                                   child: Text(
//                                     sellersOverTime[value.toInt()]['date'],
//                                     style: GoogleFonts.poppins(fontSize: 12),
//                                   ),
//                                 );
//                               }
//                               return const Text('');
//                             },
//                           ),
//                         ),
//                         leftTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 40,
//                             getTitlesWidget: (value, meta) => Text(
//                               value.toInt().toString(),
//                               style: GoogleFonts.poppins(fontSize: 12),
//                             ),
//                           ),
//                         ),
//                         topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                         rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                       ),
//                       borderData: FlBorderData(show: false),
//                       minX: 0,
//                       maxX: sellersOverTime.isEmpty ? 1 : (sellersOverTime.length - 1).toDouble(),
//                       minY: 0,
//                       maxY: getMaxY(sellersOverTime, 'count'),
//                       lineBarsData: [
//                         LineChartBarData(
//                           spots: getSpots(sellersOverTime, 'count'),
//                           isCurved: true,
//                           color: const Color(0xFF4B8A3A),
//                           dotData: FlDotData(
//                             getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
//                               radius: 4,
//                               color: const Color(0xFF4B8A3A),
//                               strokeWidth: 0,
//                             ),
//                           ),
//                           belowBarData: BarAreaData(
//                             show: true,
//                             color: const Color(0xFF4B8A3A).withOpacity(0.2),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 20),

//             // Orders and Price Bar Chart
//             if (ordersOverTime.isNotEmpty)
//               _buildChartCard(
//                 title: 'Orders and Total Price',
//                 child: SizedBox(
//                   height: 300,
//                   child: BarChart(
//                     BarChartData(
//                       gridData: FlGridData(
//                         show: true,
//                         drawVerticalLine: false,
//                         horizontalInterval: getMaxY(ordersOverTime, 'totalPrice') / 5,
//                         getDrawingHorizontalLine: (value) => const FlLine(
//                           color: Colors.grey,
//                           strokeWidth: 0.5,
//                           dashArray: [5, 5],
//                         ),
//                       ),
//                       titlesData: FlTitlesData(
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 40,
//                             getTitlesWidget: (value, meta) {
//                               if (value.toInt() >= 0 && value.toInt() < ordersOverTime.length) {
//                                 return Padding(
//                                   padding: const EdgeInsets.only(top: 8.0),
//                                   child: Text(
//                                     ordersOverTime[value.toInt()]['date'],
//                                     style: GoogleFonts.poppins(fontSize: 12),
//                                   ),
//                                 );
//                               }
//                               return const Text('');
//                             },
//                           ),
//                         ),
//                         leftTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 50,
//                             getTitlesWidget: (value, meta) => Text(
//                               value.toInt().toString(),
//                               style: GoogleFonts.poppins(fontSize: 12),
//                             ),
//                           ),
//                         ),
//                         rightTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 50,
//                             getTitlesWidget: (value, meta) => Text(
//                               value.toInt().toString(),
//                               style: GoogleFonts.poppins(fontSize: 12),
//                             ),
//                           ),
//                         ),
//                         topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                       ),
//                       borderData: FlBorderData(show: false),
//                       minY: 0,
//                       maxY: getMaxY(ordersOverTime, 'totalPrice'),
//                       barGroups: ordersOverTime.asMap().entries.map((entry) {
//                         int index = entry.key;
//                         Map<String, dynamic> data = entry.value;
//                         return BarChartGroupData(
//                           x: index,
//                           barRods: [
//                             BarChartRodData(
//                               toY: (data['totalPrice'] ?? 0).toDouble(),
//                               color: const Color(0xFF3A4B8A),
//                               width: 20,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ],
//                           showingTooltipIndicators: [0],
//                         );
//                       }).toList(),
//                       barTouchData: BarTouchData(
//                         touchTooltipData: BarTouchTooltipData(
//                           getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                             return BarTooltipItem(
//                               'Total Price: ${rod.toY.toStringAsFixed(2)} ETB\nOrders: ${ordersOverTime[groupIndex]['count']}',
//                               GoogleFonts.poppins(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 20),

//             // Summary Statistics
//             if (totalUsers > 0 || totalSellers > 0 || totalOrders > 0 || totalProducts > 0)
//               _buildSummaryCard(
//                 title: 'Summary Statistics',
//                 children: [
//                   if (totalUsers > 0) _buildSummaryItem('Total Users', totalUsers.toString()),
//                   if (totalSellers > 0) _buildSummaryItem('Total Sellers', totalSellers.toString()),
//                   if (totalOrders > 0) _buildSummaryItem('Total Orders', totalOrders.toString()),
//                   if (completedOrders > 0) _buildSummaryItem('Completed Orders', completedOrders.toString()),
//                   if (pendingOrders > 0) _buildSummaryItem('Pending Orders', pendingOrders.toString()),
//                   if (canceledOrders > 0) _buildSummaryItem('Canceled Orders', canceledOrders.toString()),
//                   if (totalBalance > 0) _buildSummaryItem('Total Balance', '${totalBalance.toStringAsFixed(2)} ETB'),
//                   if (totalProducts > 0) _buildSummaryItem('Total Products', totalProducts.toString()),
//                 ],
//               ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildChartCard({required String title, required Widget child}) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFFAB47BC),
//               ),
//             ),
//             const SizedBox(height: 10),
//             child,
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryCard({required String title, required List<Widget> children}) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFFAB47BC),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Wrap(
//               spacing: 16,
//               runSpacing: 16,
//               children: children,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryItem(String label, String value) {
//     return Container(
//       width: 150,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// version ui  
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_fonts/google_fonts.dart';
// import 'baseurl.dart';

// class AdminHomePage extends StatefulWidget {
//   const AdminHomePage({super.key});

//   // Define colors locally
//   static const Color primaryColor = Color(0xFFAB47BC); // Matches existing title color
//   static const Color accentColor = Color(0xFFFFD700); // Gold for contrast

//   @override
//   _AdminHomePageState createState() => _AdminHomePageState();
// }

// class _AdminHomePageState extends State<AdminHomePage> {
//   // final String baseUrl = 'http://localhost:3000';
//   List<Map<String, dynamic>> usersOverTime = [];
//   List<Map<String, dynamic>> sellersOverTime = [];
//   List<Map<String, dynamic>> ordersOverTime = [];
//   int totalUsers = 0;
//   int totalSellers = 0;
//   int totalOrders = 0;
//   int completedOrders = 0;
//   int pendingOrders = 0;
//   int canceledOrders = 0;
//   double totalBalance = 0.0;
//   int totalProducts = 0;
//   bool isLoading = true;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     fetchAllData();
//   }

//   Future<void> fetchAllData() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     List<String> errors = [];

//     await Future.wait([
//       fetchUsersOverTime().catchError((e) {
//         errors.add('Failed to fetch users over time: $e');
//         return;
//       }),
//       fetchSellersOverTime().catchError((e) {
//         errors.add('Failed to fetch sellers over time: $e');
//         return;
//       }),
//       fetchOrdersOverTime().catchError((e) {
//         errors.add('Failed to fetch orders over time: $e');
//         return;
//       }),
//       fetchSummaryStats().catchError((e) {
//         errors.add('Failed to fetch summary stats: $e');
//         return;
//       }),
//     ]);

//     setState(() {
//       isLoading = false;
//       if (errors.isNotEmpty) {
//         errorMessage = errors.join('\n');
//       }
//     });
//   }

//   Future<void> fetchUsersOverTime() async {
//     final response = await http.get(Uri.parse('$baseUrl/users-over-time'));
//     if (response.statusCode == 200) {
//       setState(() {
//         usersOverTime = List<Map<String, dynamic>>.from(jsonDecode(response.body));
//       });
//     } else {
//       throw Exception('Status ${response.statusCode}, Body: ${response.body}');
//     }
//   }

//   Future<void> fetchSellersOverTime() async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/admin/sellers/sellers-over-time'));
//       if (response.statusCode == 200) {
//         setState(() {
//           sellersOverTime = List<Map<String, dynamic>>.from(jsonDecode(response.body));
//         });
//       } else {
//         throw Exception('Status ${response.statusCode}, Body: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching sellers over time: $e');
//       rethrow;
//     }
//   }

//   Future<void> fetchOrdersOverTime() async {
//     final response = await http.get(Uri.parse('$baseUrl/orders-over-time'));
//     if (response.statusCode == 200) {
//       setState(() {
//         ordersOverTime = List<Map<String, dynamic>>.from(jsonDecode(response.body));
//       });
//     } else {
//       throw Exception('Status ${response.statusCode}, Body: ${response.body}');
//     }
//   }

//   Future<void> fetchSummaryStats() async {
//     // Fetch total users
//     final usersResponse = await http.get(Uri.parse('$baseUrl/total-users'));
//     if (usersResponse.statusCode == 200) {
//       setState(() {
//         totalUsers = jsonDecode(usersResponse.body)['totalUsers'] ?? 0;
//       });
//     } else {
//       throw Exception('Failed to fetch total users: Status ${usersResponse.statusCode}, Body: ${usersResponse.body}');
//     }

//     // Fetch total sellers
//     final sellersResponse = await http.get(Uri.parse('$baseUrl/admin/sellers/total-sellers'));
//     if (sellersResponse.statusCode == 200) {
//       setState(() {
//         totalSellers = jsonDecode(sellersResponse.body)['totalSellers'] ?? 0;
//       });
//     } else {
//       throw Exception('Failed to fetch total sellers: Status ${sellersResponse.statusCode}, Body: ${sellersResponse.body}');
//     }

//     // Fetch total orders
//     final ordersResponse = await http.get(Uri.parse('$baseUrl/total-orders'));
//     if (ordersResponse.statusCode == 200) {
//       setState(() {
//         totalOrders = jsonDecode(ordersResponse.body)['totalOrders'] ?? 0;
//       });
//     } else {
//       throw Exception('Failed to fetch total orders: Status ${ordersResponse.statusCode}, Body: ${ordersResponse.body}');
//     }

//     // Fetch order status breakdown
//     final statusResponse = await http.get(Uri.parse('$baseUrl/order-status-breakdown'));
//     if (statusResponse.statusCode == 200) {
//       final data = jsonDecode(statusResponse.body);
//       setState(() {
//         completedOrders = data['completed'] ?? 0;
//         pendingOrders = data['pending'] ?? 0;
//         canceledOrders = data['canceled'] ?? 0;
//       });
//     } else {
//       throw Exception('Failed to fetch order status breakdown: Status ${statusResponse.statusCode}, Body: ${statusResponse.body}');
//     }

//     // Fetch completed orders stats (number and total price)
//     final completedStatsResponse = await http.get(Uri.parse('$baseUrl/completed-orders-stats'));
//     if (completedStatsResponse.statusCode == 200) {
//       final data = jsonDecode(completedStatsResponse.body);
//       setState(() {
//         completedOrders = data['completedOrders'] ?? 0;
//         totalBalance = (data['totalPrice'] ?? 0).toDouble();
//       });
//     } else {
//       throw Exception('Failed to fetch completed orders stats: Status ${completedStatsResponse.statusCode}, Body: ${completedStatsResponse.body}');
//     }

//     // Fetch total products
//     final productsResponse = await http.get(Uri.parse('$baseUrl/products/total-products')); // Updated URL
//     if (productsResponse.statusCode == 200) {
//       setState(() {
//         totalProducts = jsonDecode(productsResponse.body)['totalProducts'] ?? 0;
//       });
//     } else {
//       throw Exception('Failed to fetch total products: Status ${productsResponse.statusCode}, Body: ${productsResponse.body}');
//     }
//   }

//   List<FlSpot> getSpots(List<Map<String, dynamic>> data, String key) {
//     return data.asMap().entries.map((entry) {
//       int index = entry.key;
//       double value = (entry.value[key] ?? 0).toDouble();
//       return FlSpot(index.toDouble(), value);
//     }).toList();
//   }

//   List<FlSpot> getCumulativeSpots(List<Map<String, dynamic>> data, String key) {
//     double cumulative = 0;
//     return data.asMap().entries.map((entry) {
//       int index = entry.key;
//       double value = (entry.value[key] ?? 0).toDouble();
//       cumulative += value;
//       return FlSpot(index.toDouble(), cumulative);
//     }).toList();
//   }

//   double getMaxY(List<Map<String, dynamic>> data, String key) {
//     if (data.isEmpty) return 10;
//     return data.map((item) => (item[key] ?? 0).toDouble()).reduce((a, b) => a > b ? a : b) * 1.2;
//   }

//   double getMaxYCumulative(List<Map<String, dynamic>> data, String key) {
//     if (data.isEmpty) return 10;
//     double cumulative = 0;
//     for (var item in data) {
//       cumulative += (item[key] ?? 0).toDouble();
//     }
//     return cumulative * 1.2;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Title
//           Text(
//             'EthioMarket Dashboard',
//             style: GoogleFonts.poppins(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: AdminHomePage.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 20),

//           if (isLoading)
//             Center(child: CircularProgressIndicator(color: AdminHomePage.primaryColor))
//           else ...[
//             if (errorMessage != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 20),
//                 child: Column(
//                   children: [
//                     Text(
//                       errorMessage!,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: fetchAllData,
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               ),

//             // EthioMarket Users Line Graph
//             if (usersOverTime.isNotEmpty)
//               _buildChartCard(
//                 title: 'EthioMarket Users',
//                 child: SizedBox(
//                   height: 280,
//                   child: LineChart(
//                     LineChartData(
//                       gridData: FlGridData(
//                         show: true,
//                         drawVerticalLine: true,
//                         horizontalInterval: getMaxY(usersOverTime, 'count') / 5,
//                         verticalInterval: 1,
//                         getDrawingHorizontalLine: (value) => FlLine(
//                           color: Colors.grey[300]!,
//                           strokeWidth: 1,
//                           dashArray: value.toInt() % 2 == 0 ? null : [5, 5],
//                         ),
//                         getDrawingVerticalLine: (value) => FlLine(
//                           color: Colors.grey[300]!,
//                           strokeWidth: 1,
//                           dashArray: [5, 5],
//                         ),
//                       ),
//                       titlesData: FlTitlesData(
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 40,
//                             getTitlesWidget: (value, meta) {
//                               if (value.toInt() >= 0 && value.toInt() < usersOverTime.length) {
//                                 return Padding(
//                                   padding: const EdgeInsets.only(top: 8.0),
//                                   child: Text(
//                                     usersOverTime[value.toInt()]['date'],
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 12,
//                                       color: AdminHomePage.primaryColor,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 );
//                               }
//                               return const Text('');
//                             },
//                           ),
//                         ),
//                         leftTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 40,
//                             getTitlesWidget: (value, meta) => Text(
//                               value.toInt().toString(),
//                               style: GoogleFonts.poppins(
//                                 fontSize: 12,
//                                 color: AdminHomePage.primaryColor,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                         topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                         rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                       ),
//                       borderData: FlBorderData(show: false),
//                       minX: 0,
//                       maxX: usersOverTime.isEmpty ? 1 : (usersOverTime.length - 1).toDouble(),
//                       minY: 0,
//                       maxY: getMaxY(usersOverTime, 'count'),
//                       lineBarsData: [
//                         LineChartBarData(
//                           spots: getSpots(usersOverTime, 'count'),
//                           isCurved: true,
//                           gradient: LinearGradient(
//                             colors: [
//                               AdminHomePage.primaryColor,
//                               AdminHomePage.primaryColor.withOpacity(0.7),
//                             ],
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                           ),
//                           barWidth: 4,
//                           shadow: const Shadow(
//                             color: Colors.black26,
//                             blurRadius: 8,
//                             offset: Offset(0, 4),
//                           ),
//                           dotData: FlDotData(
//                             getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
//                               radius: 6,
//                               color: AdminHomePage.accentColor,
//                               strokeWidth: 2,
//                               strokeColor: AdminHomePage.primaryColor,
//                             ),
//                           ),
//                           belowBarData: BarAreaData(
//                             show: true,
//                             gradient: LinearGradient(
//                               colors: [
//                                 AdminHomePage.primaryColor.withOpacity(0.3),
//                                 AdminHomePage.primaryColor.withOpacity(0.1),
//                               ],
//                               begin: Alignment.topCenter,
//                               end: Alignment.bottomCenter,
//                             ),
//                           ),
//                         ),
//                       ],
//                       lineTouchData: LineTouchData(
//                         touchTooltipData: LineTouchTooltipData(
//                           getTooltipColor: (_) => AdminHomePage.primaryColor.withOpacity(0.9),
//                           getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
//                             return LineTooltipItem(
//                               'Users: ${spot.y.toInt()}\nDate: ${usersOverTime[spot.x.toInt()]['date']}',
//                               GoogleFonts.poppins(
//                                 color: AdminHomePage.accentColor,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 20),

//             // EthioMarket Sellers Line Graph
//             if (sellersOverTime.isNotEmpty)
//               _buildChartCard(
//                 title: 'EthioMarket Sellers',
//                 child: SizedBox(
//                   height: 280,
//                   child: LineChart(
//                     LineChartData(
//                       gridData: FlGridData(
//                         show: true,
//                         drawVerticalLine: true,
//                         horizontalInterval: getMaxYCumulative(sellersOverTime, 'count') / 5,
//                         verticalInterval: 1,
//                         getDrawingHorizontalLine: (value) {
//                           // Draw a highlighted line at max count
//                           if ((value - getMaxY(sellersOverTime, 'count')).abs() < 0.1) {
//                             return FlLine(
//                               color: AdminHomePage.accentColor.withOpacity(0.3),
//                               strokeWidth: 2,
//                             );
//                           }
//                           return FlLine(
//                             color: Colors.grey[300]!,
//                             strokeWidth: 1,
//                             dashArray: value.toInt() % 2 == 0 ? null : [5, 5],
//                           );
//                         },
//                         getDrawingVerticalLine: (value) => FlLine(
//                           color: Colors.grey[300]!,
//                           strokeWidth: 1,
//                           dashArray: [5, 5],
//                         ),
//                       ),
//                       titlesData: FlTitlesData(
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 40,
//                             getTitlesWidget: (value, meta) {
//                               if (value.toInt() >= 0 && value.toInt() < sellersOverTime.length) {
//                                 return Padding(
//                                   padding: const EdgeInsets.only(top: 8.0),
//                                   child: Text(
//                                     sellersOverTime[value.toInt()]['date'],
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 12,
//                                       color: AdminHomePage.primaryColor,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 );
//                               }
//                               return const Text('');
//                             },
//                           ),
//                         ),
//                         leftTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 40,
//                             getTitlesWidget: (value, meta) => Text(
//                               value.toInt().toString(),
//                               style: GoogleFonts.poppins(
//                                 fontSize: 12,
//                                 color: AdminHomePage.primaryColor,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                         rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                         topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                       ),
//                       borderData: FlBorderData(show: false),
//                       minX: 0,
//                       maxX: sellersOverTime.isEmpty ? 1 : (sellersOverTime.length - 1).toDouble(),
//                       minY: 0,
//                       maxY: getMaxYCumulative(sellersOverTime, 'count'),
//                       lineBarsData: [
//                         LineChartBarData(
//                           spots: getSpots(sellersOverTime, 'count'),
//                           isCurved: true,
//                           gradient: LinearGradient(
//                             colors: [
//                               AdminHomePage.primaryColor,
//                               AdminHomePage.primaryColor.withOpacity(0.7),
//                             ],
//                           ),
//                           barWidth: 4,
//                           dotData: FlDotData(
//                             getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
//                               radius: 6,
//                               color: AdminHomePage.accentColor,
//                               strokeWidth: 2,
//                               strokeColor: AdminHomePage.primaryColor,
//                             ),
//                           ),
//                           belowBarData: BarAreaData(
//                             show: true,
//                             gradient: LinearGradient(
//                               colors: [
//                                 AdminHomePage.primaryColor.withOpacity(0.3),
//                                 AdminHomePage.primaryColor.withOpacity(0.1),
//                               ],
//                             ),
//                           ),
//                         ),
//                         LineChartBarData(
//                           spots: getCumulativeSpots(sellersOverTime, 'count'),
//                           isCurved: true,
//                           gradient: LinearGradient(
//                             colors: [
//                               AdminHomePage.accentColor,
//                               AdminHomePage.accentColor.withOpacity(0.7),
//                             ],
//                           ),
//                           barWidth: 3,
//                           dotData: FlDotData(
//                             getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
//                               radius: 5,
//                               color: AdminHomePage.primaryColor,
//                               strokeWidth: 1,
//                               strokeColor: AdminHomePage.accentColor,
//                             ),
//                           ),
//                           belowBarData: BarAreaData(show: false),
//                         ),
//                       ],
//                       lineTouchData: LineTouchData(
//                         touchTooltipData: LineTouchTooltipData(
//                           getTooltipColor: (_) => AdminHomePage.primaryColor.withOpacity(0.9),
//                           getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
//                             final index = spot.x.toInt();
//                             final data = sellersOverTime[index];
//                             return LineTooltipItem(
//                               'Sellers: ${data['count']}\nCumulative: ${getCumulativeSpots(sellersOverTime, 'count')[index].y.toInt()}\nDate: ${data['date']}',
//                               GoogleFonts.poppins(
//                                 color: AdminHomePage.accentColor,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 legend: [
//                   LegendItem(color: AdminHomePage.primaryColor, label: 'Sellers'),
//                   LegendItem(color: AdminHomePage.accentColor, label: 'Cumulative Sellers'),
//                 ],
//               ),
//             const SizedBox(height: 20),

//             // Orders and Price Bar Chart
//             if (ordersOverTime.isNotEmpty)
//               _buildChartCard(
//                 title: 'Orders and Total Price',
//                 child: SizedBox(
//                   height: 300,
//                   child: BarChart(
//                     BarChartData(
//                       gridData: FlGridData(
//                         show: true,
//                         drawVerticalLine: true,
//                         horizontalInterval: getMaxY(ordersOverTime, 'totalPrice') / 5,
//                         verticalInterval: 1,
//                         getDrawingHorizontalLine: (value) => FlLine(
//                           color: Colors.grey[300]!,
//                           strokeWidth: 1,
//                           dashArray: value.toInt() % 2 == 0 ? null : [5, 5],
//                         ),
//                         getDrawingVerticalLine: (value) => FlLine(
//                           color: Colors.grey[300]!,
//                           strokeWidth: 1,
//                           dashArray: [5, 5],
//                         ),
//                       ),
//                       titlesData: FlTitlesData(
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 40,
//                             getTitlesWidget: (value, meta) {
//                               if (value.toInt() >= 0 && value.toInt() < ordersOverTime.length) {
//                                 return Padding(
//                                   padding: const EdgeInsets.only(top: 8.0),
//                                   child: Text(
//                                     ordersOverTime[value.toInt()]['date'],
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 12,
//                                       color: AdminHomePage.primaryColor,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 );
//                               }
//                               return const Text('');
//                             },
//                           ),
//                         ),
//                         leftTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 50,
//                             getTitlesWidget: (value, meta) => Text(
//                               value.toInt().toString(),
//                               style: GoogleFonts.poppins(
//                                 fontSize: 12,
//                                 color: AdminHomePage.primaryColor,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                         rightTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 50,
//                             getTitlesWidget: (value, meta) => Text(
//                               value.toInt().toString(),
//                               style: GoogleFonts.poppins(
//                                 fontSize: 12,
//                                 color: AdminHomePage.primaryColor,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                         topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                       ),
//                       borderData: FlBorderData(show: false),
//                       minY: 0,
//                       maxY: getMaxY(ordersOverTime, 'totalPrice'),
//                       barGroups: ordersOverTime.asMap().entries.map((entry) {
//                         int index = entry.key;
//                         Map<String, dynamic> data = entry.value;
//                         return BarChartGroupData(
//                           x: index,
//                           barRods: [
//                             BarChartRodData(
//                               toY: (data['totalPrice'] ?? 0).toDouble(),
//                               gradient: LinearGradient(
//                                 colors: [
//                                   AdminHomePage.primaryColor,
//                                   AdminHomePage.accentColor.withOpacity(0.7),
//                                 ],
//                                 begin: Alignment.bottomCenter,
//                                 end: Alignment.topCenter,
//                               ),
//                               width: 12,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             BarChartRodData(
//                               toY: (data['count'] ?? 0).toDouble(),
//                               gradient: LinearGradient(
//                                 colors: [
//                                   AdminHomePage.accentColor,
//                                   AdminHomePage.primaryColor.withOpacity(0.7),
//                                 ],
//                                 begin: Alignment.bottomCenter,
//                                 end: Alignment.topCenter,
//                               ),
//                               width: 12,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ],
//                           showingTooltipIndicators: [0, 1],
//                         );
//                       }).toList(),
//                       barTouchData: BarTouchData(
//                         touchTooltipData: BarTouchTooltipData(
//                           getTooltipColor: (_) => AdminHomePage.primaryColor.withOpacity(0.9),
//                           getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                             final data = ordersOverTime[groupIndex];
//                             return BarTooltipItem(
//                               rodIndex == 0
//                                   ? 'Total Price: ${rod.toY.toStringAsFixed(2)} ETB'
//                                   : 'Orders: ${rod.toY.toInt()}\nDate: ${data['date']}',
//                               GoogleFonts.poppins(
//                                 color: AdminHomePage.accentColor,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 legend: [
//                   LegendItem(color: AdminHomePage.primaryColor, label: 'Total Price'),
//                   LegendItem(color: AdminHomePage.accentColor, label: 'Order Count'),
//                 ],
//               ),
//             const SizedBox(height: 20),

//             // Summary Statistics
//             if (totalUsers > 0 || totalSellers > 0 || totalOrders > 0 || totalProducts > 0)
//               _buildSummaryCard(
//                 title: 'Summary Statistics',
//                 children: [
//                   if (totalUsers > 0) _buildSummaryItem('Total Users', totalUsers.toString()),
//                   if (totalSellers > 0) _buildSummaryItem('Total Sellers', totalSellers.toString()),
//                   if (totalOrders > 0) _buildSummaryItem('Total Orders', totalOrders.toString()),
//                   if (completedOrders > 0) _buildSummaryItem('Completed Orders', completedOrders.toString()),
//                   if (pendingOrders > 0) _buildSummaryItem('Pending Orders', pendingOrders.toString()),
//                   if (canceledOrders > 0) _buildSummaryItem('Canceled Orders', canceledOrders.toString()),
//                   if (totalBalance > 0) _buildSummaryItem('Total Balance', '${totalBalance.toStringAsFixed(2)} ETB'),
//                   if (totalProducts > 0) _buildSummaryItem('Total Products', totalProducts.toString()),
//                 ],
//               ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildChartCard({required String title, required Widget child, List<LegendItem>? legend}) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey[200]!, width: 1),
//       ),
//       shadowColor: AdminHomePage.primaryColor.withOpacity(0.2),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: AdminHomePage.primaryColor,
//               ),
//             ),
//             const SizedBox(height: 10),
//             child,
//             if (legend != null && legend.isNotEmpty) ...[
//               const SizedBox(height: 10),
//               Wrap(
//                 spacing: 16,
//                 children: legend.map((item) => Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 12,
//                       height: 12,
//                       decoration: BoxDecoration(
//                         color: item.color,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       item.label,
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         color: AdminHomePage.primaryColor,
//                       ),
//                     ),
//                   ],
//                 )).toList(),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryCard({required String title, required List<Widget> children}) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFFAB47BC),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Wrap(
//               spacing: 16,
//               runSpacing: 16,
//               children: children,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryItem(String label, String value) {
//     return Container(
//       width: 150,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class LegendItem {
//   final Color color;
//   final String label;

//   LegendItem({required this.color, required this.label});
// }

// version ui


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'baseurl.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  // Define colors locally
  static const Color primaryColor = Color.fromARGB(255, 62, 62, 147);
  static const Color accentColor = Color(0xFFFFD700); // Gold for contrast

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
          // Title
          // Text(
          //   'EthioMarket Dashboard',
          //   style: GoogleFonts.poppins(
          //     fontSize: 28,
          //     fontWeight: FontWeight.bold,
          //     color: AdminHomePage.primaryColor,
          //   ),
          // ),
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
                    fontSize: 12, // Slightly smaller font size
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16, // Slightly smaller font size
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