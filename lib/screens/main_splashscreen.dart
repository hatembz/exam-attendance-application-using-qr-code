import 'package:flutter/material.dart';
import 'package:memoire/main.dart';
import 'package:splashscreen/splashscreen.dart';
class mainSplashScreen extends StatefulWidget {
  const mainSplashScreen({Key key}) : super(key: key);

  @override
  _mainSplashScreenState createState() => _mainSplashScreenState();
}

class _mainSplashScreenState extends State<mainSplashScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(
        seconds: 4,
        navigateAfterSeconds: MyApp(),
        title: Text("bienvenue",style: TextStyle(fontSize: 40,color: Color(0xff1aa0bc)),),
        image: Image.asset("assets/owl.jpeg"),
        backgroundColor: Color(0xFFdfdfdf),
        photoSize:150,
      ),
      
    );
  }
}
