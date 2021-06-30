import 'package:flutter/material.dart';
import 'package:memoire/screens/studentscreen.dart';
import 'package:memoire/screens/survillantscreen.dart';

import '../databsemanager.dart';
import 'adminScreen.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  String usertype;

  void initState() {
    super.initState();
    fetchusertype();
  }

  fetchusertype() async {
    dynamic result = await DatabaseManager().getuserList();
    if (result == null) {
      print('unable to get data');
    } else {
      setState(() {
        usertype = result[0]['category'];
      });
    }
    print("type:${result[0]['category']}");
  }

  @override
  Widget build(BuildContext context) {
    String res = usertype;
    if (res == 'student') {
      return StudentScreen();
    } else if (res == 'surviellant') {
      return SurvScreen();
    } else if (res == 'admin') {
      return adminScreen();
    } else {
      return Scaffold(
        body: Center(
          child: Container(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                strokeWidth: 10.0,
              )),
        ),
      );
    }
  }
}
