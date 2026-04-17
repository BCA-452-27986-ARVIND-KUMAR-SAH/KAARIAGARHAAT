import '../models/cart_item.dart';

class CartData {
  static List<CartItem> items = [];

  static void addItem(CartItem newItem) {
    // Check if item already exists in cart
    int index = items.indexWhere((item) => item.productId == newItem.productId);
    
    if (index != -1) {
      // Item exists, update quantity
      CartItem existingItem = items[index];
      items[index] = CartItem(
        productId: existingItem.productId,
        title: existingItem.title,
        price: existingItem.price,
        quantity: existingItem.quantity + newItem.quantity,
        artisanId: existingItem.artisanId,
        imageUrl: existingItem.imageUrl,
      );
    } else {
      // Item doesn't exist, add to list
      items.add(newItem);
    }
  }
}
