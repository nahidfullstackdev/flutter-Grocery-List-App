import 'package:flutter_groceries/models/category.dart';

class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
  });
  final String id;
  final String name;
  final Category category;
  final int quantity;
}
