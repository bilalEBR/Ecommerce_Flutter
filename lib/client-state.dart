
// //  client state

// import 'package:flutter/material.dart';

// class ClientState extends ChangeNotifier {
//   List<dynamic> _favoriteProducts = [];
//   List<dynamic> _cartProducts = [];

//   List<dynamic> get favoriteProducts => _favoriteProducts;
//   List<dynamic> get cartProducts => _cartProducts;

//   void toggleFavorite(Map<String, dynamic> product) {
//     if (_favoriteProducts.any((p) => p['_id'] == product['_id'])) {
//       _favoriteProducts.removeWhere((p) => p['_id'] == product['_id']);
//     } else {
//       _favoriteProducts.add(product);
//     }
//     notifyListeners();
//   }

//   void toggleCart(Map<String, dynamic> product) {
//     if (_cartProducts.any((p) => p['_id'] == product['_id'])) {
//       _cartProducts.removeWhere((p) => p['_id'] == product['_id']);
//     } else {
//       _cartProducts.add(product);
//     }
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';

class ClientState extends ChangeNotifier {
  List<dynamic> _favoriteProducts = [];
  List<dynamic> _cartProducts = [];

  List<dynamic> get favoriteProducts => _favoriteProducts;
  List<dynamic> get cartProducts => _cartProducts;

  void toggleFavorite(Map<String, dynamic> product) {
    if (_favoriteProducts.any((p) => p['_id'] == product['_id'])) {
      _favoriteProducts.removeWhere((p) => p['_id'] == product['_id']);
    } else {
      _favoriteProducts.add(product);
    }
    notifyListeners();
  }

  void toggleCart(Map<String, dynamic> product) {
    final productId = product['_id'];
    final selectedQuantity = product['selectedQuantity'] ?? 1; // Default to 1 if not specified

    final existingProductIndex = _cartProducts.indexWhere((p) => p['_id'] == productId);

    if (existingProductIndex != -1) {
      // Product is already in the cart
      if (selectedQuantity <= 0) {
        // Remove the product if quantity is 0 or less
        _cartProducts.removeAt(existingProductIndex);
      } else {
        // Update the quantity of the existing product
        final updatedProduct = Map<String, dynamic>.from(_cartProducts[existingProductIndex]);
        updatedProduct['selectedQuantity'] = selectedQuantity;
        _cartProducts[existingProductIndex] = updatedProduct;
      }
    } else {
      // Product is not in the cart, add it with the selected quantity
      if (selectedQuantity > 0) {
        final productWithQuantity = Map<String, dynamic>.from(product);
        productWithQuantity['selectedQuantity'] = selectedQuantity;
        _cartProducts.add(productWithQuantity);
      }
    }
    notifyListeners();
  }
}