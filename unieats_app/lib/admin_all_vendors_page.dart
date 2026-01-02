import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kBackgroundColor = Color(0xFFF6F6F6);

class AdminAllVendorsPage extends StatefulWidget {
  const AdminAllVendorsPage({Key? key}) : super(key: key);

  @override
  State<AdminAllVendorsPage> createState() => _AdminAllVendorsPageState();
}

class _AdminAllVendorsPageState extends State<AdminAllVendorsPage> {
  List<Map<String, dynamic>> vendors = [];

  @override
  void initState() {
    super.initState();
    _listenVendors();
  }

  void _listenVendors() {
    FirebaseDatabase.instance.ref('vendors').onValue.listen((event) {
      if (!event.snapshot.exists) {
        setState(() => vendors = []);
        return;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final List<Map<String, dynamic>> loaded = [];

      data.forEach((vendorId, vendorData) {
        if (vendorData is Map) {
          loaded.add({
            'id': vendorId,
            'name': vendorData['name'] ?? 'Unnamed Vendor',
            'email': vendorData['email'] ?? '',
            'approved': vendorData['approved'] == true,
          });
        }
      });

      setState(() => vendors = loaded);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: const Text(
          "All Vendors",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: vendors.isEmpty
          ? const Center(child: Text("No vendors found"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vendors.length,
              itemBuilder: (context, index) {
                final vendor = vendors[index];
                final approved = vendor['approved'] == true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (vendor['email'].isNotEmpty)
                        Text(
                          vendor['email'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            approved ? Icons.check_circle : Icons.pending,
                            color: approved ? Colors.green : Colors.orange,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            approved ? "Approved" : "Pending Approval",
                            style: TextStyle(
                              color: approved ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
