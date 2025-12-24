import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kBackgroundColor = Colors.white;

class AiChatbotPage extends StatefulWidget {
  @override
  _AiChatbotPageState createState() => _AiChatbotPageState();
}

class _AiChatbotPageState extends State<AiChatbotPage> {
  // 🔹 Read from existing vendors database
  final DatabaseReference vendorsRef = FirebaseDatabase.instance.ref().child(
    'vendors',
  );

  final TextEditingController _controller = TextEditingController();

  // Chat message list
  final List<Map<String, String>> messages = [
    {
      "role": "bot",
      "text":
          "Hi! I'm Yuni 👋 I can help you choose food.\nTry asking:\n• Recommend food\n• Popular food\n• Cheap meals",
    },
  ];

  // ===============================
  // DATABASE-BASED POPULAR FOOD LOGIC
  // ===============================
  Future<String> getPopularFoodsReply() async {
    final snapshot = await vendorsRef.get();

    if (!snapshot.exists) {
      return "I couldn't find popular foods right now 😅";
    }

    final vendors = Map<String, dynamic>.from(snapshot.value as Map);
    List<Map<String, dynamic>> allMenuItems = [];

    vendors.forEach((vendorId, vendorData) {
      if (vendorData['menu'] != null) {
        final menuMap = Map<String, dynamic>.from(vendorData['menu']);

        menuMap.forEach((menuId, menuData) {
          allMenuItems.add({
            "name": menuData['name'],
            "orderCount": menuData['orderCount'] ?? 0,
          });
        });
      }
    });

    if (allMenuItems.isEmpty) {
      return "No menu data available at the moment 🍽️";
    }

    // Sort by orderCount (descending)
    allMenuItems.sort((a, b) => b['orderCount'].compareTo(a['orderCount']));

    // Take top 3
    final topFoods = allMenuItems.take(3).map((f) => f['name']).join(", ");

    return "Popular foods right now are $topFoods ⭐";
  }

  // ===============================
  // LOGIC-BASED REPLIES (NON-DB)
  // ===============================
  String getBotReply(String userMessage) {
    final msg = userMessage.toLowerCase();

    if (msg.contains("hi") || msg.contains("hello")) {
      return "Hi! I'm Yuni 👋 What would you like to eat today?";
    }

    if (msg.contains("cheap") || msg.contains("budget")) {
      return "Looking for budget meals? Roti canai and simple rice meals are great choices 💰";
    }

    if (msg.contains("lunch")) {
      return "For lunch, rice meals are the most popular option 🍚";
    }

    if (msg.contains("breakfast")) {
      return "For breakfast, light meals like roti and drinks are great ☕🥪";
    }

    if (msg.contains("drink") || msg.contains("beverage")) {
      return "Refreshing drinks like iced tea and coffee are available 🧋";
    }

    if (msg.contains("help")) {
      return "I can recommend popular food, suggest budget meals, or help you decide 😊";
    }

    return "Sorry, I didn't quite understand 😅 Try asking about popular or cheap food 🍽️";
  }

  // ===============================
  // SEND MESSAGE (ASYNC)
  // ===============================
  void sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
    });

    String reply;
    final msg = text.toLowerCase();

    if (msg.contains("popular") || msg.contains("recommend")) {
      reply = await getPopularFoodsReply();
    } else {
      reply = getBotReply(text);
    }

    setState(() {
      messages.add({"role": "bot", "text": reply});
    });

    _controller.clear();
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
          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message["role"] == "user";

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
                      color: isUser ? kPrimaryColor : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message["text"]!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input area
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Ask Yuni for food ideas...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.send, color: kPrimaryColor),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
