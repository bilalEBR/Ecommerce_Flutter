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
import 'productdetails.dart';

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
      : 'http://192.168.1.100:3000';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCategories();
  }

  Future<void> _fetchProducts({String? categoryId}) async {
    setState(() => _isLoading = true);
    try {
      final clientState = Provider.of<ClientState>(context, listen: false);
      final token = clientState.token;

      if (token == null || token.isEmpty) {
        print('Token is null or empty, redirecting to login');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      print('Fetching products with token: $token'); // Debug log

      final uri = categoryId != null
          ? Uri.parse('$baseUrl/client-products?categoryId=$categoryId')
          : Uri.parse('$baseUrl/client-products');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Products response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched products: $data');
        setState(() {
          _products = data;
          _isLoading = false;
        });
      } else if (response.statusCode == 403) {
        print('Invalid token, redirecting to login');
        Navigator.pushReplacementNamed(context, '/login');
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
            _buildHomeTab(clientState),
            ClientFavoritesPage(),
            ClientCartPage(),
            ClientSearchPage(),
            ClientNotificationsPage(),
            ClientProfilePage(),
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
                height: 110,
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
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    child: CircleAvatar(
                                      radius: isSelected ? 35 : 30,
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
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category['name'] ?? 'Unknown',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: isSelected ? Colors.purple : Colors.black,
                                    ),
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
                          color: Colors.black12,
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
          child: RefreshIndicator(
            onRefresh: () async {
              await _fetchProducts(categoryId: _selectedCategoryId);
            },
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(child: Text('No products found'))
                    : GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
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
                          final averageRating = product['averageRating']?.toDouble() ?? 0.0;
                          final ratingCount = product['ratingCount']?.toString() ?? '0';
                          return GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(product: product),
                                ),
                              );
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
                                                  return const Icon(
                                                    Icons.star,
                                                    color: Color.fromARGB(255, 249, 224, 4),
                                                    size: 18,
                                                  );
                                                } else if (index < averageRating && averageRating % 1 != 0) {
                                                  return const Icon(
                                                    Icons.star_half,
                                                      color: Color.fromARGB(255, 249, 224, 4),
                                                     size: 18,
                                                  );
                                                } else {
                                                  return const Icon(
                                                    Icons.star_border,
                                                      color: Color.fromARGB(255, 249, 224, 4),
                                                     size: 18,
                                                  );
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
          ),
        ),
      ],
    );
  }
}