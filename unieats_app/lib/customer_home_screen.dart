// customer_home_screen.dart
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Logout user
              await _authService.logoutUser();
              // Navigate back to login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Text(
          'Welcome, ${_authService.getCurrentUser()?.email ?? 'User'}!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
