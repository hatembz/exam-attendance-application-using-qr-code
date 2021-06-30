import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memoire/screens/exam_details.dart';
import 'package:memoire/screens/surv_details.dart';

class examItem extends StatefulWidget {
  final String type;


  examItem(
    this.type,
  );

  @override
  _examItemState createState() => _examItemState();
}

class _examItemState extends State<examItem> {
  String formatHeure(DateTime date) => new DateFormat("hh:mm").format(date);
  String formatDate(DateTime date) => new DateFormat("dd:MM:yy").format(date);
  String userId = FirebaseAuth.instance.currentUser.uid;
@override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
Future<QuerySnapshot> get= FirebaseFirestore.instance
    .collection('exam')
    .where(widget.type, arrayContainsAny: [userId]).get();
    return RefreshIndicator(
onRefresh: () {
  setState(() {
     get= FirebaseFirestore.instance
        .collection('exam')
        .where(widget.type, arrayContainsAny: [userId]).get();

  });
  return get;
},
      child: FutureBuilder<QuerySnapshot>(
          future:get,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<DocumentSnapshot> documents = snapshot.data.docs;
              return GridView(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 3 / 2,
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
                                DateTime.now().isBefore(doc['date'].toDate())?
                                 Navigator.of(context).push(MaterialPageRoute(
                                builder
                                    : (ctx) => widget.type == "surveillant"
                                    ? survDetails(recievedData: doc.id,
                                    surveillant: doc['surveillant'][0],passedKey: doc['key'],)
                                    : ExamDetails(recievedData : doc.id,pasedkey: doc['key'],)))
                              :showAlertDialog(context, 'vous etes en retard');
                                print(doc['date'].toDate().toString());

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

showAlertDialog(BuildContext ctx, String title) {
  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 0,
    backgroundColor: Colors.white60,
    title: Text(
      title,
      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    ),
    actions: [

    ],
  );
  showDialog(
    context: ctx,
    builder: (BuildContext ctx) {
      return alert;
    },
  );
}
