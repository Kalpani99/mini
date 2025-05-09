import 'package:track_bus/forgot_password.dart';
import 'package:track_bus/passenger/passengerhome.dart';
import 'package:track_bus/services/firebase_services.dart';
import 'package:track_bus/signup.dart';
import 'package:track_bus/bus_operator/bostarttrip.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  static const routeName = "Login";
  @override
  State<Login> createState() => _LoginState();
}

TextEditingController _passwordTextController = TextEditingController();
TextEditingController _emailTextController = TextEditingController();

var _isObscured = true;

class _LoginState extends State<Login> {
  String? _emailError;
  String? _passwordError;

  void clearUserInput() {
    _emailTextController.clear();
    _passwordTextController.clear();
  }

  Future<void> _handleGoogleSignIn() async {
    // Show a dialog to select user type
    String? UserType = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              "Select User Type",
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop("passenger");
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      )),
                  child: const Text("Passenger",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop("busOperator");
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      )),
                  child: const Text("Bus Operator",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          );
        });

    // Sign in with Google
    await FirebaseServices().signInWithGoogle();

    // Navigate to the relevant screen based on user type
    if (UserType == "passenger") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PassengerHomeScreen()),
      );
    } else if (UserType == "busOperator") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BOStartTrip()),
      );
    }
  }

  Future<void> _handleLogin() async {
    String email = _emailTextController.text.trim();
    String password = _passwordTextController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _emailError = "Please Enter Your Email";
        _passwordError = "Password is required for login";
      });
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDataSnapshot.exists) {
        String role = userDataSnapshot.get('role');

        if (role == "busOperator") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BOStartTrip(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PassengerHomeScreen(),
            ),
          );
        }
      } else {
        // Handle invalid user
        setState(() {
          _emailError = "Invalid user";
          _passwordError = null;
        });
      }
    } catch (error) {
      print("Error during sign-in: ${error.toString()}");
      setState(() {
        _passwordError = "Invalid email or password";
        _emailError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child:
                Image.asset('assets/images/signupback.png', fit: BoxFit.cover),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: size.width * 0.08),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 35, right: 35),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailTextController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return ("Please Enter Your Email");
                                  }
                                  if (!RegExp(
                                          "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                      .hasMatch(value)) {
                                    return ("Please Enter a valid Email");
                                  }
                                  return null;
                                },
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  suffixIcon: const Padding(
                                    padding:
                                        EdgeInsetsDirectional.only(end: 10.0),
                                    child: Icon(Icons.mail),
                                  ),
                                  hintText: "Email",
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorText: _emailError,
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              TextFormField(
                                controller: _passwordTextController,
                                validator: (value) {
                                  RegExp regex = RegExp(r'^.{6,}$');
                                  if (value!.isEmpty) {
                                    return ("Password is required for login");
                                  }
                                  if (!regex.hasMatch(value)) {
                                    return ("Please enter valid password(min. 6 character)");
                                  }
                                  return null;
                                },
                                style: const TextStyle(),
                                obscureText: _isObscured,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10.0),
                                    icon: _isObscured
                                        ? const Icon(Icons.visibility)
                                        : const Icon(Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        _isObscured = !_isObscured;
                                      });
                                    },
                                  ),
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: "Password",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorText: _passwordError,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ForgotPasswordScreen()));
                                        },
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            color: Color(0xff4c505b),
                                            fontSize: 18,
                                          ),
                                        )),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    SizedBox(
                                        height: 50,
                                        width: 150,
                                        child: ElevatedButton(
                                          onPressed: _handleLogin,
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              )),
                                          child: const Text(
                                            'Log in',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 25),
                                          ),
                                        )),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Don't have an account",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SignUp()));
                                            },
                                            child: const Text(
                                              'Sign Up',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  color: Color(0xff4c505b),
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Or continue with",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 18),
                                    ),
                                    SizedBox(
                                        height: 40,
                                        width: 135,
                                        child: ElevatedButton(
                                          onPressed: _handleGoogleSignIn,
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.grey.shade100,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              )),
                                          child: Row(
                                            children: <Widget>[
                                              Image.asset(
                                                "assets/images/googlelogo.png",
                                                width: 25,
                                                height: 20,
                                              ),
                                              const Text(
                                                'Google',
                                                style: TextStyle(
                                                    color: Color(0xff4c505b),
                                                    fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
            ],
          )
        ],
      ),
    );
  }
}
