import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';

class PdfApi {
  static Future<File> generateQr(String text, String name,String txt) async {
    final pdf = Document();
    pdf.addPage(Page(
      build: (context) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
        Center(
          child: Text("$txt : $name",style: TextStyle(
            fontSize: 60,
          )),
        ),
            SizedBox(
              height:50,
            ),
        BarcodeWidget(
          barcode: Barcode.qrCode(),
          data: text,
          width: 450,
          height: 450,
        )
      ]),
    ));
    return await saveDocument(name: 'qr de $name.pdf', pdf: pdf);
  }

  static Future saveDocument({
    String name,
    Document pdf,
  }) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }
}
