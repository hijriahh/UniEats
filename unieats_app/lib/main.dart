import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'customer_homepage.dart'; // import the home screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vendor App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CustomerHomepage(),
    );
  }
}
