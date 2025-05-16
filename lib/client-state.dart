

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class ClientState extends ChangeNotifier {
//   String? _userId;
//   String? _token;
//   List<Map<String, dynamic>> _favoriteProducts = [];
//   List<Map<String, dynamic>> _cartProducts = [];

//   String? get userId => _userId;
//   String? get token => _token;
//   List<Map<String, dynamic>> get favoriteProducts => _favoriteProducts;
//   List<Map<String, dynamic>> get cartProducts => _cartProducts;

//   ClientState() {
//     _loadPersistedData();
//   }

//   Future<void> _loadPersistedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token');
//     _userId = prefs.getString('userId');
//     print('Loaded from SharedPreferences - userId: $_userId, token: $_token'); // Debug
//     final favoritesJson = prefs.getString('favoriteProducts');
//     if (favoritesJson != null) {
//       _favoriteProducts = (jsonDecode(favoritesJson) as List).cast<Map<String, dynamic>>();
//     }
//     final cartJson = prefs.getString('cartProducts');
//     if (cartJson != null) {
//       _cartProducts = (jsonDecode(cartJson) as List).cast<Map<String, dynamic>>();
//     }
//     notifyListeners();
//   }

//   Future<void> _savePersistedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (_token != null) {
//       await prefs.setString('token', _token!);
//     } else {
//       await prefs.remove('token');
//     }
//     if (_userId != null) {
//       await prefs.setString('userId', _userId!);
//     } else {
//       await prefs.remove('userId');
//     }
//     await prefs.setString('favoriteProducts', jsonEncode(_favoriteProducts));
//     await prefs.setString('cartProducts', jsonEncode(_cartProducts));
//     print('Saved to SharedPreferences - userId: $_userId, token: $_token'); // Debug
//   }

//   void updateUserId(String? userId) {
//     _userId = userId;
//     _savePersistedData();
//     notifyListeners();
//   }

//   void updateToken(String? token) {
//     _token = token;
//     _savePersistedData();
//     notifyListeners();
//   }

//   void toggleFavorite(Map<String, dynamic> product) {
//     final index = _favoriteProducts.indexWhere((p) => p['_id'] == product['_id']);
//     if (index != -1) {
//       _favoriteProducts.removeAt(index);
//     } else {
//       _favoriteProducts.add(product);
//     }
//     _savePersistedData();
//     notifyListeners();
//   }

//   void toggleCart(Map<String, dynamic> product) {
//     final index = _cartProducts.indexWhere((p) => p['_id'] == product['_id']);
//     if (index != -1) {
//       _cartProducts.removeAt(index);
//     } else {
//       _cartProducts.add(product);
//     }
//     _savePersistedData();
//     notifyListeners();
//   }

//   void clearAuthData() {
//     _userId = null;
//     _token = null;
//     _favoriteProducts.clear();
//     _cartProducts.clear();
//     _savePersistedData();
//     notifyListeners();
//   }
// }


// new verion to remove products from cart

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class ClientState extends ChangeNotifier {
//   String? _userId;
//   String? _token;
//   List<Map<String, dynamic>> _favoriteProducts = [];
//   List<Map<String, dynamic>> _cartProducts = [];

//   String? get userId => _userId;
//   String? get token => _token;
//   List<Map<String, dynamic>> get favoriteProducts => _favoriteProducts;
//   List<Map<String, dynamic>> get cartProducts => _cartProducts;

//   ClientState() {
//     _loadPersistedData();
//   }

//   Future<void> _loadPersistedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token');
//     _userId = prefs.getString('userId');
//     print('Loaded from SharedPreferences - userId: $_userId, token: $_token'); // Debug
//     final favoritesJson = prefs.getString('favoriteProducts');
//     if (favoritesJson != null) {
//       _favoriteProducts = (jsonDecode(favoritesJson) as List).cast<Map<String, dynamic>>();
//     }
//     final cartJson = prefs.getString('cartProducts');
//     if (cartJson != null) {
//       _cartProducts = (jsonDecode(cartJson) as List).cast<Map<String, dynamic>>();
//     }
//     notifyListeners();
//   }

//   Future<void> _savePersistedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (_token != null) {
//       await prefs.setString('token', _token!);
//     } else {
//       await prefs.remove('token');
//     }
//     if (_userId != null) {
//       await prefs.setString('userId', _userId!);
//     } else {
//       await prefs.remove('userId');
//     }
//     await prefs.setString('favoriteProducts', jsonEncode(_favoriteProducts));
//     await prefs.setString('cartProducts', jsonEncode(_cartProducts));
//     print('Saved to SharedPreferences - userId: $_userId, token: $_token'); // Debug
//   }

//   void updateUserId(String? userId) {
//     _userId = userId;
//     _savePersistedData();
//     notifyListeners();
//   }

//   void updateToken(String? token) {
//     _token = token;
//     _savePersistedData();
//     notifyListeners();
//   }

//   void toggleFavorite(Map<String, dynamic> product) {
//     final index = _favoriteProducts.indexWhere((p) => p['_id'] == product['_id']);
//     if (index != -1) {
//       _favoriteProducts.removeAt(index);
//     } else {
//       _favoriteProducts.add(product);
//     }
//     _savePersistedData();
//     notifyListeners();
//   }

//   void toggleCart(Map<String, dynamic> product) {
//     final index = _cartProducts.indexWhere((p) => p['_id'] == product['_id']);
//     if (index != -1) {
//       _cartProducts.removeAt(index);
//     } else {
//       _cartProducts.add(product);
//     }
//     _savePersistedData();
//     notifyListeners();
//   }

//   void removeFromCart(int index) {
//     if (index >= 0 && index < _cartProducts.length) {
//       _cartProducts.removeAt(index);
//       _savePersistedData();
//       notifyListeners();
//     }
//   }

//   void clearAuthData() {
//     _userId = null;
//     _token = null;
//     _favoriteProducts.clear();
//     _cartProducts.clear();
//     _savePersistedData();
//     notifyListeners();
//   }
// }

// version to fix login 

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class ClientState extends ChangeNotifier {
//   String? _userId;
//   String? _token;
//   List<Map<String, dynamic>> _favoriteProducts = [];
//   List<Map<String, dynamic>> _cartProducts = [];

//   String? get userId => _userId;
//   String? get token => _token;
//   List<Map<String, dynamic>> get favoriteProducts => _favoriteProducts;
//   List<Map<String, dynamic>> get cartProducts => _cartProducts;

//   ClientState() {
//     print('Initializing ClientState');
//     _loadPersistedData();
//   }

//   Future<void> _loadPersistedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token');
//     _userId = prefs.getString('userId');
//     print('Loaded from SharedPreferences - userId: $_userId, token: $_token');
//     final favoritesJson = prefs.getString('favoriteProducts');
//     if (favoritesJson != null) {
//       _favoriteProducts = (jsonDecode(favoritesJson) as List).cast<Map<String, dynamic>>();
//     }
//     final cartJson = prefs.getString('cartProducts');
//     if (cartJson != null) {
//       _cartProducts = (jsonDecode(cartJson) as List).cast<Map<String, dynamic>>();
//     }
//     notifyListeners();
//   }

//   Future<void> _savePersistedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (_token != null) {
//       await prefs.setString('token', _token!);
//     } else {
//       await prefs.remove('token');
//     }
//     if (_userId != null) {
//       await prefs.setString('userId', _userId!);
//     } else {
//       await prefs.remove('userId');
//     }
//     await prefs.setString('favoriteProducts', jsonEncode(_favoriteProducts));
//     await prefs.setString('cartProducts', jsonEncode(_cartProducts));
//     print('Saved to SharedPreferences - userId: $_userId, token: $_token');
//   }

//   void updateUserId(String? userId) {
//     _userId = userId;
//     _savePersistedData();
//     notifyListeners();
//   }

//   void updateToken(String? token) {
//     _token = token;
//     _savePersistedData();
//     notifyListeners();
//   }

//   void toggleFavorite(Map<String, dynamic> product) {
//     final index = _favoriteProducts.indexWhere((p) => p['_id'] == product['_id']);
//     if (index != -1) {
//       _favoriteProducts.removeAt(index);
//     } else {
//       _favoriteProducts.add(product);
//     }
//     _savePersistedData();
//     notifyListeners();
//   }

//   void toggleCart(Map<String, dynamic> product) {
//     final index = _cartProducts.indexWhere((p) => p['_id'] == product['_id']);
//     if (index != -1) {
//       _cartProducts.removeAt(index);
//     } else {
//       _cartProducts.add(product);
//     }
//     _savePersistedData();
//     notifyListeners();
//   }

//   void removeFromCart(int index) {
//     if (index >= 0 && index < _cartProducts.length) {
//       _cartProducts.removeAt(index);
//       _savePersistedData();
//       notifyListeners();
//     }
//   }

//   void clearAuthData() {
//     _userId = null;
//     _token = null;
//     _favoriteProducts.clear();
//     _cartProducts.clear();
//     _savePersistedData();
//     notifyListeners();
//   }
// }

// version to solve quantity issue

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class ClientState extends ChangeNotifier {
//   String? _userId;
//   String? _token;
//   List<Map<String, dynamic>> _favoriteProducts = [];
//   List<Map<String, dynamic>> _cartProducts = [];

//   String? get userId => _userId;
//   String? get token => _token;
//   List<Map<String, dynamic>> get favoriteProducts => _favoriteProducts;
//   List<Map<String, dynamic>> get cartProducts => _cartProducts;

//   ClientState() {
//     print('Initializing ClientState');
//     _loadPersistedData();
//   }

//   Future<void> _loadPersistedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token');
//     _userId = prefs.getString('userId');
//     print('Loaded from SharedPreferences - userId: $_userId, token: $_token');
//     final favoritesJson = prefs.getString('favoriteProducts');
//     if (favoritesJson != null) {
//       _favoriteProducts = (jsonDecode(favoritesJson) as List).cast<Map<String, dynamic>>();
//     }
//     final cartJson = prefs.getString('cartProducts');
//     if (cartJson != null) {
//       _cartProducts = (jsonDecode(cartJson) as List).cast<Map<String, dynamic>>();
//     }
//     notifyListeners();
//   }

//   Future<void> _savePersistedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (_token != null) {
//       await prefs.setString('token', _token!);
//     } else {
//       await prefs.remove('token');
//     }
//     if (_userId != null) {
//       await prefs.setString('userId', _userId!);
//     } else {
//       await prefs.remove('userId');
//     }
//     await prefs.setString('favoriteProducts', jsonEncode(_favoriteProducts));
//     await prefs.setString('cartProducts', jsonEncode(_cartProducts));
//     print('Saved to SharedPreferences - userId: $_userId, token: $_token');
//   }

//   void updateUserId(String? userId) {
//     _userId = userId;
//     _savePersistedData();
//     notifyListeners();
//   }

//   void updateToken(String? token) {
//     _token = token;
//     _savePersistedData();
//     notifyListeners();
//   }

//   void toggleFavorite(Map<String, dynamic> product) {
//     final index = _favoriteProducts.indexWhere((p) => p['_id'] == product['_id']);
//     if (index != -1) {
//       _favoriteProducts.removeAt(index);
//     } else {
//       _favoriteProducts.add(product);
//     }
//     _savePersistedData();
//     notifyListeners();
//   }

//   void toggleCart(Map<String, dynamic> product) {
//     final index = _cartProducts.indexWhere((p) => p['_id'] == product['_id']);
//     if (index != -1) {
//       _cartProducts.removeAt(index);
//     } else {
//       _cartProducts.add(product);
//     }
//     _savePersistedData();
//     notifyListeners();
//   }

//   void removeFromCart(int index) {
//     if (index >= 0 && index < _cartProducts.length) {
//       _cartProducts.removeAt(index);
//       _savePersistedData();
//       notifyListeners();
//     }
//   }

//   void clearCart() {
//     _cartProducts.clear();
//     _savePersistedData();
//     notifyListeners();
//   }

//   void clearAuthData() {
//     _userId = null;
//     _token = null;
//     _favoriteProducts.clear();
//     _cartProducts.clear();
//     _savePersistedData();
//     notifyListeners();
//   }
// }


// // version to  solve login  problem

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class ClientState extends ChangeNotifier {
//   String? _userId;
//   String? _token;
//   String? _role;
//   bool _isInitialized = false;
//   List<Map<String, dynamic>> _favoriteProducts = [];
//   List<Map<String, dynamic>> _cartProducts = [];

//   String? get userId => _userId;
//   String? get token => _token;
//   String? get role => _role;
//   bool get isInitialized => _isInitialized;
//   List<Map<String, dynamic>> get favoriteProducts => _favoriteProducts;
//   List<Map<String, dynamic>> get cartProducts => _cartProducts;

//   ClientState() {
//     _initialize();
//   }

//   Future<void> _initialize() async {
//     await _loadPersistedData();
//     _isInitialized = true;
//     notifyListeners();
//   }

//   Future<void> _loadPersistedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token');
//     _userId = prefs.getString('userId');
//     _role = prefs.getString('role');
    
//     final favoritesJson = prefs.getString('favoriteProducts');
//     if (favoritesJson != null) {
//       _favoriteProducts = (jsonDecode(favoritesJson) as List).cast<Map<String, dynamic>>();
//     }
//     final cartJson = prefs.getString('cartProducts');
//     if (cartJson != null) {
//       _cartProducts = (jsonDecode(cartJson) as List).cast<Map<String, dynamic>>();
//     }
//   }

//   Future<void> _savePersistedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('token', _token ?? '');
//     await prefs.setString('userId', _userId ?? '');
//     await prefs.setString('role', _role ?? '');
//     await prefs.setString('favoriteProducts', jsonEncode(_favoriteProducts));
//     await prefs.setString('cartProducts', jsonEncode(_cartProducts));
//     notifyListeners();
//   }

//   Future<void> updateAuthData(String userId, String token, String role) async {
//     _userId = userId;
//     _token = token;
//     _role = role.toLowerCase();
//     await _savePersistedData();
//     notifyListeners();
//   }

//   Future<bool> isAuthenticated() async {
//     if (!_isInitialized) {
//       await _initialize();
//     }
//     return _userId != null && _token != null && _role != null;
//   }

//   void toggleFavorite(Map<String, dynamic> product) {
//     final index = _favoriteProducts.indexWhere((p) => p['_id'] == product['_id']);
//     if (index != -1) {
//       _favoriteProducts.removeAt(index);
//     } else {
//       _favoriteProducts.add(product);
//     }
//     _savePersistedData();
//     notifyListeners();
//   }

//   void toggleCart(Map<String, dynamic> product) {
//     final index = _cartProducts.indexWhere((p) => p['_id'] == product['_id']);
//     if (index != -1) {
//       _cartProducts.removeAt(index);
//     } else {
//       _cartProducts.add(product);
//     }
//     _savePersistedData();
//     notifyListeners();
//   }

//   void removeFromCart(int index) {
//     if (index >= 0 && index < _cartProducts.length) {
//       _cartProducts.removeAt(index);
//       _savePersistedData();
//       notifyListeners();
//     }
//   }

//   void clearCart() {
//     _cartProducts.clear();
//     _savePersistedData();
//     notifyListeners();
//   }

//   Future<void> clearAuthData() async {
//     _userId = null;
//     _token = null;
//     _role = null;
//     _favoriteProducts.clear();
//     _cartProducts.clear();
    
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('userId');
//     await prefs.remove('token');
//     await prefs.remove('role');
//     await prefs.remove('favoriteProducts');
//     await prefs.remove('cartProducts');
    
//     notifyListeners();
//   }
// }

// version 2
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ClientState extends ChangeNotifier {
  String? _userId;
  String? _token;
  String? _role;
  bool _isInitialized = false;
  List<Map<String, dynamic>> _favoriteProducts = [];
  List<Map<String, dynamic>> _cartProducts = [];
  
  VoidCallback? onLogout;

  // Getters
  String? get userId => _userId;
  String? get token => _token;
  String? get role => _role;
  bool get isInitialized => _isInitialized;
  List<Map<String, dynamic>> get favoriteProducts => _favoriteProducts;
  List<Map<String, dynamic>> get cartProducts => _cartProducts;

  ClientState() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadPersistedData();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadPersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _userId = prefs.getString('userId');
      _role = prefs.getString('role');
      
      final favoritesJson = prefs.getString('favoriteProducts');
      if (favoritesJson != null && favoritesJson.isNotEmpty) {
        _favoriteProducts = List<Map<String, dynamic>>.from(
          jsonDecode(favoritesJson) as List
        );
      }
      
      final cartJson = prefs.getString('cartProducts');
      if (cartJson != null && cartJson.isNotEmpty) {
        _cartProducts = List<Map<String, dynamic>>.from(
          jsonDecode(cartJson) as List
        );
      }
    } catch (e) {
      print('Error loading persisted data: $e');
      await clearAuthData();
    }
  }

  Future<void> _savePersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token ?? '');
      await prefs.setString('userId', _userId ?? '');
      await prefs.setString('role', _role ?? '');
      await prefs.setString('favoriteProducts', jsonEncode(_favoriteProducts));
      await prefs.setString('cartProducts', jsonEncode(_cartProducts));
    } catch (e) {
      print('Error saving persisted data: $e');
    }
  }

  Future<void> updateAuthData(String userId, String token, String role) async {
    _userId = userId;
    _token = token;
    _role = role.toLowerCase();
    await _savePersistedData();
    notifyListeners();
  }

  Future<bool> isAuthenticated() async {
    if (!_isInitialized) {
      await _initialize();
    }
    return _userId != null && 
           _token != null && 
           _role != null &&
           _userId!.isNotEmpty &&
           _token!.isNotEmpty;
  }

  Future<void> clearAuthData() async {
    _userId = null;
    _token = null;
    _role = null;
    _favoriteProducts.clear();
    _cartProducts.clear();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('token');
      await prefs.remove('role');
      await prefs.remove('favoriteProducts');
      await prefs.remove('cartProducts');
    } catch (e) {
      print('Error clearing auth data: $e');
    }
    
    notifyListeners();
    
    if (onLogout != null) {
      onLogout!();
    }
  }

  // Favorite products
  void toggleFavorite(Map<String, dynamic> product) {
    final productId = product['_id'];
    if (productId == null) return;

    final index = _favoriteProducts.indexWhere((p) => p['_id'] == productId);
    if (index != -1) {
      _favoriteProducts.removeAt(index);
    } else {
      _favoriteProducts.add(product);
    }
    _savePersistedData();
    notifyListeners();
  }

  bool isFavorite(String productId) {
    return _favoriteProducts.any((p) => p['_id'] == productId);
  }

  // Cart methods
  void toggleCart(Map<String, dynamic> product) {
    final productId = product['_id'];
    if (productId == null) return;

    final index = _cartProducts.indexWhere((p) => p['_id'] == productId);
    if (index != -1) {
      _cartProducts.removeAt(index);
    } else {
      _cartProducts.add({...product, 'quantity': 1});
    }
    _savePersistedData();
    notifyListeners();
  }

  void removeFromCart(dynamic identifier) {
    if (identifier is int) {
      if (identifier >= 0 && identifier < _cartProducts.length) {
        _cartProducts.removeAt(identifier);
      }
    } else if (identifier is String) {
      _cartProducts.removeWhere((p) => p['_id'] == identifier);
    }
    _savePersistedData();
    notifyListeners();
  }

  void updateCartItemQuantity(dynamic identifier, int newQuantity) {
    int? index;
    if (identifier is int) {
      index = identifier;
    } else if (identifier is String) {
      index = _cartProducts.indexWhere((p) => p['_id'] == identifier);
    }

    if (index != null && index >= 0 && index < _cartProducts.length) {
      _cartProducts[index]['quantity'] = newQuantity;
      _savePersistedData();
      notifyListeners();
    }
  }

  void clearCart() {
    _cartProducts.clear();
    _savePersistedData();
    notifyListeners();
  }

  double get cartTotal {
    return _cartProducts.fold(0, (total, item) {
      final price = (item['price'] as num?)?.toDouble() ?? 0;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
      return total + (price * quantity);
    });
  }

  int get cartItemCount {
    return _cartProducts.fold(0, (count, item) {
      return count + ((item['quantity'] as num?)?.toInt() ?? 1);
    });
  }
}