import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kSecondaryColor = Color.fromARGB(255, 251, 255, 206);

class VendorMenuPage extends StatelessWidget {
  final Map<String, dynamic> vendorData;

  const VendorMenuPage({Key? key, required this.vendorData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuItems = vendorData['menu'] as Map<dynamic, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Vendor banner image + overlay info
          Stack(
            children: [
              // Full-width vendor image
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  image: vendorData['image'] != null && vendorData['image']!.isNotEmpty
                      ? DecorationImage(
                          image: AssetImage(vendorData['image']),
                          fit: BoxFit.cover,
                        )
                      : null,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
              ),

              // Dark overlay for text readability
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
              ),

              // Vendor info
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendorData['name'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${vendorData['category']} • ⭐ ${vendorData['rating'] ?? ''}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Back button
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

                // Handle price as string or number
                String price = '';
                if (item['price'] is num) {
                  price = "RM${(item['price'] as num).toStringAsFixed(2)}";
                } else if (item['price'] is String) {
                  price = item['price'];
                }

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Menu image
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: item['image'] != null && item['image']!.isNotEmpty
                              ? Image.asset(
                                  item['image'],
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Menu details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              price,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Add to Cart button
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            // TODO: Add to cart functionality
                          },
                          child: const Text(
                            "Add",
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255), // Text color matches primary color
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
