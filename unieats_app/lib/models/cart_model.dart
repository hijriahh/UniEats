class CartItem {
  final String vendorKey;
  final String vendorName;
  final String name;
  final double price;
  int quantity;
  final String? menuimage; // store image path

  CartItem({
    required this.vendorKey,
    required this.vendorName,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.menuimage,
  });
}

class CartModel {
  static final List<CartItem> _items = [];

  // Get cart items
  static List<CartItem> get items => _items;

  // Add item to cart
  static void addItem(
    String vendorKey,
    String vendorName,
    String name,
    double price, {
    String? image,
  }) {
    final index = _items.indexWhere(
      (item) => item.vendorKey == vendorKey && item.name == name,
    );
    if (index != -1) {
      _items[index].quantity += 1;
    } else {
      _items.add(
        CartItem(
          vendorKey: vendorKey,
          vendorName: vendorName,
          name: name,
          price: price,
          menuimage: image,
        ),
      );
    }
  }

  // Decrease quantity or remove
  static void decreaseItem(CartItem item) {
    if (item.quantity > 1) {
      item.quantity -= 1;
    } else {
      _items.remove(item);
    }
  }

  // Total price
  static double get totalPrice {
    double total = 0;
    for (var item in _items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  // Clear cart
  static void clear() {
    _items.clear();
  }
}
