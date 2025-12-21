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
                  child: ListTile(
                    leading: item['menuimage'] != null && item['menuimage'].isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              item['menuimage'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : null,
                    title: Text(item['name'] ?? ''),
                    subtitle: Text(price),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: kPrimaryColor, width: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: () {
                        // TODO: Add to cart action
                      },
                      child: const Text(
                        "Add",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
