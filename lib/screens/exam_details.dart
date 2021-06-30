

import 'package:barcode_widget/barcode_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as ency;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';

import '../databsemanager.dart';

class ExamDetails extends StatefulWidget {
  final recievedData;
 final pasedkey;
  const ExamDetails({Key key, this.recievedData, this.pasedkey}) : super(key: key);

  @override
  _ExamDetailsState createState() => _ExamDetailsState();
}

class _ExamDetailsState extends State<ExamDetails> {
  void initState() {
    super.initState();
    fetchexamList();
  }
  List userList = [];
  List salle = [];
  List selecteditem = [];
  List userprofile = [];
 String keyVal;
  fetchexamList() async {
    dynamic result = await DatabaseManager().selectedItem(widget.recievedData);
    dynamic res = await DatabaseManager()
        .selecteditemdetails(widget.recievedData, "etudiant");
    dynamic res2 = await DatabaseManager().getuserList();
    if (result == null || res == null) {
      print('unable to get data');
    } else {
      setState(() {
        userprofile = res2;
        userList = result;
        salle = res;
      keyVal=widget.pasedkey;
      });
    }
    print("user:$userprofile");
    print("userlist:$userList");
    print("salle:$salle");
  }

  CryptQr(@required qrData,String val) {
    final key = ency.Key.fromUtf8(val);
    final iv = ency.IV.fromLength(16);
    final encrypter = ency.Encrypter(ency.AES(key));
    final encryptedQR = encrypter.encrypt(qrData, iv: iv);
    return encryptedQR.base64;
  }

  var _content;

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() {
      _content = barcodeScanRes;
    });
  }

  String formatDate(DateTime date) => new DateFormat("dd/MM/yy").format(date);

  String formatHeure(DateTime date) => new DateFormat("hh:mm").format(date);
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xFF33ccff),
          title: Text(
            userList.isEmpty ? '' : userList[0]["nom d'exam"],
            style: TextStyle(color: Colors.white),
          )),
      body: userList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Stack(fit: StackFit.expand, children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                        child: Card(
                      child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF33ccff),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height * 0.15,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            color: Color(0xFF33ccff),
                            elevation: 0.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Date : ${formatDate(userList[0]["date"].toDate()).toString()}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                Text(
                                  "Heure : ${formatHeure(userList[0]["date"].toDate()).toString()}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                Text(
                                  "Salle : ${salle[0]}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('exam')
                                        .doc(widget.recievedData)
                                        .collection('planing')
                                        .where('etudiant',
                                            arrayContainsAny: [
                                          FirebaseAuth.instance.currentUser.uid
                                        ]).snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (!snapshot.hasData) {
                                        return new Text("État :",  style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20),);
                                      } else {
                                        var userDocument = snapshot.data.docs;
                                        return Text(   userDocument[0]['présent'].contains(FirebaseAuth.instance.currentUser.uid)?
                                          "État : présent":"État : absent",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        );
                                      }
                                    }),
                              ],
                            ),
                          )),
                      color: Color(0xFF33ccff),
                      margin: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      elevation: 10,
                    )),
                    Spacer(
                      flex: 2,
                    )
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.20),
                  Card(
                    margin: const EdgeInsets.all(15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Visibility(
                      visible: visible,
                      child: BarcodeWidget(
                        barcode: Barcode.qrCode(),
                        data: CryptQr(
                          '${FirebaseAuth.instance.currentUser.uid}' +
                              '/' +
                              '${userList[0]["nom d'exam"]}' +
                              '/' +
                              '${userprofile[0]["nom"]}' +
                              '/' +
                              '${userprofile[0]["prenom"]}',
                        keyVal),
                        width: MediaQuery.of(context).size.width * 0.75,
                        height: MediaQuery.of(context).size.width * 0.75,
                      ),
                    ),
                  ),
                  Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ))),
                        onPressed: () async {
                          await scanQR().then((_) {
                            var qrDetails = _content.split('/');
                            if (qrDetails[0] == salle[1]) {
                              return showAlertDialog(context, "valide", "c'est votre salle", Colors.green);
                            } else {
                              return showAlertDialog(context, "erroné", "esseyer encore", Colors.red);
                            }});},
                        child: Text('Scanner QR-code'),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.15,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ))),
                        onPressed: () {
                          setState(() {
                            visible = !visible;
                          });
                        },
                        child: Text("Afficher QR CODE"),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                ],
              ),
            ]),
    );
  }

  showAlertDialog(
      BuildContext context, String title, String content, Color col) {
    Widget okButton = TextButton(
      child: Text(
        "OK",
        style: TextStyle(color: col),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: TextStyle(color: col, fontWeight: FontWeight.bold),
      ),
      content: Text(
        content,
        style: TextStyle(color: col, fontSize: 20),
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
