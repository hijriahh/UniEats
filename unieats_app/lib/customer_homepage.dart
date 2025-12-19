import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'vendor_menu_page.dart';
import 'customer_navigation_bar.dart';

// Theme colors
const Color kPrimaryColor = Color(0xFFA07F60); // warm brown
const Color kSecondaryColor = Color.fromARGB(255, 251, 255, 206); // white
const Color kBackgroundColor = Color.fromARGB(255, 255, 255, 255);
const double kHorizontalPadding = 12.0;

class CustomerHomepage extends StatefulWidget {
  @override
  _CustomerHomepageState createState() => _CustomerHomepageState();
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

    database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://unieats-f88f7-default-rtdb.asia-southeast1.firebasedatabase.app",
    ).ref();

    database.child('vendors').onValue.listen((event) {
      if (event.snapshot.value == null) {
        setState(() => vendors = []);
        return;
      }

      final rawData = event.snapshot.value;
      List<Map<String, dynamic>> loadedVendors = [];

      if (rawData is Map) {
        rawData.forEach((key, value) {
          if (value is Map) {
            loadedVendors.add(Map<String, dynamic>.from(value));
          }
        });
      }

      setState(() => vendors = loadedVendors);
    });
  }

  List<Map<String, dynamic>> get filteredVendors {
    return vendors.where((vendor) {
      final name = (vendor['name'] ?? '').toLowerCase();
      final category = (vendor['category'] ?? '');
      final menuItems = extractMenu(vendor['menu']).join(" ").toLowerCase();

      final matchesCategory =
          selectedCategory == "All" || category == selectedCategory;

      final matchesSearch = searchQuery.isEmpty ||
          name.contains(searchQuery) ||
          menuItems.contains(searchQuery);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: kPrimaryColor, width: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("UniEats"),
        backgroundColor:Color(0xFF402E1F),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👋 Greeting
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kHorizontalPadding,
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Hi 👋 Hungry today?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      "UNIMAS Campus",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kHorizontalPadding,
              vertical: 8,
            ),
            child: SizedBox(
              height: 50,
              child: TextField(
                onChanged: (value) {
                  setState(() => searchQuery = value.toLowerCase());
                },
                style: const TextStyle(fontSize: 14),
                decoration: _buildInputDecoration("Search vendor or food"),
              ),
            ),
          ),

          // 🏷 Category chips
          SizedBox(
            height: 50, // taller chip row
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              scrollDirection: Axis.horizontal,
              children: [
                categoryChip("All"),
                categoryChip("Breakfast & Lunch"),
                categoryChip("Beverages"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🤖 AI Recommended
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                print("AI Recommended clicked!");
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: kHorizontalPadding, vertical: 8),
                child: Row(
                  children: const [
                    Text(
                      "🤖 AI Recommended",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🏪 Vendor list with pull-to-refresh
          Expanded(
            child: vendors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.store_mall_directory,
                            size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          "No vendors available",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredVendors.length,
                      itemBuilder: (context, index) {
                        return vendorCard(filteredVendors[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: CustomerNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  // 🏷 Category Chip
  Widget categoryChip(String category) {
    final bool isSelected = selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5), // spacing between chips
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = category;
          });
        },
        child: Container(
          constraints: const BoxConstraints(minWidth: 6),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2), // size chip
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? kPrimaryColor : kPrimaryColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.brown,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.check,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 🏪 Vendor Card
  Widget vendorCard(Map<String, dynamic> vendor) {
    final menuItems = extractMenu(vendor['menu']);
    return Card(
      elevation: 3,
      color: const Color.fromARGB(255, 241, 238, 232),
      margin: const EdgeInsets.symmetric(
          horizontal: kHorizontalPadding, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: kSecondaryColor,
          backgroundImage: vendor['image'] != null && vendor['image']!.isNotEmpty
              ? AssetImage(vendor['image'])
              : null,
          child: vendor['image'] == null || vendor['image']!.isEmpty
              ? Text(
                  vendor['name'] != null ? vendor['name'][0] : '',
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        title: Text(vendor['name'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${vendor['category']} • ⭐ ${vendor['rating'] ?? ''}"),
            if (menuItems.isNotEmpty)
              Text(
                "Menu: ${menuItems.take(1).join(", ")}",
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VendorMenuPage(vendorName: vendor['name']),
            ),
          );
        },
      ),
    );
  }

  // 🍽 Extract menu
  List<String> extractMenu(dynamic menuData) {
    if (menuData == null) return [];
    List<String> items = [];

    if (menuData is Map) {
      menuData.forEach((key, value) {
        if (value is Map && value['name'] != null) {
          items.add(value['name']);
        }
      });
    }

    return items;
  }
}
