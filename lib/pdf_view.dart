import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewWidget extends StatefulWidget {
  const PdfViewWidget({super.key, required this.path});
  final String path;
  @override
  State<PdfViewWidget> createState() => _PdfViewWidgetState();
}

class _PdfViewWidgetState extends State<PdfViewWidget> {
  late int? pages = 0;
  late  bool isReady = false;
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(10),
      child: PDFView(
        filePath: widget.path,
        enableSwipe: true,
        swipeHorizontal: true,
        fitPolicy: FitPolicy.BOTH,
        onRender: (pages) {
          setState(() {
            pages = pages;
            isReady = true;
          });
        },
        onError: (error) {
          print(error.toString());
        },
        onPageError: (page, error) {
          print('$page: ${error.toString()}');
        },
        onPageChanged: (int? page, int? total) {
          print('page change: $page/$total');
        },
      ),
    );
  }
}