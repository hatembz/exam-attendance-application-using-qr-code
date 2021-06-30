import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as ency;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:memoire/screens/etudiant_pr%C3%A9sent.dart';
import 'package:memoire/widgets/custom_alert.dart';

import '../databsemanager.dart';

class survDetails extends StatefulWidget {
  final recievedData;
  final surveillant;
  final passedKey;

  const survDetails({
    Key key,
    this.recievedData,
    this.surveillant, this.passedKey,
  }) : super(key: key);

  @override
  _survDetailsState createState() => _survDetailsState();
}

class _survDetailsState extends State<survDetails> {
  void initState() {
    super.initState();
    fetchexamList();
  }

  bool found = false;

  String formatHeure(DateTime date) => new DateFormat("hh:mm").format(date);

  String formatDate(DateTime date) => new DateFormat("dd/MM/yy").format(date);
  List userList = [];
  List salle = [];
  List tab = [];
 List time=[];
 var id;
  fetchexamList() async {
    dynamic result = await DatabaseManager().selectedItem(widget.recievedData);
    dynamic res = await DatabaseManager()
        .selecteditemdetails(widget.recievedData, 'surveillant');
    if (result == null) {
      print('unable to get data');
    } else {
      setState(() {
        userList = result;
        salle = res;
        keyVal=widget.passedKey;
      });
    }
    print("key:$keyVal");
    print("userlist:$userList");
    print("salle:$salle");
  }

  var _content;
String keyVal;
  Future scanQR(String val) async {
    final key = ency.Key.fromUtf8(val);
    final iv = ency.IV.fromLength(16);
    final encrypter = ency.Encrypter(ency.AES(key));
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    final decryptedQR = encrypter.decrypt(ency.Encrypted.from64(barcodeScanRes), iv: iv);
     print('BARCODE' + decryptedQR);
     print(barcodeScanRes);
     setState(() {
       barcodeScanRes = decryptedQR;
       _content = barcodeScanRes;
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          userList.isEmpty ? '' : userList[0]["nom d'exam"],
          style: TextStyle(color: Colors.white),
        )),
        body: RefreshIndicator(
            onRefresh: () async {
              return await fetchexamList();
            },
            child: userList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Stack(
                    fit: StackFit.expand,
                    children: [
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 15),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    color: Color(0xFF33ccff),
                                    elevation: 0.0,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        salle.isEmpty
                                            ? CircularProgressIndicator()
                                            : Text(
                                                "Date : ${formatDate(userList[0]["date"].toDate()).toString()}",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                        Text(
                                          "Heure : ${formatHeure(userList[0]["date"].toDate()).toString()}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        Text(
                                          "Salle : ${salle[0]['salle']}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('exam')
                                                .doc(widget.recievedData)
                                                .collection('planing')
                                                .where('surveillant',
                                                    arrayContainsAny: [
                                                  FirebaseAuth
                                                      .instance.currentUser.uid
                                                ]).snapshots(),
                                            builder: (context,
                                                AsyncSnapshot<QuerySnapshot>
                                                    snapshot) {
                                              if (!snapshot.hasData) {
                                                return new Text("Loading");
                                              } else {
                                                var userDocument =
                                                    snapshot.data.docs;
                                                return Text(
                                                  "Nombre de présences :${userDocument[0]['présent'].length} sur ${userDocument[0]["etudiant"].length} étudiants",
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
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(elevation: 5.0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                      backgroundColor: Color(0xFF33ccff),
                                      textStyle: TextStyle(fontSize: 24)),
                                  onPressed: () async {
                                    print('key:$keyVal');
                                    await scanQR(keyVal).then((value) {
                                      var qrDetails = _content.split('/');
                                      for (int i = 0; i < salle[0]['etudiant'].length; i++) {
                                        if (salle[0]['etudiant'][i] == qrDetails[0]) {
                                            setState(() {
                                              found = true;
                                              salle[0]['présent'] == null ? tab = [] : tab = salle[0]['présent'];
                                             time= salle[0]['time'];
                                            });
                                            showDialog(context: context, builder: (BuildContext context) {
                                                  return CustomDialogBox(id: qrDetails[0], t: tab, idExam: widget.recievedData, time: time,);});
                                            break;
                                        } else if (i + 1 == salle[0]['etudiant'].length && found == false) {
                                          showAlertDialog(context, ' salle erronée');}}});},
                                  child: Text('Scan QR', style: TextStyle(color: Colors.white)),
                                ),
                                Spacer(),
                                TextButton(
                                    style: TextButton.styleFrom(
                                        elevation: 5.0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        backgroundColor: Color(0xFF33ccff),
                                        textStyle: TextStyle(fontSize: 24)),
                                    onPressed: () {
                                      tab = salle[0]['présent'];
                                       id=widget.recievedData;
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EtudiantPresent(presant:tab,time:id),
                                          ));
                                    },
                                    child: Text(
                                      "liste de présence",
                                      style: TextStyle(color: Colors.white),
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                          )
                        ],
                      ),
                    ],
                  )));
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
    actions: [],
  );
  showDialog(
    context: ctx,
    builder: (BuildContext ctx) {
      return alert;
    },
  );
}
