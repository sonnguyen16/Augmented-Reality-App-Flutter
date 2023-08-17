import 'package:flutter/material.dart';
import 'login.dart';
import '../constant/color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WelcomeScreen(), // Màn hình chờ (nếu cần)
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _animationController1;

  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _slideAnimation1;
  late Animation<Offset> _slideAnimationForGhe;
  late Animation<Offset> _slideAnimationForSofa;
  late Animation<Offset> _slideAnimationForGhe1;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _animationController1 = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation1 = Tween<Offset>(
      begin: const Offset(15, 0),
      end: const Offset(0, 0),
    ).animate(_animationController1);

    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -50), end: Offset.zero)
            .animate(_animationController);
    _slideAnimationForGhe =
        Tween<Offset>(begin: const Offset(40, 0), end: Offset.zero)
            .animate(_animationController);
    _slideAnimationForSofa =
        Tween<Offset>(begin: const Offset(0, 50), end: Offset.zero)
            .animate(_animationController);
    _slideAnimationForGhe1 = Tween<Offset>(
      begin: const Offset(-50, 0),
      end: Offset.zero,
    ).animate(_animationController);

    _animationController.forward();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController1.forward();
        _animationController1.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/bg_welcome.jpg'),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.translate(
                    offset: _slideAnimation.value,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 50),
                        Text(
                          'Welcome to',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: Image(
                                image: AssetImage(
                                    'assets/images/lamp_welcome.png'),
                                width: 240,
                              ),
                            ),
                            Positioned(
                              child: Text(
                                'AR Furniture',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 45,
                              child: Text(
                                'Try furniture in your home',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Transform.translate(
                        offset: _slideAnimationForGhe.value,
                        child: const Image(
                          image: AssetImage('assets/images/ghe.png'),
                          width: 100,
                        ),
                      ),
                      Positioned(
                        child: Transform.translate(
                          offset: _slideAnimationForSofa.value,
                          child: const Padding(
                            padding: EdgeInsets.only(top: 120),
                            child: Image(
                              image: AssetImage('assets/images/sofa.png'),
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        child: Transform.translate(
                          offset: _slideAnimationForGhe1.value,
                          child: const Padding(
                            padding: EdgeInsets.only(top: 220, right: 210),
                            child: Image(
                              image: AssetImage('assets/images/ghe1.png'),
                              width: 100,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          child: AnimatedBuilder(
                              animation: _animationController1,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: _slideAnimationForGhe.value,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 340, right: 20),
                                    child: Transform.translate(
                                        offset: _slideAnimation1.value,
                                        child: FloatingActionButton(
                                          onPressed:  goToLogin,
                                          backgroundColor: primaryColor,
                                          child: const Icon(
                                            Icons.arrow_forward_outlined,
                                            color: Colors.black,
                                          ),
                                        )),
                                  ),
                                );
                              })),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      )
    );
  }

  void goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
