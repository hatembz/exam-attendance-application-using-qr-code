import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memoire/screens/student_qr.dart';

import '../databsemanager.dart';

class FoundStudent extends StatefulWidget {
  final Studentid;

  const FoundStudent({Key key, this.Studentid}) : super(key: key);

  @override
  _FoundStudentState createState() => _FoundStudentState();
}

class _FoundStudentState extends State<FoundStudent> {
  @override
  void initState() {
    super.initState();
    fetchexamList();
  }

  fetchexamList() async {
    dynamic result = await DatabaseManager().founduserdetails(widget.Studentid);
    if (result == null) {
      print('unable to get data');
    } else {
      setState(() {
        found = result;
      });
    }
    print("user:$found");
  }

  List found = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: found.isEmpty
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('exam')
                  .where('etudiant', arrayContainsAny: [found[1]]).get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data.docs;
                  return GridView(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: MediaQuery.of(context).size.width,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 10,
                        childAspectRatio: 3 / 1,
                      ),
                      padding: EdgeInsets.all(15),
                      children: documents
                          .map((doc) => Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF33ccff),
                                          Color(0xFF33ccff).withOpacity(0.8)
                                        ]),
                                    borderRadius: BorderRadius.circular(20)),
                                child: InkWell(
                                  onTap: () async {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (ctx) => StudentQr(
                                                id: widget.Studentid,nom:doc["nom d'exam"],passedkey: doc["key"],)));
                                  },
                                  child: Center(
                                    child: Text(
                                      doc["nom d'exam"],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ))
                          .toList());
                } else if (snapshot.hasError) {
                  return Text('Its Error!');
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              }),
    );
  }
}
