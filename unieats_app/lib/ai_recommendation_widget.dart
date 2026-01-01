import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'vendor_menu_page.dart';

const Color kPrimaryColor = Color(0xFFB7916E);

class AiRecommendationWidget extends StatefulWidget {
  final String selectedCategory;

  const AiRecommendationWidget({Key? key, required this.selectedCategory})
    : super(key: key);

  @override
  State<AiRecommendationWidget> createState() => _AiRecommendationWidgetState();
}

class _AiRecommendationWidgetState extends State<AiRecommendationWidget> {
  final DatabaseReference vendorsRef = FirebaseDatabase.instance.ref().child(
    'vendors',
  );

  List<Map<String, dynamic>> recommendations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  @override
  void didUpdateWidget(covariant AiRecommendationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      fetchRecommendations();
    }
  }

  Future<void> fetchRecommendations() async {
    setState(() => isLoading = true);

    final snapshot = await vendorsRef.get();
    if (!snapshot.exists) {
      setState(() => isLoading = false);
      return;
    }

    final vendors = Map<String, dynamic>.from(snapshot.value as Map);
    List<Map<String, dynamic>> items = [];

    vendors.forEach((vendorKey, vendorData) {
      if (vendorData is! Map) return;

      if (widget.selectedCategory != "All" &&
          vendorData['category'] != widget.selectedCategory) {
        return;
      }

      if (vendorData['menu'] is Map) {
        final menuMap = Map<String, dynamic>.from(vendorData['menu']);

        menuMap.forEach((_, menuData) {
          if (menuData is Map &&
              menuData['available'] == true &&
              menuData['orderCount'] != null) {
            items.add({
              "menuName": menuData['name'],
              "menuImage": menuData['menuimage'],
              "orderCount": menuData['orderCount'],
              "vendorData": vendorData,
              "vendorKey": vendorKey,
            });
          }
        });
      }
    });

    items.sort((a, b) => b['orderCount'].compareTo(a['orderCount']));

    setState(() {
      recommendations = items.take(5).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: const [
              Icon(Icons.auto_awesome, color: kPrimaryColor, size: 18),
              SizedBox(width: 6),
              Text(
                "AI Recommendations",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final item = recommendations[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VendorMenuPage(
                        vendorData: Map<String, dynamic>.from(
                          item['vendorData'],
                        ),
                        vendorKey: item['vendorKey'],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child:
                            item['menuImage'] != null &&
                                item['menuImage'].toString().isNotEmpty
                            ? Image.asset(
                                item['menuImage'],
                                height: 90,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 90,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.fastfood),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          item['menuName'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
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
    );
  }
}
