import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/login.dart';

class loginScreen extends StatefulWidget {
  @override
  _loginScreenState createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  void _submit(String email, String password, BuildContext ctx) async {
    UserCredential authResult;
    try {
      authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String msg = "erreur";
      if (e.code == 'user-not-found') {
        msg = 'Aucun utilisateur trouvé pour cet email.';
      } else if (e.code == 'wrong-password') {
        msg = 'Mot de passe erroné';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return login(_submit);
  }
}
