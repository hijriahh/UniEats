import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kBackgroundColor = Color(0xFFF6F6F6);

class AdminVendorApprovalPage extends StatefulWidget {
  const AdminVendorApprovalPage({Key? key}) : super(key: key);

  @override
  State<AdminVendorApprovalPage> createState() =>
      _AdminVendorApprovalPageState();
}

class _AdminVendorApprovalPageState extends State<AdminVendorApprovalPage> {
  List<Map<String, dynamic>> pendingVendors = [];

  @override
  void initState() {
    super.initState();
    _listenPendingVendors();
  }

  void _listenPendingVendors() {
    FirebaseDatabase.instance.ref('vendors').onValue.listen((event) {
      if (!event.snapshot.exists) {
        setState(() => pendingVendors = []);
        return;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final List<Map<String, dynamic>> loaded = [];

      data.forEach((vendorId, vendorData) {
        if (vendorData is Map &&
            (vendorData['approved'] == false ||
                vendorData['approved'] == null)) {
          loaded.add({
            'vendorId': vendorId,
            'name': vendorData['name'] ?? 'Unnamed Vendor',
            'email': vendorData['email'] ?? '',
          });
        }
      });

      setState(() => pendingVendors = loaded);
    });
  }

  void _approveVendor(String vendorId) {
    FirebaseDatabase.instance.ref('vendors/$vendorId').update({
      'approved': true,
    });
  }

  void _rejectVendor(String vendorId) {
    FirebaseDatabase.instance.ref('vendors/$vendorId').remove();
  }

  @override
  Widget build(BuildContext context) {
    if (pendingVendors.isEmpty) {
      return const Center(child: Text("No pending vendor approvals"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingVendors.length,
      itemBuilder: (context, index) {
        final vendor = pendingVendors[index];

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
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (vendor['email'].isNotEmpty)
                Text(
                  vendor['email'],
                  style: const TextStyle(color: Colors.grey),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _approveVendor(vendor['vendorId']),
                      child: const Text("Approve"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _rejectVendor(vendor['vendorId']),
                      child: const Text("Reject"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
