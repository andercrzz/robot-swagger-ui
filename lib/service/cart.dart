import 'package:robot/model/product_model.dart';

class Cart {
  static final List<ProductModel> _items = [];

  static List<ProductModel> get items => _items;

  static void addItem(ProductModel product) {
    _items.add(product);
  }

  static void removeItem(ProductModel product) {
    _items.remove(product);
  }

  static void clear() {
    _items.clear();
  }
}