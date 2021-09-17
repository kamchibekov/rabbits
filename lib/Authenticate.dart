import 'package:flutter/material.dart';
import 'package:rabbits/Activity.dart';
import 'SignIn.dart';
import 'Registration.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignInForm = false;
  void toggleForm() {
    setState(() => showSignInForm = !showSignInForm);
  }

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Activity()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return showSignInForm
        ? SignIn(toggleForm: toggleForm)
        : Registration(toggleForm: toggleForm);
  }
}
