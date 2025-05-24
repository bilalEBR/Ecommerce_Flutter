

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'client-state.dart';
import 'clientfavorites.dart';
import 'clientcart.dart';
import 'clientprofile.dart';
import 'productdetails.dart';
import 'baseurl.dart';


class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  _ClientHomePageState createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  int _selectedIndex = 0;
  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  bool _isLoading = false;
  bool _isLoadingProfile = false;
  String? _selectedCategoryId;
  String? _errorMessage;
  String? _firstName = 'User';
  String? _profilePicture;
  String _sortOption = 'A-Z';
  List<dynamic> _sortedProducts = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Color primaryColor = const Color.fromARGB(255, 62, 62, 147); 
  final Color accentColor = const Color(0xFFFFD700); 

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print('ClientHomePage: Navigated to tab index $_selectedIndex');
    });
  }

  @override
  void initState() {
    super.initState();
    print('ClientHomePage initState: Initializing UI');
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _loadData();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _sortProducts(_sortOption);
      });
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isLoadingProfile = true;
      _errorMessage = null;
    });

    final clientState = Provider.of<ClientState>(context, listen: false);
    if (clientState.userId == null || clientState.token == null) {
      print('No userId or token in _loadData, redirecting to login');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    await _fetchClientProfile();
    await _fetchCategories();
    await _fetchProducts();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchClientProfile() async {
    final clientState = Provider.of<ClientState>(context, listen: false);
    final userId = clientState.userId;
    final token = clientState.token;

    print('Fetching profile for userId: $userId');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/client/profile/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Profile response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _firstName = data['firstName'] ?? 'User';
          _profilePicture = data['profilePicture'];
          _isLoadingProfile = false;
        });
      } else {
        print('Profile fetch failed: ${response.statusCode}');
        setState(() {
          _errorMessage = 'Failed to load profile. Please try again.';
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() {
        _errorMessage = 'Network error while loading profile.';
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/categories'));
      print('Categories response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _categories = data;
        });
      } else {
        print('Categories fetch failed: ${response.statusCode}');
        setState(() {
          _errorMessage = 'Failed to load categories. Please try again.';
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        _errorMessage = 'Network error while loading categories.';
      });
    }
  }

  Future<void> _fetchProducts({String? categoryId}) async {
    try {
      final clientState = Provider.of<ClientState>(context, listen: false);
      final token = clientState.token;
      final uri = categoryId != null
          ? Uri.parse('$baseUrl/client-products?categoryId=$categoryId')
          : Uri.parse('$baseUrl/client-products');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Products response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _products = data;
          _sortProducts(_sortOption);
        });
      } else if (response.statusCode == 403) {
        print('Invalid token, redirecting to login');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        print('Products fetch failed: ${response.statusCode}');
        setState(() {
          _errorMessage = 'Failed to load products. Please try again.';
        });
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        _errorMessage = 'Network error while loading products.';
      });
    }
  }

  void _sortProducts(String sortOption) {
    setState(() {
      _sortOption = sortOption;
      final filteredProducts = _searchQuery.isEmpty
          ? _products
          : _products.where((product) => (product['title'] ?? '').toLowerCase().contains(_searchQuery)).toList();
      _sortedProducts = List.from(filteredProducts);
      switch (sortOption) {
        case 'A-Z':
          _sortedProducts.sort((a, b) => (a['title'] ?? '').compareTo(b['title'] ?? ''));
          break;
        case 'Z-A':
          _sortedProducts.sort((a, b) => (b['title'] ?? '').compareTo(a['title'] ?? ''));
          break;
        case 'Rating':
          _sortedProducts.sort((a, b) => (b['averageRating']?.toDouble() ?? 0.0).compareTo(a['averageRating']?.toDouble() ?? 0.0));
          break;
        case 'Price':
          _sortedProducts.sort((a, b) => (a['price']?.toDouble() ?? 0.0).compareTo(b['price']?.toDouble() ?? 0.0));
          break;
      }
    });
  }

  void _seeAllProducts() {
    setState(() {
      _selectedCategoryId = null;
      _searchQuery = '';
      _searchController.clear();
      print('See All tapped: Resetting filters');
    });
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('ClientHomePage build: Rendering full UI');
    final clientState = Provider.of<ClientState>(context);

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(clientState),
            const ClientFavoritesPage(),
            const ClientCartPage(),
            // const ClientSearchPage(),
            // const ClientNotificationsPage(),
            const ClientProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          // BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          // BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeTab(ClientState clientState) {
    return RefreshIndicator(
      onRefresh: () => _fetchProducts(categoryId: _selectedCategoryId),
      color: accentColor,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Row(
                    children: [
                      _isLoadingProfile
                          ? const CircularProgressIndicator(strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF009A44)))
                          : CircleAvatar(
                              radius: 20,
                              backgroundImage: _profilePicture != null
                                  ? NetworkImage('$baseUrl$_profilePicture')
                                  : null,
                              backgroundColor: Colors.grey[300],
                              child: _profilePicture == null
                                  ? Text(
                                      _firstName != null && _firstName!.isNotEmpty
                                          ? _firstName![0].toUpperCase()
                                          : 'U',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                      const SizedBox(width: 12),
                      _isLoadingProfile
                          ? Text('Loading...', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold))
                          : Text(
                              'Welcome, ${_firstName ?? 'User'}',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search EthioMarket products...',
                              hintStyle: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                              prefixIcon: Icon(Icons.search, color: primaryColor),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Stack(
                        children: [
                          IconButton(
                            icon: Icon(Icons.favorite, color: primaryColor),
                            onPressed: () => _onItemTapped(1),
                          ),
                          if (clientState.favoriteProducts.isNotEmpty)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${clientState.favoriteProducts.length}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: Icon(Icons.shopping_cart, color: primaryColor),
                            onPressed: () => _onItemTapped(2),
                          ),
                          if (clientState.cartProducts.isNotEmpty)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${clientState.cartProducts.length}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
               
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Categories',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                 const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: _categories.isEmpty
                      ? Center(child: Text('No categories loaded', style: GoogleFonts.poppins(fontSize: 16)))
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
                                        backgroundColor: isSelected ? primaryColor.withOpacity(0.2) : Colors.grey[300],
                                        child: imageUrl == null
                                            ? Text(
                                                category['name']?.substring(0, 1) ?? 'C',
                                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                                              )
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      category['name'] ?? 'Unknown',
                                      style: GoogleFonts.poppins(fontSize: 12, color: isSelected ? primaryColor : Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Products',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: _seeAllProducts,
                            child: Text(
                              'See All',
                              style: GoogleFonts.poppins(fontSize: 14, color: primaryColor, fontWeight: FontWeight.w600),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.sort, color: primaryColor),
                            onSelected: (value) => _sortProducts(value),
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'A-Z', child: Text('Sort A-Z')),
                              const PopupMenuItem(value: 'Z-A', child: Text('Sort Z-A')),
                              const PopupMenuItem(value: 'Rating', child: Text('Sort by Rating')),
                              const PopupMenuItem(value: 'Price', child: Text('Sort by Price')),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Retry', style: GoogleFonts.poppins()),
                            ),
                          ],
                        ),
                      )
                    : _products.isEmpty
                        ? Center(
                            child: Text(
                              'No products available. Pull to refresh.',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          )
                        : GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio: 0.7,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            itemCount: _sortedProducts.length,
                            itemBuilder: (context, index) {
                              final product = _sortedProducts[index];
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
                                    MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
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
                                                ? const Center(child: Text('No Image', style: TextStyle(color: Colors.grey)))
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
                                              onPressed: () => clientState.toggleFavorite(product),
                                            ),
                                          ),
                                          if (product['productStatus'] == 'sold' || product['quantity'] == 0)
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
                                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: List.generate(5, (index) {
                                                if (index < averageRating.floor()) {
                                                  return Icon(Icons.star, color: accentColor, size: 18);
                                                } else if (index < averageRating && averageRating % 1 != 0) {
                                                  return Icon(Icons.star_half, color: accentColor, size: 18);
                                                } else {
                                                  return Icon(Icons.star_border, color: accentColor, size: 18);
                                                }
                                              }),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${product['price']?.toStringAsFixed(2) ?? '0.00'} ETB',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                // color: Colors.black87,
                                                color: primaryColor,
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
      ),
    );
  }
}
