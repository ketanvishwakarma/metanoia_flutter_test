import 'package:flutter/material.dart';
import 'package:metanoia_flutter_test/product/productmodel.dart';

class CartProduct {
  final String? name, id;
  final int? numOfOrder, price;
  int? quantity;

  CartProduct({this.id, this.quantity, this.name, this.numOfOrder, this.price});
}

class CartModel extends ChangeNotifier {
  List<CartProduct> productCartItems = [];

  int totalPrice() {
    int total = 0;
    productCartItems.forEach((element) {
      total += element.price! * element.quantity!;
    });
    return total;
  }

  void add(Product product) {
    CartProduct cartProduct = productCartItems.firstWhere(
      (element) {
        if (element.id == product.id) {
          element.quantity = element.quantity! + 1;
          return true;
        }
        return false;
      },
      orElse: () => CartProduct(
          id: product.id,
          quantity: 1,
          name: product.name,
          numOfOrder: product.numOfOrder,
          price: product.price),
    );
    if (cartProduct.quantity == 1) productCartItems.add(cartProduct);
    notifyListeners();
  }
  void removeAll() {
    productCartItems.clear();
    notifyListeners();
  }
}
