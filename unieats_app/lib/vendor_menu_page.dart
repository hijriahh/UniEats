import 'package:flutter/material.dart';
import 'customer_navigation_bar.dart';
import 'models/cart_model.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kSecondaryColor = Color.fromARGB(255, 251, 255, 206);
const Color kBackgroundColor = Color(0xFFF6F6F6);

class VendorMenuPage extends StatefulWidget {
  final Map<String, dynamic> vendorData;
  final String vendorKey; // ✅ ADD THIS

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

  void _showMenuPopup(Map<dynamic, dynamic> item) {
    int quantity = 1;
    double priceValue = 0;

    if (item['price'] is num) {
      priceValue = item['price'].toDouble();
    } else if (item['price'] is String) {
      priceValue = double.tryParse(item['price'].replaceAll("RM", "")) ?? 0;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item['menuimage'] != null &&
                        item['menuimage'].isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          item['menuimage'],
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
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
                    const SizedBox(height: 8),

                    Text(
                      "RM ${priceValue.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (quantity > 1) {
                                  setStateDialog(() => quantity--);
                                }
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                              color: kPrimaryColor,
                              iconSize: 30,
                            ),
                            Text(
                              quantity.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setStateDialog(() => quantity++),
                              icon: const Icon(Icons.add_circle_outline),
                              color: kPrimaryColor,
                              iconSize: 30,
                            ),
                          ],
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            CartModel.addItem(
                              widget.vendorKey,
                              item['name'],
                              priceValue,
                              image: item['menuimage'],
                            );

                            Navigator.pop(context);
                            setState(() {});
                          },
                          child: const Text("Add to Cart"),
                        ),
                      ],
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

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          // Banner
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

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems.values.elementAt(index);

                final price = item['price'] is num
                    ? item['price'].toDouble()
                    : double.tryParse(item['price']?.toString() ?? '0') ?? 0;

                return ListTile(
                  title: Text(item['name'] ?? ''),
                  subtitle: Text("RM ${price.toStringAsFixed(2)}"),
                  trailing: ElevatedButton(
                    onPressed: () => _showMenuPopup(item),
                    child: const Text("Add"),
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
