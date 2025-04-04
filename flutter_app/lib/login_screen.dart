import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Components/custom_inputfield.dart';
import 'Components/login_screen/header.dart';
import 'Components/login_screen/service_login_buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String emailAddress = '';
  String password = '';

  void handleLogin() async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        try {
          final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailAddress,
            password: password,
          );
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            print('No user found for that email.');
          } else if (e.code == 'wrong-password') {
            print('Wrong password provided for that user.');
          }
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _updateEmail(String value) {
    setState(() {
      emailAddress = value;
    });
  }

  void _updatePassword(String value) {
    setState(() {
      password = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
            color: Colors.blue,
            child: Center(
                child: Column(children: [
              Header(),
              Expanded(
                  flex: 2,
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 50, horizontal: 25),
                      color: Colors.white,
                      child: Column(
                        children: [
                          CustomInputField(
                            title: "Email",
                            onChanged: _updateEmail,
                          ),
                          SizedBox(height: 30),
                          CustomInputField(
                              title: "Password",
                              onChanged: _updatePassword, isPassword: true),
                          SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text("Forgot Password?",
                                style: TextStyle(
                                  color: Color(0xFF8C9E34),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0,
                                )),
                          ),
                          SizedBox(height: 20),
                          TextButton(
                              onPressed: () {
                                handleLogin();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Color(0xFFC0E862),
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 25),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: SizedBox(
                                  width: double.infinity,
                                  child: Center(
                                    child: Text("Login",
                                        style: TextStyle(
                                          color: Color(0xFF1E1E1E),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0,
                                        )),
                                  ))),
                          SizedBox(height: 30),
                          Stack(children: [
                            SizedBox(height: 22, child: Divider()),
                            Center(
                                child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Text("Or login with",
                                  style: TextStyle(
                                    color: Color(0xFF1E1E1E),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0,
                                  )),
                            ))
                          ]),
                          SizedBox(height: 30),
                          ServiceLoginButtons(),
                          SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account?",
                                  style: TextStyle(letterSpacing: 0)),
                              SizedBox(width: 5),
                              Text("Register",
                                  style: TextStyle(
                                    color: Color(0xFF8C9E34),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                  )),
                            ],
                          )
                        ],
                      )))
            ]))));
  }
}
