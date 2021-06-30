import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../databsemanager.dart';

class CustomDialogBox extends StatefulWidget {
  final String id;
  final String idExam;
  final List t;
  final List time;

  CustomDialogBox({Key key, this.id, this.t, this.idExam, this.time})
      : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserinfo();
  }

  List _userProfile = [];

  fetchUserinfo() async {
    dynamic res = await DatabaseManager().getStudentInfo(widget.id);
    if (res == null) {
      print('unable to get data');
    } else {
      setState(() {
        _userProfile = res;
      });
    }
    print('userprofile:$_userProfile');
  }

  @override
  Widget build(BuildContext context) {
    return _userProfile.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.padding),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: contentBox(context),
          );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              left: 15,
              top: Constants.avatarRadius + Constants.padding,
              right: 5,
              bottom: Constants.padding),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Étudiant : ${_userProfile[0]["nom"]} ${_userProfile[0]['prenom']}",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              SizedBox(
                height: 15,
              ),
              // Text(widget.descriptions,style: TextStyle(fontSize: 14),textAlign: TextAlign.center,),
              SizedBox(
                height: 22,
              ),
              Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      Spacer(),
                      TextButton(
                          onPressed: () async {
                            if (widget.t.contains(widget.id)) {
                              Navigator.pop(context);
                              showAlertDialog(context);
                            } else {
                              widget.t.add(widget.id);
                              widget.time.add(DateTime.now());
                            }
                            print('tab  i:${widget.t}');
                            print('tab  time:${widget.time}');
                            try {
                              await FirebaseFirestore.instance
                                  .collection('exam')
                                  .doc(widget.idExam)
                                  .collection('planing')
                                  .where("etudiant",
                                      arrayContainsAny: [widget.id])
                                  .get()
                                  .then((value) {
                                    value.docs.forEach((element) async {
                                      await FirebaseFirestore.instance
                                          .collection('exam')
                                          .doc(widget.idExam)
                                          .collection('planing')
                                          .doc(element.id)
                                          .update({
                                        'présent': widget.t,
                                      }).then((_) => FirebaseFirestore.instance
                                                  .collection('exam')
                                                  .doc(widget.idExam)
                                                  .collection('planing')
                                                  .doc(element.id)
                                                  .update({
                                                'time': widget.time,
                                              }));
                                    });
                                  })
                                  .then((value) => Navigator.pop(
                                        context,
                                      ));
                            } catch (e) {
                              print("default is :$e");
                            }
                          },
                          child: Text(
                            'validé',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          )),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'non',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          )),
                    ],
                  )),
            ],
          ),
        ),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: Constants.avatarRadius,
            child: ClipRRect(
                borderRadius:
                    BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                child: _userProfile.isEmpty
                    ? CircularProgressIndicator()
                    : Image.network("${_userProfile[0]["image"]}")),
          ),
        ),
      ],
    );
  }
}

showAlertDialog(BuildContext ctx) {
  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 0,
    backgroundColor: Colors.white60,
    title: Text(
      'cet étudiant est déjà validé',
      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    ),
    actions: [],
  );
  showDialog(
    context: ctx,
    builder: (BuildContext ctx) {
      return alert;
    },
  );
}
