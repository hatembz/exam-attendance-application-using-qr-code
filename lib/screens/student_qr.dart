import 'package:barcode_widget/barcode_widget.dart';
import 'package:encrypt/encrypt.dart' as ency;
import 'package:flutter/material.dart';

import '../databsemanager.dart';
import '../pdf_api.dart';

class StudentQr extends StatefulWidget {
  final id;
  final nom;
  final passedkey;

  const StudentQr({Key key, this.id, this.nom, this.passedkey, }) : super(key: key);

  @override
  _StudentQrState createState() => _StudentQrState();
}

class _StudentQrState extends State<StudentQr> {
  void initState() {
    super.initState();
    fetchexamList();
  }

  fetchexamList() async {
    dynamic result = await DatabaseManager().founduserdetails(widget.id);
    if (result == null) {
      print('unable to get data');
    } else {
      setState(() {
        found = result;
        keyVal=widget.passedkey;
      });
    }
    print("user:$found");
  }
String keyVal;
  CryptQr(@required qrData,String val) {
    final key = ency.Key.fromUtf8(val);
    final iv = ency.IV.fromLength(16);
    final encrypter = ency.Encrypter(ency.AES(key));
    final encryptedQR = encrypter.encrypt(qrData, iv: iv);
    return encryptedQR.base64;
  }

  List found = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: found.isEmpty
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
                              horizontal: 10, vertical: 12),
                          margin: EdgeInsets.symmetric(horizontal: 10),
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
                                  "étudiant : ${found[0]["nom"]} ${found[0]["prenom"]}",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700),
                                ),
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
              Column(children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.20),
                Card(
                  margin: const EdgeInsets.all(15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: BarcodeWidget(
                    barcode: Barcode.qrCode(),
                    data: CryptQr(
                        '${found[1]}' +
                            '/' +
                            '${widget.nom}' +
                            '/' +
                            '${found[0]["nom"]}' +
                            '/' +
                            '${found[0]["prenom"]}'
                    ,keyVal),
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.width * 0.7,
                  ),
                ),
                Spacer(),
                TextButton(

                  onPressed: () async {
                    print(keyVal);
                    final pdfFile =
                        await PdfApi.generateQr(CryptQr(
                            '${found[1]}' +
                                '/' +
                                '${widget.nom}' +
                                '/' +
                                '${found[0]["nom"]}' +
                                '/' +
                                '${found[0]["prenom"]}'
                       ,keyVal ), widget.nom,'module');
                    PdfApi.openFile(pdfFile);
                  },
                  child: Text(
                    "transfrom vers pdf",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
              ]),
            ]),
    );
  }
}
