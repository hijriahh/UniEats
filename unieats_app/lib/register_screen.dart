import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  void _registerUser() async {
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);
    String res = await AuthService().registerUser(_emailController.text.trim(), _passwordController.text.trim());
    setState(() => _isLoading = false);

    if (res == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration successful!')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
          SizedBox(height: 12),
          TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
          SizedBox(height: 12),
          TextField(controller: _confirmPasswordController, decoration: InputDecoration(labelText: 'Confirm Password'), obscureText: true),
          SizedBox(height: 20),
          _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(onPressed: _registerUser, child: Text('Register')),
          SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen())),
            child: Text('Already have an account? Login'),
          ),
        ]),
      ),
    );
  }
}
