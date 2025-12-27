import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kBackgroundColor = Color(0xFFF6F6F6);

class AiChatbotPage extends StatefulWidget {
  const AiChatbotPage({Key? key}) : super(key: key);

  @override
  State<AiChatbotPage> createState() => _AiChatbotPageState();
}

class _AiChatbotPageState extends State<AiChatbotPage> {
  final TextEditingController _controller = TextEditingController();

  final DatabaseReference vendorsRef = FirebaseDatabase.instance.ref().child(
    'vendors',
  );

  final List<Map<String, String>> messages = [
    {
      "role": "bot",
      "text":
          "Hi! I'm Yuni 👋\nI can help you with:\n• Breakfast & Lunch 🍽️\n• Beverages 🧋\n• Cheap food 💰\n\nUse the buttons below 👇",
    },
  ];

  // 기억 (memory)
  String? lastCategory;
  bool lastWasCheap = false;
  Set<String> alreadyRecommended = {};

  // ===============================
  // CATEGORY RECOMMENDATION (POPULAR)
  // ===============================
  Future<String> getCategoryRecommendation(
    String targetCategory, {
    bool getMore = false,
  }) async {
    final snapshot = await vendorsRef.get();
    if (!snapshot.exists) {
      return "Sorry, I couldn't access the menu right now 😅";
    }

    final vendors = Map<String, dynamic>.from(snapshot.value as Map);
    List<Map<String, dynamic>> items = [];

    vendors.forEach((_, vendorData) {
      if (vendorData is! Map) return;

      if (vendorData['category'] == targetCategory &&
          vendorData['menu'] is Map) {
        final menuMap = Map<String, dynamic>.from(vendorData['menu']);

        menuMap.forEach((_, menuData) {
          if (menuData is Map &&
              menuData['available'] == true &&
              menuData['orderCount'] != null) {
            final name = menuData['name'];
            if (getMore && alreadyRecommended.contains(name)) return;

            items.add({"name": name, "orderCount": menuData['orderCount']});
          }
        });
      }
    });

    if (items.isEmpty) {
      return "No more $targetCategory items to recommend 😊";
    }

    items.sort((a, b) => b['orderCount'].compareTo(a['orderCount']));

    final selected = items.take(3).toList();

    lastCategory = targetCategory;
    lastWasCheap = false;
    alreadyRecommended.addAll(selected.map((e) => e['name'].toString()));

    final names = selected.map((e) => e['name']).join(", ");

    return getMore
        ? "Here are some other $targetCategory options:\n$names ⭐"
        : "Recommended $targetCategory items:\n$names ⭐";
  }

  // ===============================
  // CHEAP FOOD / DRINKS
  // ===============================
  Future<String> getCheapRecommendation(
    String targetCategory, {
    bool getMore = false,
  }) async {
    final snapshot = await vendorsRef.get();
    if (!snapshot.exists) {
      return "Sorry, I couldn't access the menu right now 😅";
    }

    final vendors = Map<String, dynamic>.from(snapshot.value as Map);
    List<Map<String, dynamic>> items = [];

    vendors.forEach((_, vendorData) {
      if (vendorData is! Map) return;

      if (vendorData['category'] == targetCategory &&
          vendorData['menu'] is Map) {
        final menuMap = Map<String, dynamic>.from(vendorData['menu']);

        menuMap.forEach((_, menuData) {
          if (menuData is Map &&
              menuData['available'] == true &&
              menuData['price'] != null) {
            final name = menuData['name'];
            if (getMore && alreadyRecommended.contains(name)) return;

            items.add({"name": name, "price": menuData['price']});
          }
        });
      }
    });

    if (items.isEmpty) {
      return "No cheap $targetCategory items found 💰";
    }

    // Sort by cheapest
    items.sort((a, b) => a['price'].compareTo(b['price']));

    final selected = items.take(3).toList();

    lastCategory = targetCategory;
    lastWasCheap = true;
    alreadyRecommended.addAll(selected.map((e) => e['name'].toString()));

    final names = selected
        .map((e) => "${e['name']} (RM${e['price']})")
        .join(", ");

    return getMore
        ? "Other cheap $targetCategory options:\n$names 💰"
        : "Cheap $targetCategory recommendations:\n$names 💰";
  }

  // ===============================
  // SEND MESSAGE
  // ===============================
  void processMessage(String text) async {
    setState(() {
      messages.add({"role": "user", "text": text});
    });

    final msg = text.toLowerCase();
    String reply = "I'm sorry, I didn't understand that. Please try again.";

    // MORE / OTHER
    if ((msg.contains("more") || msg.contains("other")) &&
        lastCategory != null) {
      reply = lastWasCheap
          ? await getCheapRecommendation(lastCategory!, getMore: true)
          : await getCategoryRecommendation(lastCategory!, getMore: true);
    }
    // CHEAP
    else if (msg.contains("cheap")) {
      alreadyRecommended.clear();
      reply = (msg.contains("drink") || msg.contains("beverage"))
          ? await getCheapRecommendation("Beverages")
          : await getCheapRecommendation("Breakfast & Lunch");
    }
    // BEVERAGES
    else if (msg.contains("beverage") || msg.contains("drink")) {
      alreadyRecommended.clear();
      reply = await getCategoryRecommendation("Beverages");
    }
    // FOOD
    else {
      alreadyRecommended.clear();
      reply = await getCategoryRecommendation("Breakfast & Lunch");
    }

    setState(() {
      messages.add({"role": "bot", "text": reply});
    });
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Ask Yuni"),
        backgroundColor: kPrimaryColor,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (_, index) {
                final m = messages[index];
                final isUser = m['role'] == 'user';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? kPrimaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      m['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // QUICK REPLIES
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                quickButton("🍽️ Food", "food"),
                quickButton("🧋 Drinks", "beverages"),
                quickButton("💰 Cheap Food", "cheap food"),
                quickButton("💰 Cheap Drinks", "cheap drinks"),
                quickButton("➕ More", "more"),
              ],
            ),
          ),

          // Input
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        processMessage(v.trim());
                        _controller.clear();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Ask Yuni...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: kPrimaryColor),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      processMessage(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Quick reply button widget
  Widget quickButton(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: kPrimaryColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () => processMessage(value),
        child: Text(label),
      ),
    );
  }
}
