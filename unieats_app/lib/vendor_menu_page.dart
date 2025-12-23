import 'package:flutter/material.dart';
import 'customer_navigation_bar.dart';
import 'models/cart_model.dart';
//import 'cart_page.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kSecondaryColor = Color.fromARGB(255, 251, 255, 206);
const Color kBackgroundColor = Color(0xFFF6F6F6); // subtle grey

class VendorMenuPage extends StatefulWidget {
  final Map<String, dynamic> vendorData;

  const VendorMenuPage({Key? key, required this.vendorData}) : super(key: key);

  @override
  State<VendorMenuPage> createState() => _VendorMenuPageState();
}

class _VendorMenuPageState extends State<VendorMenuPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final menuItems = widget.vendorData['menu'] as Map<dynamic, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          // Vendor banner image
          Stack(
            children: [
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  image: widget.vendorData['image'] != null && widget.vendorData['image'].isNotEmpty
                      ? DecorationImage(
                          image: AssetImage(widget.vendorData['image']),
                          fit: BoxFit.cover,
                        )
                      : null,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
              ),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vendorData['name'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${widget.vendorData['category']} • ⭐ ${widget.vendorData['rating'] ?? ''}",
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Menu list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final itemKey = menuItems.keys.elementAt(index);
                final item = menuItems[itemKey] as Map<dynamic, dynamic>;

                double priceValue = 0;
                if (item['price'] is num) {
                  priceValue = item['price'].toDouble();
                } else if (item['price'] is String) {
                  priceValue = double.tryParse(item['price'].replaceAll("RM", "")) ?? 0;
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: item['menuimage'] != null && item['menuimage'].isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(item['menuimage'], width: 60, height: 60, fit: BoxFit.cover),
                          )
                        : null,
                    title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("RM ${priceValue.toStringAsFixed(2)}"),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        CartModel.addItem(widget.vendorData['name'], item['name'], priceValue, image: item['menuimage']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${item['name']} added to cart"), duration: const Duration(seconds: 1)),
                        );
                        setState(() {});
                      },
                      child: const Text('Add'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ✅ Fixed navigation bar
      bottomNavigationBar: CustomerNavigationBar(currentIndex: _currentIndex),
    );
  }
}
