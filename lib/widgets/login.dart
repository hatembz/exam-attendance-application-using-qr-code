import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class login extends StatefulWidget {
  final void Function(String email, String password, BuildContext ctx) submitfn;

  login(this.submitfn);

  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {
  final _formkey = GlobalKey<FormState>();

  String _email = "";
  String _password = "";

  void _valide() {
    final isValid = _formkey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formkey.currentState.save();
      widget.submitfn(_email.trim(), _password.trim(), context);
    }
  }

  IconData eye = Icons.visibility_off;
  bool visible = true;

  @override
  Widget build(BuildContext context) {
    double rad = MediaQuery.of(context).size.width * 0.18;
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Card(
                    child: Stack(
                      children: [
                        Positioned(
                          top: _height * 0.05,
                          right: _width * 0.335,
                          child: CircleAvatar(
                            radius: rad,
                            backgroundImage: AssetImage('assets/logo.jpeg'),
                          ),
                        )
                      ],
                    ),
                    color:  Color(0xFF33ccff),
                    margin: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    elevation: 10,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
          SafeArea(
            child: ListView(
              children: [
                SizedBox(height: _height * 0.28),
                Card(
                  margin: const EdgeInsets.all(22.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Form(
                    key: _formkey,
                    child: ListView(
                      shrinkWrap: true,
                      primary: false,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        const SizedBox(height: 20.0),
                        Text(
                          "Log In",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline5.copyWith(
                                color:  Color(0xFF33ccff),
                              ),
                        ),
                        const SizedBox(height: 40.0),
                        TextFormField(
                          key: ValueKey('email'),
                          validator: (val) {
                            final bool isValid = EmailValidator.validate(val);
                            if (!isValid) {
                              return 'entrer un email valide';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (val) => _email = val,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                            labelText: "adresse email",
                          ),
                        ),
                        SizedBox(height: 10.0),
                        TextFormField(
                          key: ValueKey('password'),
                          validator: (val) {
                            if (val.isEmpty || val.length <= 4) {
                              return 'mot de passe invalide';
                            }
                            return null;
                          },
                          obscureText: visible,
                          onSaved: (val) => _password = val,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  eye == Icons.visibility
                                      ? eye = Icons.visibility_off
                                      : eye = Icons.visibility;
                                  visible = !visible;
                                });
                              },
                              icon: Icon(eye),
                            ),
                            border: OutlineInputBorder(),
                            labelText: "mot de passe",
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        ElevatedButton(
                          child: Text("connexion"),
                          onPressed: _valide,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
