import 'package:flutter/material.dart';

class VendorMenuPage extends StatefulWidget {
  final Map<String, dynamic> vendorData;

  const VendorMenuPage({Key? key, required this.vendorData}) : super(key: key);

  @override
  State<VendorMenuPage> createState() => _VendorMenuPageState();
}

class _VendorMenuPageState extends State<VendorMenuPage> {
  List<Map<String, dynamic>> menuItems = [];

  @override
  void initState() {
    super.initState();
    fetchMenuItems();
  }

  void fetchMenuItems() {
    final menuData = widget.vendorData['menu'];
    List<Map<String, dynamic>> items = [];

    if (menuData != null && menuData is Map) {
      menuData.forEach((key, value) {
        if (value is Map) {
          items.add(Map<String, dynamic>.from(value));
        }
      });
    }

    setState(() {
      menuItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    const kPrimaryColor = Color(0xFFB7916E);

    final vendorName = widget.vendorData['name'] ?? '';
    final vendorCategory = widget.vendorData['category'] ?? '';
    final vendorRating = widget.vendorData['rating']?.toString() ?? '';
    final vendorBanner = widget.vendorData['image'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Vendor Banner with info
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: kPrimaryColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendorName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "$vendorCategory • ⭐ $vendorRating",
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              background: vendorBanner.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                      child: Image.network(
                        vendorBanner,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                      ),
                    ),
            ),
          ),

          // Menu Items List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = menuItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: item['image'] != null && item['image'].isNotEmpty
                        ? Image.network(item['image'], width: 60, height: 60, fit: BoxFit.cover)
                        : CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            child: const Icon(Icons.fastfood, color: Colors.white),
                          ),
                    title: Text(item['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['description'] ?? ''),
                    trailing: Text(item['price'] != null ? 'RM ${item['price']}' : ''),
                    onTap: () {
                      // TODO: Add to cart action
                    },
                  ),
                );
              },
              childCount: menuItems.length,
            ),
          ),
        ],
      ),
    );
  }
}
