import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:flutter/material.dart';

class ReadPdf extends StatefulWidget {
  final String url;
  ReadPdf({Key key, @required this.url}) : super(key: key);
  @override
  _ReadPdfState createState() => _ReadPdfState();
}

class _ReadPdfState extends State<ReadPdf> {
  bool _isLoading = true;
  PDFDocument document;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    document = await PDFDocument.fromURL(widget.url);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              size: 35,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xffff2193b0), Color(0xffff6dd5ed)])),
        ),
      ),
      body: Container(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : PDFViewer(
                  showNavigation: true,
                  document: document,
                  showIndicator: true,
                  showPicker: true,
                  indicatorText: Colors.red,
                  indicatorBackground: Colors.white,
                )),
    );
  }
}
