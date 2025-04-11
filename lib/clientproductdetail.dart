


// class ProductDetailPage extends StatelessWidget {
//   final Map<String, dynamic> product;

//   const ProductDetailPage({super.key, required this.product});

//   @override
//   Widget build(BuildContext context) {
//     final clientState = Provider.of<ClientState>(context);
//     final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000';
//     final imageUrl = product['image'] != null
//         ? '$baseUrl${product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
//         : null;
//     final isInCart = clientState.cartProducts.any((p) => p['_id'] == product['_id']);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           product['title'] ?? 'Product Details',
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
//                     product['title'] ?? 'Unknown Product',
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
//                         '4.5 (120)',
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
//                     style: GoogleFonts.poppins(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
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
//                     product['description'] ?? 'No description available',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () {
//                       clientState.toggleCart(product);
//                       if (!isInCart) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('${product['title']} added to cart!'),
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
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }