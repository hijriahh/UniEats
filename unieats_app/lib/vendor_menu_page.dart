import 'package:flutter/material.dart';
import 'customer_navigation_bar.dart';
import 'models/cart_model.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kSecondaryColor = Color.fromARGB(255, 251, 255, 206);
const Color kBackgroundColor = Color(0xFFF6F6F6);

class VendorMenuPage extends StatefulWidget {
  final Map<String, dynamic> vendorData;
  final String vendorKey;

  const VendorMenuPage({
    Key? key,
    required this.vendorData,
    required this.vendorKey,
  }) : super(key: key);

  @override
  State<VendorMenuPage> createState() => _VendorMenuPageState();
}

class _VendorMenuPageState extends State<VendorMenuPage> {
  int _currentIndex = 0;

  // SAFE IMAGE HANDLER
  Widget _menuImage(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: kSecondaryColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.fastfood, color: Colors.white, size: 32),
      );
    }

    return Image.asset(path, width: 80, height: 80, fit: BoxFit.cover);
  }

  // ADD TO CART POPUP
  void _showMenuPopup(Map<dynamic, dynamic> item) {
    int quantity = 1;

    final price = item['price'] is num
        ? item['price'].toDouble()
        : double.tryParse(item['price']?.toString() ?? '0') ?? 0;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _menuImage(item['menuimage']),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      item['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "RM ${price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        color: kPrimaryColor,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: kPrimaryColor,
                          onPressed: () {
                            if (quantity > 1) {
                              setDialogState(() => quantity--);
                            }
                          },
                        ),
                        Text(
                          quantity.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: kPrimaryColor,
                          onPressed: () => setDialogState(() => quantity++),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          for (int i = 0; i < quantity; i++) {
                            CartModel.addItem(
                              widget.vendorKey,
                              widget.vendorData['name'],
                              item['name'],
                              price,
                              image: item['menuimage'],
                            );
                          }

                          Navigator.pop(context);
                          setState(() {});
                        },
                        child: const Text(
                          "Add to Cart",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = widget.vendorData['menu'] as Map<dynamic, dynamic>? ?? {};

    //filter available menu items only
    final availableItems = menuItems.entries.where((entry) {
      final item = entry.value as Map;
      return item['available'] == true;
    }).toList();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          // VENDOR BANNER
          Stack(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                image:
                    widget.vendorData['image'] != null &&
                            widget.vendorData['image'].isNotEmpty
                        ? DecorationImage(
                            image: AssetImage(widget.vendorData['image']),
                            fit: BoxFit.cover,
                          )
                        : null,
              ),
            ),

            // 🔙 BACK BUTTON
            Positioned(
              top: 40,
              left: 12,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            Positioned(
              bottom: 16,
              left: 16,
              child: Text(
                widget.vendorData['name'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),


          // MENU LIST (CARD UI)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: availableItems.length,
              itemBuilder: (context, index) {
                final item =
                    availableItems[index].value as Map<dynamic, dynamic>;

                final price = item['price'] is num
                    ? item['price'].toDouble()
                    : double.tryParse(item['price']?.toString() ?? '0') ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: _menuImage(item['menuimage']),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "RM ${price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: kPrimaryColor,
                        iconSize: 30,
                        onPressed: () => _showMenuPopup(item),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomerNavigationBar(currentIndex: _currentIndex),
    );
  }
}
