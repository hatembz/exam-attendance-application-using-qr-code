import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memoire/screens/found_student_details.dart';

import '../databsemanager.dart';
class StudentList extends StatefulWidget {
  const StudentList({Key key}) : super(key: key);

  @override
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {

  void initState() {
    // TODO: implement initState
    super.initState();
    fetchstudentlist();
  }

  List fullList = [];

  fetchstudentlist()async {
    dynamic res = await DatabaseManager().getStudentList();
    if (res == null) {
      print('unable to get data');
    } else {
      setState(() {
        fullList = res;
        _foundUsers = fullList;
      });
    }
  }
  List _foundUsers = [];
  void _runFilter(String enteredKeyword) {
    List results = [];
    if (enteredKeyword.isEmpty) {
      results = fullList;
    } else {
      results = fullList
          .where((user) =>
          user["nom"].toLowerCase().contains(enteredKeyword.toLowerCase())|| user["prenom"].toLowerCase().contains(enteredKeyword.toLowerCase())
               )
          .toList();
    }
    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            TextField(
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueAccent,
                    ),
                    borderRadius: BorderRadius.circular(10.0),),
                  labelText: 'Search', suffixIcon: Icon(Icons.search)),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: _foundUsers.length > 0
                  ?  FutureBuilder(
                future:  FirebaseFirestore.instance. collection("users")
                    .where("category",
                    isEqualTo: 'student')
                    .get(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: _foundUsers.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 3),
                          key: ValueKey(_foundUsers[index]['email']),
                          child: ListTile(
                            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => FoundStudent(Studentid:_foundUsers[index]["nom"]),));},
                            title: Text("${_foundUsers[index]['nom']} ${_foundUsers[index]['prenom']} "),
                          ),
                        );
                      },
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              )
                  : Text(
                'No results found',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
