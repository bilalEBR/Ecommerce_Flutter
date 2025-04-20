// // clientcart.dart
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'client-state.dart';

// class ClientCartPage extends StatelessWidget {
//   const ClientCartPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final clientState = Provider.of<ClientState>(context);

//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               'Cart',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           clientState.cartProducts.isEmpty
//               ? const Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Center(child: Text('No products in cart yet')),
//                 )
//               : GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 16.0,
//                     mainAxisSpacing: 16.0,
//                     childAspectRatio: 0.7,
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                   itemCount: clientState.cartProducts.length,
//                   itemBuilder: (context, index) {
//                     final product = clientState.cartProducts[index];
//                     final imageUrl = product['image'] != null
//                         ? 'http://192.168.1.100:3000${product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
//                         : null;
//                     final isFavorite = clientState.favoriteProducts.any((p) => p['_id'] == product['_id']);
//                     final isInCart = clientState.cartProducts.any((p) => p['_id'] == product['_id']);
//                     return Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12.0),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.3),
//                             spreadRadius: 1,
//                             blurRadius: 3,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Stack(
//                             children: [
//                               Container(
//                                 height: 150,
//                                 decoration: BoxDecoration(
//                                   borderRadius: const BorderRadius.only(
//                                     topLeft: Radius.circular(12),
//                                     topRight: Radius.circular(12),
//                                   ),
//                                   image: imageUrl != null
//                                       ? DecorationImage(
//                                           image: NetworkImage(imageUrl),
//                                           fit: BoxFit.cover,
//                                           onError: (exception, stackTrace) {
//                                             print('Error loading product image: $exception');
//                                           },
//                                         )
//                                       : null,
//                                 ),
//                                 child: imageUrl == null
//                                     ? const Center(
//                                         child: Text(
//                                           'No Image',
//                                           style: TextStyle(color: Colors.grey),
//                                         ),
//                                       )
//                                     : null,
//                               ),
//                               Positioned(
//                                 top: 8,
//                                 right: 8,
//                                 child: IconButton(
//                                   icon: Icon(
//                                     isFavorite ? Icons.favorite : Icons.favorite_border,
//                                     color: isFavorite ? Colors.red : Colors.grey,
//                                   ),
//                                   onPressed: () {
//                                     clientState.toggleFavorite(product);
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   product['title'] ?? 'Unknown Product',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 Row(
//                                   children: [
//                                     const Icon(
//                                       Icons.star,
//                                       color: Colors.yellow,
//                                       size: 16,
//                                     ),
//                                     Text(
//                                       '4.5 (120)',
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 12,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Text(
//                                   '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     clientState.toggleCart(product);
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: isInCart ? Colors.grey : Colors.black,
//                                     foregroundColor: Colors.white,
//                                     minimumSize: const Size(double.infinity, 36),
//                                   ),
//                                   child: Text(
//                                     isInCart ? 'Added to Cart' : 'Add to Cart',
//                                     style: GoogleFonts.poppins(fontSize: 12),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//         ],
//       ),
//     );
//   }
// }


// version 2 new cart page 

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'client-state.dart';
import 'payment_screen.dart'; // To be created for payment flow

class ClientCartPage extends StatefulWidget {
  const ClientCartPage({super.key});

  @override
  _ClientCartPageState createState() => _ClientCartPageState();
}

class _ClientCartPageState extends State<ClientCartPage> {
  final String baseUrl = 'http://localhost:3000';

  void _proceedToCheckout() async {
    final clientState = Provider.of<ClientState>(context, listen: false);
    final total = _calculateTotal();
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${clientState.token}',
      },
      body: jsonEncode({
        'userId': clientState.userId,
        'items': clientState.cartProducts.map((product) {
          final productId = product['_id']?.toString();
          return {
            'productId': productId,
            'sellerId': product['sellerId'],
            'price': product['negotiatedPrice'] ?? product['price'],
            'quantity': product['selectedQuantity'],
          };
        }).toList(),
        'total': total,
      }),
    );

    if (response.statusCode == 201) {
      final orderId = jsonDecode(response.body)['_id'];
      final paymentDetails = await http.post(
        Uri.parse('$baseUrl/payment/initiate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${clientState.token}',
        },
        body: jsonEncode({'total': total, 'orderId': orderId}),
      );

      if (paymentDetails.statusCode == 200) {
        final qrCodeUrl = jsonDecode(paymentDetails.body)['qrCodeUrl'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(qrCodeUrl: qrCodeUrl),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initiate payment: ${paymentDetails.body}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: ${response.body}')),
      );
    }
  }

  double _calculateTotal() {
    final clientState = Provider.of<ClientState>(context, listen: false);
    double total = 0;
    for (var product in clientState.cartProducts) {
      final price = product['negotiatedPrice'] ?? product['price'];
      final quantity = (product['selectedQuantity'] ?? 1).toDouble();
      total += price * quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final clientState = Provider.of<ClientState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            clientState.cartProducts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('No products in cart yet')),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: clientState.cartProducts.length,
                    itemBuilder: (context, index) {
                      final product = clientState.cartProducts[index];
                      final productId = product['_id']?.toString();
                      final imageUrl = product['image'] != null
                          ? '$baseUrl${product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
                          : null;
                      final price = product['negotiatedPrice'] ?? product['price'];
                      final quantity = product['selectedQuantity'] ?? 1;
                      final totalItemPrice = price * quantity;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
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
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['title'] ?? 'Unknown Product',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty $quantity',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${price.toStringAsFixed(2)} ETB',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (product['negotiatedPrice'] != null)
                                    Text(
                                      'Original: ${product['price'].toStringAsFixed(2)} ETB',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              '${totalItemPrice.toStringAsFixed(2)} ETB',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1.5,
                        indent: 16,
                        endIndent: 16,
                      ),
                    ),
                  ),
            if (clientState.cartProducts.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivery',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'STANDARD - Free',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_calculateTotal().toStringAsFixed(2)} ETB',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _proceedToCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDAA520), // Orange color from screenshot
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Checkout',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}