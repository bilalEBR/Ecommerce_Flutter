

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'client-state.dart';
import 'clientcheckout.dart';
import 'baseurl.dart';

class ClientCartPage extends StatefulWidget {
  const ClientCartPage({super.key});

  @override
  _ClientCartPageState createState() => _ClientCartPageState();
}

class _ClientCartPageState extends State<ClientCartPage> {
  final double deliveryFee = 150.0;
  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);
  final Color accentColor = const Color(0xFFFFD700);

  void _proceedToCheckout() {
    final clientState = Provider.of<ClientState>(context, listen: false);
    final total = _calculateFinalTotal();

    final cartItems = clientState.cartProducts.map((product) {
      return {
        'productId': product['_id']?.toString(),
        'sellerId': product['sellerId']?.toString(),
        'price': product['negotiatedPrice'] ?? product['price'],
        'image': product['image'],
        'quantity': product['selectedQuantity'] ?? 1,
      };
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientCheckoutPage(cartItems: cartItems, total: total),
      ),
    );
  }

  double _calculateSubTotal() {
    final clientState = Provider.of<ClientState>(context, listen: false);
    double total = 0;
    for (var product in clientState.cartProducts) {
      final price = product['negotiatedPrice'] ?? product['price'];
      final quantity = (product['selectedQuantity'] ?? 1).toDouble();
      total += price * quantity;
    }
    return total;
  }

  double _calculateFinalTotal() {
    return _calculateSubTotal() + deliveryFee;
  }

  void _removeFromCart(int index) {
    final clientState = Provider.of<ClientState>(context, listen: false);
    clientState.removeFromCart(index);
  }

  @override
  Widget build(BuildContext context) {
    final clientState = Provider.of<ClientState>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'Cart',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            clientState.cartProducts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No products in cart yet',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                    itemCount: clientState.cartProducts.length,
                    itemBuilder: (context, index) {
                      final product = clientState.cartProducts[index];
                      final imageUrl = product['image'] != null
                          ? '$baseUrl${product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
                          : null;
                      final price = product['negotiatedPrice'] ?? product['price'];
                      final quantity = product['selectedQuantity'] ?? 1;
                      final totalItemPrice = price * quantity;

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Stack(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey[300]!, width: 1),
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
                                        ? Center(
                                            child: Text(
                                              'No Image',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
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
                                          product['title'] ?? 'Unknown Product',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Qty $quantity',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${price.toStringAsFixed(2)} ETB',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                          ),
                                        ),
                                        if (product['negotiatedPrice'] != null)
                                          Row(
                                            children: [
                                              Text(
                                                'Original: ',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              Text(
                                                '${product['price'].toStringAsFixed(2)} ETB',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                  decoration: TextDecoration.lineThrough,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${totalItemPrice.toStringAsFixed(2)} ETB',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _removeFromCart(index),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Remove',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                  ),
            if (clientState.cartProducts.isNotEmpty) ...[
              const Divider(height: 24, thickness: 2, indent: 12, endIndent: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SUB TOTAL',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          '${_calculateSubTotal().toStringAsFixed(2)} ETB',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DELIVERY',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          '${deliveryFee.toStringAsFixed(2)} ETB',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL PRICE',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          '${_calculateFinalTotal().toStringAsFixed(2)} ETB',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _proceedToCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    shadowColor: Colors.grey.withOpacity(0.5),
                  ),
                  child: Text(
                    'Checkout',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
