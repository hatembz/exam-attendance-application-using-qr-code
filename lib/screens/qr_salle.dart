import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../databsemanager.dart';
import '../pdf_api.dart';

class QrSalle extends StatefulWidget {
  final id;
  final nom;
  final examid;

  const QrSalle({Key key, this.id, this.nom, this.examid}) : super(key: key);

  @override
  _QrSalleState createState() => _QrSalleState();
}

class _QrSalleState extends State<QrSalle> {
  void initState() {
    super.initState();
    fetchexamdetails();
  }

  String formatDate(DateTime date) =>
      new DateFormat("dd/MM/yy hh:mm a").format(date);

  fetchexamdetails() async {
    dynamic result = await DatabaseManager().selectedItem(widget.examid);

    if (result == null) {
      print('unable to get data');
    } else {
      setState(() {
        found = result;
      });
    }
    print("exams:$found");
  }

  List found = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: found.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: Card(
            margin: const EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.05,
                ),
                BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: widget.id + '/' + 'exam de: ${found[0]["nom d'exam"]}' +
                      '/' +
                      "${formatDate(found[0]["date"].toDate())} " + '/' +
                      '${found[0]["durée"]}min',
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.8,
                  height: MediaQuery
                      .of(context)
                      .size
                      .width * 0.8,
                ),
                SizedBox(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.15,
                ),
                TextButton(
                  onPressed: () async {
                    final pdfFile = await PdfApi.generateQr(
                        widget.id + '/' + 'exam de: ${found[0]["nom d'exam"]}' +
                            '/' + "${formatDate(found[0]["date"].toDate())} " + '/' + '${found[0]["durée"]}min',widget.nom, 'salle');
                    PdfApi.openFile(pdfFile);
                  },
                  child: Text("transfrom vers pdf"),
                ),
              ],
            )),
      ),
    );
  }
}
