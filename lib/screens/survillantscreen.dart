import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:memoire/screens/surv_details.dart';
import 'package:memoire/widgets/exam_items.dart';
import '../widgets/mydrawer.dart';

class SurvScreen extends StatefulWidget {
  @override
  _SurvScreenState createState() => _SurvScreenState();
}

class _SurvScreenState extends State<SurvScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('surveillant',style: TextStyle(color: Colors.white),),
        actions: [],
      ),
      body: examItem('surveillant',),
      drawer: MainDrawer(),
    );
  }
}
