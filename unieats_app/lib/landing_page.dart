import 'package:flutter/material.dart';
import 'login_page.dart';

const Color kPrimaryColor = Color(0xFFA07F60);
const Color kBackgroundColor = Color.fromARGB(255, 255, 255, 255);
const Color kTextColor = Color(0xFF333333);

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // -------------------- HEADER IMAGE --------------------
            Stack(
              children: [
                Container(
                  height: 380, // 👈 IMAGE LOWER (changed only height)
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/landingpage.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipPath(
                      clipper: BottomCurveClipper(), // SAME CURVE
                      child: Container(
                        height: 100, // 👈 SAME AS BEFORE
                        color: kBackgroundColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60), // 👈 PUSH CONTENT LOWER

            // -------------------- CONTENT --------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const Text(
                    'Welcome to UniEats',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Experience easy access and secure services with our application.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // -------------------- GET STARTED BUTTON --------------------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- CURVE CLIPPER (UNCHANGED) --------------------
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
