import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rabbits/Activity.dart';

class Registration extends StatefulWidget {
  final Function toggleForm;
  Registration({Key? key, required this.toggleForm}) : super(key: key);

  @override
  RegisterForm createState() => RegisterForm();
}

class RegisterForm extends State<Registration> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String password = '';
  String errors = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () => widget.toggleForm(),
            icon: Icon(Icons.person),
            label: Text('Sign In'),
            style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white)),
          )
        ],
      ),
      body: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter your name',
              ),
              onChanged: (val) {
                setState(() => name = val);
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
              onChanged: (val) {
                setState(() => email = val);
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter your password',
              ),
              onChanged: (val) {
                setState(() => password = val);
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              obscureText: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  // Validate will return true if the form is valid, or false if
                  // the form is invalid.
                  if (_registerFormKey.currentState!.validate()) {
                    // Process data.
                    dynamic result = await createNewUser(name, email, password);
                    if (result is User) {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Activity()));
                    } else {
                      setState(() => errors = result);
                    }
                  }
                },
                child: const Text('Register'),
              ),
            ),
            SizedBox(height: 12.0),
            Text(
              errors,
              style: TextStyle(color: Colors.red),
            )
          ],
        ),
      ),
    );
  }

  Future createNewUser(String name, String email, String password) async {
    try {
      UserCredential _userCreds = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await _userCreds.user!.updateDisplayName(name);

      return _userCreds.user;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
