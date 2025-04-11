// clientfavorites.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'client-state.dart';

class ClientFavoritesPage extends StatelessWidget {
  const ClientFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final clientState = Provider.of<ClientState>(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Favorites',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          clientState.favoriteProducts.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('No favorite products yet')),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: clientState.favoriteProducts.length,
                  itemBuilder: (context, index) {
                    final product = clientState.favoriteProducts[index];
                    final imageUrl = product['image'] != null
                        ? 'http://192.168.1.100:3000${product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
                        : null;
                    final isFavorite = clientState.favoriteProducts.any((p) => p['_id'] == product['_id']);
                    final isInCart = clientState.cartProducts.any((p) => p['_id'] == product['_id']);
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
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
                                child: IconButton(
                                  icon: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: isFavorite ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {
                                    clientState.toggleFavorite(product);
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['title'] ?? 'Unknown Product',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                      size: 16,
                                    ),
                                    Text(
                                      '4.5 (120)',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ElevatedButton(
                                  onPressed: () {
                                    clientState.toggleCart(product);
                                    if (!isInCart) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${product['title']} added to cart!'),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isInCart ? Colors.grey : Colors.black,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 36),
                                  ),
                                  child: Text(
                                    isInCart ? 'Added to Cart' : 'Add to Cart',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}