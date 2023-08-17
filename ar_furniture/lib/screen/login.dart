import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'navigation.dart';
import '../constant/color.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _slideAnimation1;
  bool _isLoading = false;
  String stateLogin = '';
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -50), end: Offset.zero)
            .animate(_animationController);
    _slideAnimation1 =
        Tween<Offset>(begin: const Offset(0, 100), end: Offset.zero)
            .animate(_animationController);

    _animationController.forward();
  }

  // Function verifyPhoneNumber
  Future<void> verifyPhoneNumber(BuildContext context) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String phoneNumber = '+84${_phoneNumberController.text.trim()}';
   
    await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Xác thực tự động khi số điện thoại đã được xác định
          await auth.signInWithCredential(credential);
          // ignore: use_build_context_synchronously
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
            stateLogin = 'Phone number is incorrect';
          });
        },
        codeSent: (String verificationId, int? resendToken) async{
          setState(() {
            _isLoading = false;
          });
          // Lưu verificationId và chuyển đến màn hình xác nhận mã
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                  verificationId: verificationId, phoneNumber: phoneNumber),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Xử lý khi thời gian chờ của mã xác nhận quá lâu
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Code Retrieval Timeout'),
                content: const Text('Please try again.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  )
                ],
              );
            },
          );
        });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
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
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.translate(
                      offset: _slideAnimation.value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 50),
                          const Text(
                            'Login to',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const Stack(
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
                                  'Login with your phone number',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 70),
                          Transform.translate(
                              offset: _slideAnimation1.value,
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _phoneNumberController,
                                    decoration: InputDecoration(
                                      hintText: 'Phone Number',
                                      hintStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: inputColor,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            const BorderSide(color: inputColor),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(stateLogin,
                                      style:
                                          const TextStyle(color: Colors.red)),
                                  const SizedBox(height: 5),
                                  ElevatedButton(
                                    onPressed: () => {
                                      setState(() {
                                        _isLoading = true;
                                        stateLogin = '';
                                      }),
                                      // Future.delayed(const Duration(seconds: 3),
                                      //     () {
                                      //   setState(() {
                                      //     _isLoading = false;
                                      //   });
                                      //   Navigator.of(context).push(
                                      //     MaterialPageRoute(
                                      //       builder: (context) => const OTPScreen(),
                                      //     ),
                                      //   );
                                      // })
                                      verifyPhoneNumber(context)
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                    ),
                                    child: _isLoading == false
                                        ? const Text(
                                            'Get OTP code',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          )
                                        : const CircularProgressIndicator(
                                            color: Colors.black),
                                  ),
                                  const SizedBox(height: 30),
                                  const Text(
                                    'Or Login with',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 30),
                                  const Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image(image: AssetImage('assets/images/google.png'), width: 37, height: 37,),
                                        SizedBox(width: 30),
                                        Icon(
                                          Icons.facebook,
                                          size: 45,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 30),
                                        Icon(
                                          Icons.apple,
                                          size: 48,
                                          color: Colors.black,
                                        ),
                                      ]),
                                ],
                              ))
                        ],
                      ),
                    ),
                  );
                },
              )),
        ));
  }
}

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPScreen({super.key, required this.verificationId, required this.phoneNumber});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  bool _isLoading = false;
  final TextEditingController _smsCodeController = TextEditingController();
  String stateLogin = '';

  Future<void> signInWithPhoneNumber(String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() {
        _isLoading = false;
        stateLogin = '';
      });
      // ignore: use_build_context_synchronously
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        stateLogin = 'OTP code is incorrect';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Enter your OTP code',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'We sent otp code to your phone number',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 50),
                TextField(
                  controller: _smsCodeController,
                  decoration: InputDecoration(
                    hintText: 'OTP code',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFFB8B8B8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFB8B8B8)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(stateLogin, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 5),
                ElevatedButton(
                    onPressed: () => {
                          setState(() {
                            _isLoading = true;
                            stateLogin = '';
                          }),
                          signInWithPhoneNumber(_smsCodeController.text.trim())
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEC248),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading == false
                        ? const Text(
                            'Login',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          )
                        : const CircularProgressIndicator(
                            color: Colors.black,
                          )),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => {},
                  child: const Text(
                    'Did\'nt received? Resend OTP code',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
