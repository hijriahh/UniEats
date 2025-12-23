import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'vendor_menu_page.dart';
import 'customer_navigation_bar.dart';

const Color kPrimaryColor = Color(0xFFB7916E); // Brown
const Color kSecondaryColor = Color.fromARGB(255, 251, 255, 206);
const Color kBackgroundColor = Color(0xFFF6F6F6); // subtle grey

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int _currentIndex = 1;
  String searchQuery = "";
  late final DatabaseReference database;
  List<Map<String, dynamic>> vendors = [];

  @override
  void initState() {
    super.initState();
    database = FirebaseDatabase.instance.ref();
    database.child('vendors').onValue.listen((event) {
      if (!mounted) return;
      final data = event.snapshot.value;
      if (data == null || data is! Map) {
        setState(() => vendors = []);
        return;
      }
      final List<Map<String, dynamic>> loaded = [];
      data.forEach((key, value) {
        if (value is Map) loaded.add(Map<String, dynamic>.from(value));
      });
      setState(() => vendors = loaded);
    });
  }

  List<Map<String, dynamic>> get filteredVendors {
    return vendors.where((vendor) {
      final name = (vendor['name'] ?? '').toString().toLowerCase();
      final menuText = extractMenu(vendor['menu']).join(" ").toLowerCase();
      return searchQuery.isEmpty || name.contains(searchQuery) || menuText.contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context), // <- goes back to previous page
        ),
        title: const Text(
          "Search",
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))
                ],
              ),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                decoration: const InputDecoration(
                  hintText: "Search vendor or food",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Search results
          Expanded(
            child: filteredVendors.isEmpty
                ? const Center(child: Text("No vendors found", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredVendors.length,
                    itemBuilder: (context, index) {
                      final vendor = filteredVendors[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: kSecondaryColor,
                            backgroundImage: vendor['image'] != null && vendor['image'].toString().isNotEmpty
                                ? AssetImage(vendor['image'])
                                : null,
                            child: vendor['image'] == null
                                ? Text(vendor['name'] != null ? vendor['name'][0] : '',
                                    style: const TextStyle(color: Colors.white))
                                : null,
                          ),
                          title: Text(vendor['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${vendor['category']} • ⭐ ${vendor['rating'] ?? ''}"),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => VendorMenuPage(vendorData: vendor)),
                            );
                          },
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

  List<String> extractMenu(dynamic menuData) {
    if (menuData == null || menuData is! Map) return [];
    final List<String> items = [];
    menuData.forEach((key, value) {
      if (value is Map && value['name'] != null) items.add(value['name'].toString());
    });
    return items;
  }
}
