import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class VendorMenuPage extends StatefulWidget {
  final String vendorName;

  const VendorMenuPage({Key? key, required this.vendorName}) : super(key: key);

  @override
  _VendorMenuPageState createState() => _VendorMenuPageState();
}

class _VendorMenuPageState extends State<VendorMenuPage> {
  final database = FirebaseDatabase.instance.ref();
  Map<String, dynamic> menuItems = {};

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  void fetchMenu() async {
    // Query vendor by name
    final snapshot = await database
        .child('vendors')
        .orderByChild('name')
        .equalTo(widget.vendorName)
        .get();

    if (snapshot.exists) {
      final vendorData = Map<String, dynamic>.from(snapshot.value as Map);
      final vendorKey = vendorData.keys.first;
      final menu = vendorData[vendorKey]['menu'] as Map<dynamic, dynamic>;

      setState(() {
        menuItems = Map<String, dynamic>.from(menu);
      });
    } else {
      print('Vendor not found!');
    }
  }

  void addToCart(String itemName, double price) {
    // For demo, we just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$itemName added to cart')),
    );

    // Later: integrate with CartPage / Firebase
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vendorName),
      ),
      body: menuItems.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final key = menuItems.keys.elementAt(index);
                final item = Map<String, dynamic>.from(menuItems[key]);

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(item['name']),
                    subtitle: Text('RM ${item['price'].toStringAsFixed(2)}'),
                    trailing: item['available']
                        ? ElevatedButton(
                            onPressed: () {
                              addToCart(item['name'], item['price']);
                            },
                            child: Text('Add'),
                          )
                        : Text(
                            'Not available',
                            style: TextStyle(color: Colors.red),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
