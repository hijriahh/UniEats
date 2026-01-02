import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'auth_service.dart';
import 'customer_homepage.dart';
import 'vendor_homepage.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';

const Color kPrimaryColor = Color(0xFFA07F60);
const Color kBackgroundColor = Colors.white;
const Color kTextColor = Color(0xFF333333);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _getVendorByUid(String uid) async {
    final snapshot = await FirebaseDatabase.instance.ref('vendors').get();
    if (!snapshot.exists) return null;
    final vendors = Map<String, dynamic>.from(snapshot.value as Map);
    for (final entry in vendors.entries) {
      final vendorData = Map<String, dynamic>.from(entry.value);
      if (vendorData['uid'] == uid) return {'vendorId': entry.key, 'vendorData': vendorData};
    }
    return null;
  }

  void _showAlert(String message) {
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

  void _loginUser() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showAlert('Please enter both email and password.');
      return;
    }

    setState(() => _isLoading = true);
    String res = await _authService.loginUser(email, password);
    setState(() => _isLoading = false);

    if (res == 'success') {
      final uid = _authService.getCurrentUser()!.uid;
      final vendorResult = await _getVendorByUid(uid);
      if (vendorResult != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => VendorHomepage(vendorId: vendorResult['vendorId'])),
        );
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerHomepage()));
      }
    } else {
      _showAlert(res);
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------------- TOP IMAGE WITH CURVE ----------------
            Stack(
              children: [
                Container(
                  height: 380,
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/landingpage.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipPath(
                      clipper: BottomCurveClipper(),
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -3))],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kTextColor),
                  ),
                  const SizedBox(height: 15),

                  // Email
                  TextField(controller: _emailController, decoration: _buildInputDecoration('Email')),
                  const SizedBox(height: 15),

                  // Password
                  TextField(controller: _passwordController, obscureText: true, decoration: _buildInputDecoration('Password')),
                  const SizedBox(height: 10),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                      child: const Text('Forgot Password?', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _loginUser,
                            child: const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                  const SizedBox(height: 15),

                  // Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: const Text("Sign Up", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- CURVE CLIPPER --------------------
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.9, size.width * 0.7, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.4, size.width, size.height * 0.8);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
