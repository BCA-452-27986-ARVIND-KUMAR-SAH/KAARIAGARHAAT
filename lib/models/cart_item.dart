class CartItem {
  final String productId;
  final String title;
  final double price;
  final int quantity;
  final String artisanId;
  final String imageUrl; // Added imageUrl field

  CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.artisanId,
    required this.imageUrl, // Added to constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'quantity': quantity,
      'artisanId': artisanId,
      'imageUrl': imageUrl, // Added to map
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      quantity: int.tryParse(map['quantity']?.toString() ?? '1') ?? 1,
      artisanId: map['artisanId']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '', // Added to factory
    );
  }
}
