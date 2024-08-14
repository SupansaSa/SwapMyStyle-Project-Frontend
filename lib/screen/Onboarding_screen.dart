import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:myapp/features/authentication/signIn/sign_in_page.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Container(
        color: Colors.white,
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              children: [
                buildPage(
                  title: "Welcome to Swap My Style",
                  description: "Discover and exchange quality second-hand clothes with our community.",
                  image: "assets/image/sammy-line-shopping.gif",
                ),
                buildPage(
                  title: "How It Works",
                  description: "Learn to post, exchange, and manage clothes easily.",
                  image: "assets/image/sammy-line-searching.gif",
                ),
                buildPage(
                  title: "Shipping & Receiving",
                  description: "Learn how to ship and receive items easily and securely.",
                  image: "assets/image/sammy-line-delivery.gif",
                ),
              ],
            ),
            Positioned(
              top: 40,
              right: 10,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Skip', style: TextStyle(color: Colors.black, fontSize: 16)),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: SmoothPageIndicator(
                          controller: _controller,
                          count: 3,
                          effect: const WormEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: IconButton(
                          onPressed: () {
                            if (_controller.page!.toInt() == 2) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
                            } else {
                              _controller.nextPage(
                                duration: Duration(milliseconds: 250),
                                curve: Curves.easeIn,
                              );
                            }
                          },
                          icon: Icon(Icons.arrow_forward, size: 30),
                        ),
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

  Widget buildPage({required String title, required String description, required String image}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: 350),
        SizedBox(height: 10),
        Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
