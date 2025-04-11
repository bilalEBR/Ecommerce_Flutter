

// clienthomepage.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'client-state.dart';
import 'clientfavorites.dart';
import 'clientcart.dart';
import 'clientsearch.dart';
import 'clientnotifications.dart';
import 'clientprofile.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  _ClientHomePageState createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  String? _selectedCategoryId;

  final String baseUrl = kIsWeb
      ? 'http://localhost:3000'
      : 'http://192.168.1.100:3000'; // Replace with your backend URL

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCategories();
  }

  Future<void> _fetchProducts({String? categoryId}) async {
    setState(() => _isLoading = true);
    try {
      final uri = categoryId != null
          ? Uri.parse('$baseUrl/client-products?categoryId=$categoryId')
          : Uri.parse('$baseUrl/client-products');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched products: $data');
        setState(() {
          _products = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/categories'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched categories: $data');
        setState(() {
          _categories = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching categories: $e')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final clientState = Provider.of<ClientState>(context);

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(clientState), // Home tab
            ClientFavoritesPage(), // Favorites tab
            ClientCartPage(), // Cart tab
            ClientSearchPage(), // Search tab
            ClientNotificationsPage(), // Notifications tab
            ClientProfilePage(), // Profile tab
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }



Widget _buildHomeTab(ClientState clientState) {
  return Column(
    children: [
      Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NEW COLLECTION',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '20% OFF',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'SHOP NOW',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Categories',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: _categories.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final imageUrl = category['image'] != null
                            ? '$baseUrl${category['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
                            : null;
                        final isSelected = _selectedCategoryId == category['_id'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = isSelected ? null : category['_id'];
                              });
                              _fetchProducts(categoryId: _selectedCategoryId);
                            },
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                                  backgroundColor: isSelected ? Colors.purple.withOpacity(0.2) : Colors.grey[300],
                                  child: imageUrl == null
                                      ? Text(
                                          category['name']?.substring(0, 1) ?? 'C',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  category['name'] ?? 'Unknown',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Products',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategoryId = null;
                      });
                      _fetchProducts();
                    },
                    child: Text(
                      'See All',
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _products.isEmpty
                ? const Center(child: Text('No products found'))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final imageUrl = product['image'] != null
                          ? '$baseUrl${product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
                          : null;
                      final isFavorite = clientState.favoriteProducts.any((p) => p['_id'] == product['_id']);
                      final averageRating = product['averageRating']?.toStringAsFixed(1) ?? '0.0';
                      final ratingCount = product['ratingCount']?.toString() ?? '0';
                      return GestureDetector(
                        onTap: () async {
                          // Navigate to ProductDetailPage and wait for it to pop
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(product: product),
                            ),
                          );
                          // Refresh the product list after returning
                          await _fetchProducts(categoryId: _selectedCategoryId);
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
                                          '$averageRating ($ratingCount)',
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    ],
  );
}
}





class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedRating = 0; // User-selected rating (1 to 5)
  int _quantity = 1; // Selected quantity to add to cart
  final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://192.168.1.100:3000'; // Moved baseUrl to class level



Future<void> _submitRating(String productId, int rating) async {
  try {
    // Hardcoded userId for testing; replace with actual user ID from authentication
    const String userId = 'user123'; // Replace with actual user ID (e.g., from ClientState or auth token)

    final response = await http.post(
      Uri.parse('$baseUrl/client-products/rate-product'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'productId': productId,
        'rating': rating,
        'userId': userId, // Added userId to the request body
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully')),
      );
      // The refresh is handled by ClientHomePage when this page pops
    } else if (response.statusCode == 404) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating service unavailable. Please try again later.'),
        ),
      );
    } else {
      final errorMessage = jsonDecode(response.body)['error'] ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: $errorMessage')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error submitting rating: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final clientState = Provider.of<ClientState>(context);
    final imageUrl = widget.product['image'] != null
        ? '$baseUrl${widget.product['image']}?t=${DateTime.now().millisecondsSinceEpoch}'
        : null;
    final isInCart = clientState.cartProducts.any((p) => p['_id'] == widget.product['_id']);
    final availableQuantity = widget.product['quantity']?.toInt() ?? 0;
    final averageRating = widget.product['averageRating']?.toStringAsFixed(1) ?? '0.0';
    final ratingCount = widget.product['ratingCount']?.toString() ?? '0';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product['title'] ?? 'Product Details',
          style: GoogleFonts.poppins(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['title'] ?? 'Unknown Product',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.yellow,
                        size: 20,
                      ),
                      Text(
                        '$averageRating ($ratingCount)',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.product['price']?.toStringAsFixed(2) ?? '0.00'}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rate this product',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.yellow,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedRating = index + 1;
                          });
                          _submitRating(widget.product['_id'], _selectedRating);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product['description'] ?? 'No description available',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quantity',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (_quantity > 1) {
                              _quantity--;
                            }
                          });
                        },
                      ),
                      Text(
                        '$_quantity',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            if (_quantity < availableQuantity) {
                              _quantity++;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cannot exceed available quantity'),
                                ),
                              );
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Available: $availableQuantity',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_quantity > availableQuantity) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Selected quantity exceeds available stock'),
                          ),
                        );
                        return;
                      }
                      // Add the product to the cart with the selected quantity
                      final productWithQuantity = {
                        ...widget.product,
                        'selectedQuantity': _quantity,
                      };
                      clientState.toggleCart(productWithQuantity);
                      if (!isInCart) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.product['title']} added to cart!'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInCart ? Colors.grey : Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      isInCart ? 'Added to Cart' : 'Add to Cart',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Placeholder for navigating to chat page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chat page coming soon!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      'Contact Seller',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}