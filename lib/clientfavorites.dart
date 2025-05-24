
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'client-state.dart';
// import 'productdetails.dart';
// import 'baseurl.dart';

// class ClientFavoritesPage extends StatelessWidget {
//   const ClientFavoritesPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final clientState = Provider.of<ClientState>(context);

//     print('Favorite products: ${clientState.favoriteProducts}');

//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               'Favorites' ,
              
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           clientState.favoriteProducts.isEmpty
//               ? const Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Center(child: Text('No favorite products yet')),
//                 )
//               : GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 16.0,
//                     mainAxisSpacing: 16.0,
//                     childAspectRatio: 0.7, // Match ClientHomePage
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                   itemCount: clientState.favoriteProducts.length,
//                   itemBuilder: (context, index) {
//                     final product = clientState.favoriteProducts[index];
//                     // Debug product data
//                     print('Product[${product['_id']}]: image=${product['image']}, title=${product['title']}');
//                     final imageUrl = product['image'] != null
//                         ? '$baseUrl${product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
//                         : null;
//                     final isFavorite = clientState.favoriteProducts.any((p) => p['_id'] == product['_id']);
//                     final averageRating = product['averageRating']?.toDouble() ?? 0.0;
//                     final ratingCount = product['ratingCount']?.toString() ?? '0';
//                     return GestureDetector(
//                       onTap: () {
//                         print('Navigating to ProductDetailPage: ${product['_id']}, image=${product['image']}');
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ProductDetailPage(product: product),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12.0),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.3),
//                               spreadRadius: 1,
//                               blurRadius: 3,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Stack(
//                               children: [
//                                 Container(
//                                   height: 150,
//                                   decoration: BoxDecoration(
//                                     borderRadius: const BorderRadius.only(
//                                       topLeft: Radius.circular(12),
//                                       topRight: Radius.circular(12),
//                                     ),
//                                     image: imageUrl != null
//                                         ? DecorationImage(
//                                             image: NetworkImage(imageUrl),
//                                             fit: BoxFit.cover,
//                                             onError: (exception, stackTrace) {
//                                               print('Error loading image for ${product['_id']}: $exception');
//                                             },
//                                           )
//                                         : const DecorationImage(
//                                             image: AssetImage('assets/placeholder.jpg'),
//                                             fit: BoxFit.cover,
//                                           ),
//                                   ),
//                                 ),
//                                 Positioned(
//                                   top: 8,
//                                   right: 8,
//                                   child: IconButton(
//                                     icon: Icon(
//                                       isFavorite ? Icons.favorite : Icons.favorite_border,
//                                       color: isFavorite ? Colors.red : Colors.grey,
//                                     ),
//                                     onPressed: () {
//                                       clientState.toggleFavorite(product);
//                                     },
//                                   ),
//                                 ),
//                                 if (product['productStatus'] == 'sold') ...[
//                                   Positioned(
//                                     top: 8,
//                                     left: 8,
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                       decoration: BoxDecoration(
//                                         color: Colors.red,
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Text(
//                                         'Sold',
//                                         style: GoogleFonts.poppins(
//                                           color: Colors.white,
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     product['title'] ?? 'Unknown Product',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Row(
//                                     children: [
//                                       Row(
//                                         children: List.generate(5, (index) {
//                                           if (index < averageRating.floor()) {
//                                             return const Icon(
//                                               Icons.star,
//                                               color: Color.fromARGB(255, 249, 224, 4),
//                                               size: 18,
//                                             );
//                                           } else if (index < averageRating && averageRating % 1 != 0) {
//                                             return const Icon(
//                                               Icons.star_half,
//                                               color: Color.fromARGB(255, 249, 224, 4),
//                                               size: 18,
//                                             );
//                                           } else {
//                                             return const Icon(
//                                               Icons.star_border,
//                                               color: Color.fromARGB(255, 249, 224, 4),
//                                               size: 18,
//                                             );
//                                           }
//                                         }),
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Text(
//                                         '${averageRating.toStringAsFixed(1)} ($ratingCount)',
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 12,
//                                           color: Colors.black87,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     '${product['price']?.toStringAsFixed(2) ?? '0.00'} ETB',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: const Color.fromARGB(255, 80, 64, 81),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'client-state.dart';
import 'productdetails.dart';
import 'baseurl.dart';

class ClientFavoritesPage extends StatelessWidget {
  const ClientFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final clientState = Provider.of<ClientState>(context);
    final Color primaryColor = const Color.fromARGB(255, 62, 62, 147);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Favorites',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          ? '$baseUrl${product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
                          : null;
                      final isFavorite = clientState.favoriteProducts.any((p) => p['_id'] == product['_id']);
                      final averageRating = product['averageRating']?.toDouble() ?? 0.0;
                      final ratingCount = product['ratingCount']?.toString() ?? '0';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(product: product),
                            ),
                          );
                        },
                        child: Container(
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
                                            )
                                          : const DecorationImage(
                                              image: AssetImage('assets/placeholder.jpg'),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
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
                                  if (product['productStatus'] == 'sold')
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Sold',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Row(
                                          children: List.generate(5, (index) {
                                            if (index < averageRating.floor()) {
                                              return const Icon(Icons.star, color: Colors.amber, size: 18);
                                            } else if (index < averageRating && averageRating % 1 != 0) {
                                              return const Icon(Icons.star_half, color: Colors.amber, size: 18);
                                            } else {
                                              return const Icon(Icons.star_border, color: Colors.amber, size: 18);
                                            }
                                          }),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${averageRating.toStringAsFixed(1)} ($ratingCount)',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${product['price']?.toStringAsFixed(2) ?? '0.00'} ETB',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(255, 80, 64, 81),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
