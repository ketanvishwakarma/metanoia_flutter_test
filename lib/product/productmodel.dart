import 'package:provider/provider.dart';

class Product{
  static List<Product> productList = [];

  final String name, id;
  final int numOfOrder, price;
  Product( this.id, this.name, this.numOfOrder, this.price);

}