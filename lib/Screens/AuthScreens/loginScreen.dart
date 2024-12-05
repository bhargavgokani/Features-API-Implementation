import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:login_signup/common%20widget/ReminderToggle.dart';
import '../../common widget/customTextField.dart';
import '../../common widget/customButton.dart';
import 'signupScreen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});
  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late bool _passwordVisible;
  String? errorMessage;

  signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: usernameController.text, password: passwordController.text);
      Fluttertoast.showToast(
        msg: "Login successful!",
        backgroundColor: Colors.lightGreen,
        textColor: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        Fluttertoast.showToast(
          msg: "invalid-credential",
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
    // catch (e) {
    //   setState(() {
    //     errorMessage = "User doesn't exist";
    //   });
    //   return "user not exist";
    // }
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

  void _validateAndSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Proceed with sign-in logic
      signIn();
    } else {
      // Handle validation failure (e.g., show a toast or error message)
      print("Validation failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 50,
                ),
                // Illustration
                Center(
                  child: SvgPicture.asset(
                    'assets/login.svg',
                    height: 250,
                    width: 200,
                  ),
                ),
                // const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Login',
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
                    'Please sign in to continue.',
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
                      return "please enter your email";
                    }
                    if (value.length < 3 || !value.contains("@")) {
                      return "invalid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "please enter password";
                      }
                      if (value.length < 8) {
                        return "password must contains 8 char.";
                      }
                      return null;
                    },
                    suffixIcon: _passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    isObscure: !_passwordVisible,
                    isVisible: changeText),
                ReminderToggle(),
                CustomButton(
                  text: 'Sign In',
                  onPressed: _validateAndSubmit,
                ),
                // const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterScreen()));
                      },
                      child: const Text(
                        " Sign Up",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
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
