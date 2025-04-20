// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

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
//     _loadPersistedData(); // Load token and other data on initialization
//   }

//   // Load persisted data when the app starts
//   Future<void> _loadPersistedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token');
//     _userId = prefs.getString('userId');
//     // Optionally persist favorites and cart if needed
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

//   // Save data to SharedPreferences
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

//   // Add a method to clear the token (e.g., on logout)
//   void clearAuthData() {
//     _userId = null;
//     _token = null;
//     _favoriteProducts.clear();
//     _cartProducts.clear();
//     _savePersistedData();
//     notifyListeners();
//   }
// }




// import 'package:flutter/material.dart';

// class ClientState extends ChangeNotifier {
//   List<dynamic> _favoriteProducts = [];
//   List<dynamic> _cartProducts = [];
//   String? _userId;
//   String? _token;

//   List<dynamic> get favoriteProducts => _favoriteProducts;
//   List<dynamic> get cartProducts => _cartProducts;
//   String? get userId => _userId;
//   String? get token => _token;

//   void updateUserId(String? userId) {
//     _userId = userId;
//     notifyListeners();
//   }

//   void updateToken(String? token) {
//     _token = token;
//     notifyListeners();
//   }

//   void logout() {
//     _userId = null;
//     _token = null;
//     _favoriteProducts.clear();
//     _cartProducts.clear();
//     notifyListeners();
//   }

//   void toggleFavorite(Map<String, dynamic> product) {
//     if (_favoriteProducts.any((p) => p['_id'] == product['_id'])) {
//       _favoriteProducts.removeWhere((p) => p['_id'] == product['_id']);
//     } else {
//       _favoriteProducts.add(product);
//     }
//     notifyListeners();
//   }

//   void toggleCart(Map<String, dynamic> product) {
//     final productId = product['_id'];
//     final selectedQuantity = product['selectedQuantity'] ?? 1;

//     final existingProductIndex = _cartProducts.indexWhere((p) => p['_id'] == productId);

//     if (existingProductIndex != -1) {
//       if (selectedQuantity <= 0) {
//         _cartProducts.removeAt(existingProductIndex);
//       } else {
//         final updatedProduct = Map<String, dynamic>.from(_cartProducts[existingProductIndex]);
//         updatedProduct['selectedQuantity'] = selectedQuantity;
//         _cartProducts[existingProductIndex] = updatedProduct;
//       }
//     } else {
//       if (selectedQuantity > 0) {
//         final productWithQuantity = Map<String, dynamic>.from(product);
//         productWithQuantity['selectedQuantity'] = selectedQuantity;
//         _cartProducts.add(productWithQuantity);
//       }
//     }
//     notifyListeners();
//   }
// }





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


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ClientState extends ChangeNotifier {
  String? _userId;
  String? _token;
  List<Map<String, dynamic>> _favoriteProducts = [];
  List<Map<String, dynamic>> _cartProducts = [];

  String? get userId => _userId;
  String? get token => _token;
  List<Map<String, dynamic>> get favoriteProducts => _favoriteProducts;
  List<Map<String, dynamic>> get cartProducts => _cartProducts;

  ClientState() {
    _loadPersistedData();
  }

  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    print('Loaded from SharedPreferences - userId: $_userId, token: $_token'); // Debug
    final favoritesJson = prefs.getString('favoriteProducts');
    if (favoritesJson != null) {
      _favoriteProducts = (jsonDecode(favoritesJson) as List).cast<Map<String, dynamic>>();
    }
    final cartJson = prefs.getString('cartProducts');
    if (cartJson != null) {
      _cartProducts = (jsonDecode(cartJson) as List).cast<Map<String, dynamic>>();
    }
    notifyListeners();
  }

  Future<void> _savePersistedData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString('token', _token!);
    } else {
      await prefs.remove('token');
    }
    if (_userId != null) {
      await prefs.setString('userId', _userId!);
    } else {
      await prefs.remove('userId');
    }
    await prefs.setString('favoriteProducts', jsonEncode(_favoriteProducts));
    await prefs.setString('cartProducts', jsonEncode(_cartProducts));
    print('Saved to SharedPreferences - userId: $_userId, token: $_token'); // Debug
  }

  void updateUserId(String? userId) {
    _userId = userId;
    _savePersistedData();
    notifyListeners();
  }

  void updateToken(String? token) {
    _token = token;
    _savePersistedData();
    notifyListeners();
  }

  void toggleFavorite(Map<String, dynamic> product) {
    final index = _favoriteProducts.indexWhere((p) => p['_id'] == product['_id']);
    if (index != -1) {
      _favoriteProducts.removeAt(index);
    } else {
      _favoriteProducts.add(product);
    }
    _savePersistedData();
    notifyListeners();
  }

  void toggleCart(Map<String, dynamic> product) {
    final index = _cartProducts.indexWhere((p) => p['_id'] == product['_id']);
    if (index != -1) {
      _cartProducts.removeAt(index);
    } else {
      _cartProducts.add(product);
    }
    _savePersistedData();
    notifyListeners();
  }

  void clearAuthData() {
    _userId = null;
    _token = null;
    _favoriteProducts.clear();
    _cartProducts.clear();
    _savePersistedData();
    notifyListeners();
  }
}



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
//     print('ClientState: Initializing and loading persisted data');
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
//     print('Updating userId: $userId');
//     _userId = userId;
//     _savePersistedData();
//     notifyListeners();
//   }

//   void updateToken(String? token) {
//     print('Updating token: $token');
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
//     print('Clearing auth data');
//     _userId = null;
//     _token = null;
//     _favoriteProducts.clear();
//     _cartProducts.clear();
//     _savePersistedData();
//     notifyListeners();
//   }
// }