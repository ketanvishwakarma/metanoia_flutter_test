import 'package:cloud_firestore/cloud_firestore.dart';

class Product{
  static List<Product> productList = [];

  final String name, id;
  final int numOfOrder, price;
  final List like;
  Product( this.id, this.name, this.numOfOrder, this.price, this.like);

}

class ProductDatabaseService {

  final productCollection = FirebaseFirestore.instance.collection('products');

  Future updateLike(id, likes) async {
    return await productCollection.doc(id).update({'like': likes});
  }

  Future<List<Product>> getProducts() async {
    List<Product> productList = [];
    await productCollection.get().then((value) {
      value.docs.forEach((element) {
        Product _product = new Product(
            element.id,
            element.get('name'),
            element.get('numOfOrder'),
            element.get('price'),
            element.get('like'));
        productList.add(_product);
      });
    });
    return productList;
  }
}