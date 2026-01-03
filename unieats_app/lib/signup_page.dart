import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart';

const Color kPrimaryColor = Color(0xFFA07F60);
const Color kBackgroundColor = Colors.white;
const Color kTextColor = Color(0xFF333333);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _role = 'user'; // default role
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _registerUser() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showDialog('Please fill in all fields.');
      return;
    }

    if (password != confirmPassword) {
      _showDialog('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Create Firebase Auth user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name);

        // 2️⃣ Save user info to Realtime Database
        final ref = FirebaseDatabase.instance.ref().child('${_role}s/${user.uid}');
        await ref.set({
          'name': name,
          'email': email,
          'role': _role,
          'approved': _role == 'vendor' ? false : true, // vendor needs admin approval
        });

        if (_role == 'vendor') {
          // 3️⃣ Show vendor approval popup
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Registration Complete'),
              content: const Text(
                'Your vendor account has been registered. Please wait for admin approval before you can log in.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Normal user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      _showDialog(e.message ?? 'An error occurred');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: kPrimaryColor, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------------- Top Back Button ----------------
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            // ---------------- Form Fields ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Register Account',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kTextColor),
                  ),
                  const SizedBox(height: 15),

                  TextField(controller: _nameController, decoration: _buildInputDecoration('Name')),
                  const SizedBox(height: 15),

                  TextField(controller: _emailController, decoration: _buildInputDecoration('Email')),
                  const SizedBox(height: 15),

                  TextField(controller: _passwordController, obscureText: true, decoration: _buildInputDecoration('Password')),
                  const SizedBox(height: 15),

                  TextField(controller: _confirmPasswordController, obscureText: true, decoration: _buildInputDecoration('Confirm Password')),
                  const SizedBox(height: 20),

                  // Role Selection
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'user',
                          groupValue: _role,
                          onChanged: (val) => setState(() => _role = val!),
                          title: const Text('Customer'),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'vendor',
                          groupValue: _role,
                          onChanged: (val) => setState(() => _role = val!),
                          title: const Text('Vendor'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: _registerUser,
                            child: const Text('Register', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                        child: const Text("Login", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
