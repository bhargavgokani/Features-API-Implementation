import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:login_signup/wrapper.dart';
import '../../common widget/ReminderToggle.dart';
import '../../common widget/customButton.dart';
import '../../common widget/customTextField.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late bool _passwordVisible;

  signup() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: usernameController.text, password: passwordController.text);
      Get.offAll(Wrapper());
      Fluttertoast.showToast(
        msg: "Signup successful!",
        backgroundColor: Colors.lightGreen,
        textColor: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
          msg: "user already exist",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } else {
        // print("error message-----> $e");
        // print("error code--------> ${e.code}");
        Fluttertoast.showToast(
          msg: "An error occurred. Please try again.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  void _validateAndSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Proceed with sign-in logic
      signup();
    } else {
      // Handle validation failure (e.g., show a toast or error message)
      print("Validation failed");
    }
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  void changeText() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: SvgPicture.asset(
                    'assets/signup.svg',
                    height: 250,
                  ),
                ),
                // const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Register',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3F5769)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Please register to login.',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF3F5769),
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: usernameController,
                  hintText: 'Email',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "please enter email";
                    }
                    if (value.length < 3 || !value.contains("@")) {
                      return "enter valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: mobileController,
                  hintText: 'Mobile Number',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null) {
                      return 'please enter mobile no.';
                    }
                    if (value.length != 10) {
                      return "enter a valid 10-digit mobile number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock,
                    suffixIcon: _passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    isObscure: !_passwordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "please enter password";
                      }
                      if (value.length < 8) {
                        return "password must contains 8 character";
                      }
                      return null;
                    },
                    isVisible: changeText),

                // const SizedBox(height: 20),
                ReminderToggle(),
                // const SizedBox(height: 20),
                CustomButton(
                  text: 'Sign Up',
                  onPressed: _validateAndSubmit,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        " Sign In",
                        style: TextStyle(
                            color: Color(0xFF3F5769),
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
