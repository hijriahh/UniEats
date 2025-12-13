import 'package:flutter/material.dart';

// --- MOCK CLASSES (REPLACE WITH YOUR ACTUAL IMPORTS IN YOUR PROJECT) ---
// These mocks are needed to make the single file runnable in Canvas.

class CustomerHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Scaffold(
    appBar: AppBar(title: Text('Customer Home')),
    body: Center(child: Text('Login Successful!')),
  );
}

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Scaffold(
    appBar: AppBar(title: Text('Register')),
    body: Center(child: Text('Register Screen Placeholder')),
  );
}

class AuthService {
  // Mock login function for demonstration
  Future<String> loginUser(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    if (email.isEmpty || password.isEmpty) {
      return 'Email and password cannot be empty.';
    }
    if (email.trim() == 'test@food.com' && password.trim() == 'password123') {
      return 'success';
    } else {
      return 'Invalid credentials. Hint: test@food.com / password123';
    }
  }
}
// --------------------------------------------------------------------------

// --- Color and Style Constants ---
const Color kPrimaryColor = Color(0xFFA07F60);
const Color kBackgroundColor = Color(0xFFFBF0E9);
const Color kTextColor = Color(0xFF333333);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food App Sign In',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: kTextColor, fontFamily: 'Inter'),
          bodyMedium: TextStyle(color: kTextColor, fontFamily: 'Inter'),
          headlineMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: kTextColor,
            fontFamily: 'Inter',
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: Colors.black26),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: Colors.black26),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
          ),
          hintStyle: TextStyle(color: Colors.black38),
          contentPadding: EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 20.0,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
            elevation: 4,
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

// --------------------------------------------------------------------------
// --- USER'S LOGIC INTEGRATED INTO NEW UI STRUCTURE ---
// --------------------------------------------------------------------------

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Preserve user's controllers and state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Preserve user's login method logic
  void _loginUser() async {
    setState(() => _isLoading = true);

    // Using user's logic structure with the mock AuthService
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
      // Use a custom SnackBar to match the aesthetic better than default text
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // --- 1. Header Image and Curved Shape ---
            Stack(
              children: <Widget>[
                Container(
                  height: 300,
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://placehold.co/800x600/A07F60/FBF0E9.jpg?text=Your+Food+Image',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.only(top: 40, left: 24, right: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '9:41',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipPath(
                      clipper: BottomCurveClipper(),
                      child: Container(
                        height: 100,
                        color: kBackgroundColor,
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- 2. Sign In Form and Content ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 30),

                  // Email Field (Used user's controller)
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      labelText: 'Email', // Added label for clarity
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // Password Field (Used user's controller)
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      labelText: 'Password',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Placeholder for forgot password logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Forgot Password clicked'),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password',
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Log In Button (Used user's _isLoading state and _loginUser method)
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: kPrimaryColor,
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _loginUser,
                          child: const Text('Log In'),
                        ),
                  const SizedBox(height: 20),

                  // 'or' Separator
                  const Center(
                    child: Text('or', style: TextStyle(color: Colors.black54)),
                  ),
                  const SizedBox(height: 20),

                  // Continue with Google Button (Placeholder action)
                  _SocialButton(
                    text: 'Continue with Google',
                    iconData: Icons.g_mobiledata,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 15),

                  // Continue with Apple Button (Placeholder action)
                  _SocialButton(
                    text: 'Continue with Apple',
                    iconData: Icons.apple,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 40),

                  // Don't have an Account? Register (Used user's navigation logic)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Don't have an Account? ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterScreen()),
                        ),
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Custom Widget for Social Buttons (Reused from previous UI) ---
class _SocialButton extends StatelessWidget {
  final String text;
  final IconData? iconData;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.text,
    this.iconData,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.black26, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(iconData ?? Icons.person, color: kTextColor, size: 24),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  color: kTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Custom Clipper for the Curved Bottom Header (Reused from previous UI) ---
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.4);

    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.9,
      size.width * 0.7,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.4,
      size.width,
      size.height * 0.8,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
