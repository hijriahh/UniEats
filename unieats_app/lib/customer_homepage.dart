import 'package:flutter/material.dart';
import 'vendor_menu_page.dart';
import 'customer_navigation_bar.dart';
import 'package:firebase_database/firebase_database.dart';

// Choose a theme color that blends: soft brown/orange
const Color kPrimaryColor = Color(0xFFA07F60); // warm brown
const Color kSecondaryColor = Color(0xFFF0A66D); // light orange

class CustomerHomepage extends StatefulWidget {
  @override
  _CustomerHomepageState createState() => _CustomerHomepageState();
}

class _CustomerHomepageState extends State<CustomerHomepage> {
  int _currentIndex = 0;
  String selectedCategory = "All";
  final database = FirebaseDatabase.instance.ref();

  List<Map<String, dynamic>> vendors = [];

  @override
  void initState() {
    super.initState();
    fetchVendors();
  }

  void fetchVendors() async {
    final snapshot = await database.child('vendors').get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      List<Map<String, dynamic>> loadedVendors = [];

      data.forEach((key, value) {
        final vendor = Map<String, dynamic>.from(value);
        vendor['id'] = key;
        loadedVendors.add(vendor);
      });

      setState(() {
        vendors = loadedVendors;
      });
    } else {
      print("No vendors found");
    }
  }

  List<Map<String, dynamic>> get filteredVendors {
    if (selectedCategory == "All") return vendors;
    return vendors.where((v) => v['category'] == selectedCategory).toList();
  }

  // InputDecoration for search bar
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
      appBar: AppBar(
        title: const Text("UniEats"),
        backgroundColor: kPrimaryColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: _buildInputDecoration('Search vendor or food'),
              onChanged: (value) {
                setState(() {
                  // Optional: implement search filter later
                });
              },
            ),
          ),

          // Category chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                categoryChip("All"),
                categoryChip("Most Popular"),
                categoryChip("Breakfast & Lunch"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // AI Recommendations (hardcoded top 3)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: const Text(
              'Recommended for you',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: vendors.take(3).map((v) {
                return recommendationCard(v['name']);
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // Vendor List
          Expanded(
            child: ListView.builder(
              itemCount: filteredVendors.length,
              itemBuilder: (context, index) {
                final vendor = filteredVendors[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(vendor['name']),
                    subtitle: Text('${vendor['category']} • ⭐ ${vendor['rating']}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VendorMenuPage(
                            vendorName: vendor['name'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomerNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // Custom styled category chip with tick
  Widget categoryChip(String category) {
    bool isSelected = category == selectedCategory;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = category;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? kPrimaryColor : Colors.brown,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.brown,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(left: 6.0),
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

  // Recommendation card
  Widget recommendationCard(String name) {
    return Container(
      width: 150,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSecondaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
