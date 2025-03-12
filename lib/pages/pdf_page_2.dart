import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class PdfPage2 extends StatefulWidget {
  final String path;
  const PdfPage2({super.key, required this.path});

  @override
  State<PdfPage2> createState() => _PdfPage2State();
}

class _PdfPage2State extends State<PdfPage2> {
  int pages = 0;
  bool isReady = false;
  Completer<PDFViewController> controller = Completer<PDFViewController>();
  String? filePath;

  @override
  void initState() {
    super.initState();
    loadPdfFromAssets();
  }

  Future<void> loadPdfFromAssets() async {
    try {
      // Load the PDF from assets
      final byteData = await rootBundle.load(widget.path);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/cv.pdf');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      setState(() {
        filePath = tempFile.path; // Update the filePath
      });
      log('Temporary file path: $filePath');
    } catch (e) {
      log('Error loading PDF from assets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          filePath == null
              ? const Center(child: CircularProgressIndicator())
              : PDFView(
                filePath: filePath,
                enableSwipe: true,
                swipeHorizontal: true,
                autoSpacing: true,
                pageFling: true,
                backgroundColor: Colors.grey,
                onRender: (values) {
                  setState(() {
                    pages = values!;
                    isReady = true;
                  });
                },
                onError: (error) {
                  log(error.toString());
                },
                onPageError: (page, error) {
                  log('$page: ${error.toString()}');
                },
                onViewCreated: (PDFViewController pdfViewController) {
                  !controller.isCompleted
                      ? controller.complete(pdfViewController)
                      : null;
                },
                onPageChanged: (page, total) {
                  log('page change: $page/$total');
                },
              ),
    );
  }
}
