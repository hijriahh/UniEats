import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'vendor_menu_page.dart';
import 'customer_navigation_bar.dart';
import 'ai_chatbot.dart';
import 'ai_recommendation_widget.dart';

const Color kPrimaryColor = Color(0xFFB7916E); // Brown
const Color kSecondaryColor = Color.fromARGB(255, 251, 255, 206);
const Color kBackgroundColor = Color(0xFFF6F6F6); // subtle grey

class CustomerHomepage extends StatefulWidget {
  const CustomerHomepage({Key? key}) : super(key: key);

  @override
  State<CustomerHomepage> createState() => _CustomerHomepageState();
}

class _CustomerHomepageState extends State<CustomerHomepage> {
  int _currentIndex = 0;
  String selectedCategory = "All";
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
      final category = (vendor['category'] ?? '').toString();
      final menuText = extractMenu(vendor['menu']).join(" ").toLowerCase();
      final matchesCategory =
          selectedCategory == "All" || category == selectedCategory;
      final matchesSearch =
          searchQuery.isEmpty ||
          name.contains(searchQuery) ||
          menuText.contains(searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: kBackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Hello! Welcome 👋",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 96, 48, 12),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color.fromARGB(255, 96, 48, 12),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "UNIMAS Campus",
                        style: TextStyle(
                          color: Color.fromARGB(176, 96, 48, 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  decoration: InputDecoration(
                    hintText: "Search vendor or food",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Category chips with tick
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  "All",
                  "Breakfast & Lunch",
                  "Beverages",
                ].map((cat) => categoryChip(cat)).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Vendor list
            Expanded(
              child: filteredVendors.isEmpty
                  ? const Center(
                      child: Text(
                        "No vendors available",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView(
                      children: [
                        const SizedBox(height: 8),

                        // ⭐ AI Recommendation Widget
                        AiRecommendationWidget(
                          selectedCategory: selectedCategory,
                        ),

                        const SizedBox(height: 12),

                        ...filteredVendors
                            .map((vendor) => vendorCard(vendor))
                            .toList(),
                      ],
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.smart_toy, color: Colors.white),
        label: const Text(
          "Ask Yuni",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiChatbotPage()),
          );
        },
      ),

      // ✅ FORCE BOTTOM-LEFT POSITION
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ✅ bottom navigation bar — DO NOT CHANGE THIS
      bottomNavigationBar: CustomerNavigationBar(currentIndex: _currentIndex),
    );
  }

  // Category chip with tick
  Widget categoryChip(String category) {
    final bool selected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => selectedCategory = category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? kPrimaryColor : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Text(
                category,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.brown.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_circle, size: 16, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Vendor card with modern style
  Widget vendorCard(Map<String, dynamic> vendor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: kSecondaryColor,
          backgroundImage:
              vendor['image'] != null && vendor['image'].toString().isNotEmpty
              ? AssetImage(vendor['image'])
              : null,
          child: vendor['image'] == null
              ? Text(
                  vendor['name'] != null ? vendor['name'][0] : '',
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        title: Text(
          vendor['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${vendor['category']} • ⭐ ${vendor['rating'] ?? ''}"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VendorMenuPage(vendorData: vendor),
            ),
          );
        },
      ),
    );
  }

  List<String> extractMenu(dynamic menuData) {
    if (menuData == null || menuData is! Map) return [];
    final List<String> items = [];
    menuData.forEach((key, value) {
      if (value is Map && value['name'] != null)
        items.add(value['name'].toString());
    });
    return items;
  }
}
