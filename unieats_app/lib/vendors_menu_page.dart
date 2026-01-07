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
        automaticallyImplyLeading: false,
      ),
      body: menuItems.isEmpty
          ? const Center(child: Text("No menu items"))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: menuItems.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: 300,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final key = menuItems.keys.elementAt(index);
                final item = Map<String, dynamic>.from(menuItems[key]);

                final price = (item['price'] is num)
                    ? item['price'].toDouble()
                    : double.tryParse(item['price']?.toString() ?? '0') ?? 0;

                final available = item['available'] == true;

                return GestureDetector(
                  onTap: () => _editPrice(key, price),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 1.3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child:
                                item['menuimage'] != null &&
                                    item['menuimage'].toString().isNotEmpty
                                ? Image.asset(
                                    item['menuimage'],
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.fastfood,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "RM ${price.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Orders: ${item['orderCount'] ?? 0}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: available
                                            ? Colors.green.shade100
                                            : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        available ? "Available" : "Unavailable",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: available
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 32,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Switch(
                                          value: available,
                                          activeColor: kPrimaryColor,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          onChanged: (_) => _toggleAvailability(
                                            key,
                                            available,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
        currentIndex: 2,
        vendorId: widget.vendorId,
      ),
    );
  }
}
