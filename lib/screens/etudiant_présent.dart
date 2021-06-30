import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../databsemanager.dart';

class EtudiantPresent extends StatefulWidget {
  final time;
  final presant;

  const EtudiantPresent({Key key, this.presant, this.time}) : super(key: key);

  @override
  _EtudiantPresentState createState() => _EtudiantPresentState();
}

class _EtudiantPresentState extends State<EtudiantPresent> {
  String formatHeure(DateTime date) => new DateFormat("hh:mm a").format(date);
  String formatDate(DateTime date) => new DateFormat("dd/MM/yy").format(date);

  void initState() {
    super.initState();
    fetchStudents();
    fetchTime();
  }

  var timer;
  List _foundUsers = [];

  fetchStudents() async {
    for (int i = 0; i < widget.presant.length; i++) {
      dynamic result =
          await DatabaseManager().selectedstudent(widget.presant[i]);
      if (result == null) {
        print('unable to get data');
      } else {
        setState(() {
          _foundUsers.add(result);
        });
      }

      print('foundUsers:${_foundUsers}');
    }
  }

  fetchTime() async {
    dynamic res =
        await DatabaseManager().selecteditemdetails(widget.time, 'surveillant');
    if (res == null) {
      print('unable to get data');
    } else {
      setState(() {
        timer = res;
      });
    }
    print(timer);
  }

  @override
  Widget build(BuildContext context) {
    var get = FirebaseFirestore.instance
        .collection("users")
        .where("category", isEqualTo: 'student')
        .get();
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Les étudiants validés :',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Expanded(
              child:  (_foundUsers.isEmpty&&timer[0]["time"].isEmpty)
                      ? Text(
                          'aucun étudiant validé',
                          style: TextStyle(fontSize: 24),
                        )
                      : _foundUsers.length == timer[0]["time"].length
                  ? RefreshIndicator(
                onRefresh: () {
                  setState(() {
                    get = FirebaseFirestore.instance
                        .collection("users")
                        .where("category", isEqualTo: 'student')
                        .get();
                  });
                  return get;
                },
                child: FutureBuilder(
                    future: get,
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 3),
                              child: ListTile(
                                title: Text(_foundUsers[index][0]['nom'] +
                                    ' ' +
                                    _foundUsers[index][0]['prenom']),
                                subtitle: Text(
                                  "validé le: ${formatDate(timer[0]["time"][index].toDate())} à : ${formatHeure(timer[0]["time"][index].toDate())}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                          itemCount: widget.presant.length,
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }),
              )
                  : Text(
                          'attend...',
                          style: TextStyle(fontSize: 24),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
