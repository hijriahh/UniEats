import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'vendor_menu_page.dart';
import 'customer_navigation_bar.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kSecondaryColor = Color.fromARGB(255, 251, 255, 206);
const Color kBackgroundColor = Color(0xFFF6F6F6);

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int _currentIndex = 1;
  String searchQuery = "";
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  List<Map<String, dynamic>> menuList = [];

  @override
  void initState() {
    super.initState();
    database.child('vendors').onValue.listen((event) {
      if (!mounted) return;
      final data = event.snapshot.value;
      if (data == null || data is! Map) {
        setState(() => menuList = []);
        return;
      }

      final List<Map<String, dynamic>> loadedMenus = [];

      data.forEach((vendorId, vendorData) {
        if (vendorData is Map && vendorData['menu'] is Map) {
          final vendorName = vendorData['name'];
          final menu = vendorData['menu'] as Map;

          menu.forEach((menuId, menuData) {
            if (menuData is Map) {
              loadedMenus.add({
                'menuName': menuData['name'],
                'image': menuData['menuimage'],
                'price': menuData['price'],
                'vendorName': vendorName,
                'vendorData': Map<String, dynamic>.from(vendorData),
                'vendorKey': vendorId,
              });
            }
          });
        }
      });

      setState(() => menuList = loadedMenus);
    });
  }

  List<Map<String, dynamic>> get filteredMenu {
    if (searchQuery.isEmpty) return [];
    return menuList.where((item) {
      return item['menuName'].toString().toLowerCase().contains(searchQuery);
    }).toList();
  }

  Widget buildMenuImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return _imagePlaceholder();
    }

    try {
      // Use Image.asset for local assets
      return Image.asset(imagePath, width: 70, height: 70, fit: BoxFit.cover);
    } catch (_) {
      return _imagePlaceholder();
    }
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 70,
      height: 70,
      color: kSecondaryColor,
      alignment: Alignment.center,
      child: const Icon(Icons.fastfood, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Search Food",
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: Column(
        children: [
          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) =>
                    setState(() => searchQuery = value.toLowerCase()),
                decoration: const InputDecoration(
                  hintText: "Search food...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          /// SEARCH RESULTS
          Expanded(
            child: filteredMenu.isEmpty
                ? const Center(
                    child: Text(
                      "No food found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredMenu.length,
                    itemBuilder: (context, index) {
                      final item = filteredMenu[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VendorMenuPage(
                                vendorData: item['vendorData'],
                                vendorKey: item['vendorKey'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
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
                          child: Row(
                            children: [
                              /// MENU IMAGE
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: buildMenuImage(item['image']),
                              ),
                              const SizedBox(width: 12),

                              /// DETAILS
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['menuName'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['vendorName'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "RM ${item['price'] ?? ''}",
                                      style: const TextStyle(
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
