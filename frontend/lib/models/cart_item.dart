import 'menu_item.dart';

class CartItem {
  CartItem({
    required this.item,
    required this.quantity,
  });

  final MenuItem item;
  int quantity;

  int get total => item.price * quantity;
}
