import 'package:flutter/material.dart';
import 'package:memoire/widgets/exam_items.dart';

import '../widgets/mydrawer.dart';

class StudentScreen extends StatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('étudiant',style: TextStyle(color: Colors.white),),
        actions: [],
      ),
      body: examItem('etudiant',),
      drawer: MainDrawer(),
    );
  }
}
