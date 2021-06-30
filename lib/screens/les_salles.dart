import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memoire/screens/qr_salle.dart';
class Salles extends StatefulWidget {
  final id;
  const Salles({Key key, this.id}) : super(key: key);

  @override
  _SallesState createState() => _SallesState();
}

class _SallesState extends State<Salles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future:  FirebaseFirestore.instance. collection("exam").doc(widget.id).collection("planing")
            .get(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            final List<DocumentSnapshot> documents = snapshot.data.docs;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 3),
                  child: ListTile(
                    onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => QrSalle(id:documents[index].id,nom:documents[index]['salle'],examid:widget.id,),));},
                    title: Text("${documents[index]['salle']}  "),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Its Error!');
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
