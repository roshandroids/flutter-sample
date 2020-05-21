import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReadPdf extends StatefulWidget {
  final String title;
  final String url;
  ReadPdf({Key key, @required this.url, @required this.title})
      : super(key: key);
  @override
  _ReadPdfState createState() => _ReadPdfState();
}

class _ReadPdfState extends State<ReadPdf> {
  FileInfo fileInfo;

  String localPath;

  @override
  void initState() {
    super.initState();
    loadPDF();
  }

  void loadPDF() async {
    File f = await DefaultCacheManager().getSingleFile(widget.url);

    setState(() {
      localPath = f.path;
    });
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
        centerTitle: true,
        title: Text(
          widget.title,
          style: GoogleFonts.firaCode(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xffff2193b0), Color(0xffff6dd5ed)])),
        ),
      ),
      body: localPath != null
          ? PDFView(
              swipeHorizontal: true,
              filePath: localPath,
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
