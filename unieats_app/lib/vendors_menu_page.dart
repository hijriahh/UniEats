import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'vendor_navigation_bar.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kBackgroundColor = Color(0xFFF6F6F6);

class VendorsMenuPage extends StatefulWidget {
  final String vendorId;

  const VendorsMenuPage({Key? key, required this.vendorId}) : super(key: key);

  @override
  State<VendorsMenuPage> createState() => _VendorsMenuPageState();
}

class _VendorsMenuPageState extends State<VendorsMenuPage> {
  Map<String, dynamic> menuItems = {};

  @override
  void initState() {
    super.initState();
    _listenMenu();
  }

  // =========================
  // LOAD MENU FROM FIREBASE
  // =========================
  void _listenMenu() {
    FirebaseDatabase.instance
        .ref('vendors/${widget.vendorId}/menu')
        .onValue
        .listen((event) {
          if (!event.snapshot.exists) {
            setState(() => menuItems = {});
            return;
          }

          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          setState(() => menuItems = data);
        });
  }

  // =========================
  // UPDATE PRICE
  // =========================
  void _editPrice(String menuKey, dynamic oldPrice) {
    final controller = TextEditingController(text: oldPrice.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Price"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: "RM ",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () {
              final newPrice = double.tryParse(controller.text.trim());
              if (newPrice == null) return;

              FirebaseDatabase.instance
                  .ref('vendors/${widget.vendorId}/menu/$menuKey')
                  .update({'price': newPrice});

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // =========================
  // TOGGLE AVAILABILITY
  // =========================
  void _toggleAvailability(String key, bool current) {
    FirebaseDatabase.instance
        .ref('vendors/${widget.vendorId}/menu/$key')
        .update({'available': !current});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("My Menu"),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: menuItems.isEmpty
          ? const Center(child: Text("No menu items"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final key = menuItems.keys.elementAt(index);
                final item = Map<String, dynamic>.from(menuItems[key]);

                final price = (item['price'] is num)
                    ? item['price'].toDouble()
                    : double.tryParse(item['price']?.toString() ?? '0') ?? 0;

                final available = item['available'] == true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                    leading:
                        item['menuimage'] != null &&
                            item['menuimage'].toString().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              item['menuimage'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : null,
                    title: Text(
                      item['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("RM ${price.toStringAsFixed(2)}"),
                        const SizedBox(height: 4),
                        Text(
                          "Orders: ${item['orderCount'] ?? 0}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Switch(
                          value: available,
                          activeColor: kPrimaryColor,
                          onChanged: (_) => _toggleAvailability(key, available),
                        ),
                        GestureDetector(
                          onTap: () => _editPrice(key, price),
                          child: const Text(
                            "Edit",
                            style: TextStyle(
                              fontSize: 12,
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: VendorNavigationBar(
        currentIndex: 2, // Menu tab
        vendorId: widget.vendorId,
      ),
    );
  }
}
