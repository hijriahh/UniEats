import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'register_screen.dart';
import 'customer_home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _loginUser() async {
    setState(() => _isLoading = true);

    String res = await AuthService().loginUser(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (res == 'success') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CustomerHomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
          SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          SizedBox(height: 20),
          _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(onPressed: _loginUser, child: Text('Login')),
          SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen())),
            child: Text('Don’t have an account? Register'),
          ),
        ]),
      ),
    );
  }
}
