import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_flip/page_flip.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfPage2 extends StatefulWidget {
  final String path;
  const PdfPage2({super.key, required this.path});

  @override
  State<PdfPage2> createState() => _PdfPage2State();
}

class _PdfPage2State extends State<PdfPage2> {
  final pdfViewerController = PdfViewerController();
  final pageFlipController = GlobalKey<PageFlipWidgetState>();
  int totalPages = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPageCount();
  }

  // Loads the total page count of the PDF asynchronously.
  Future<void> loadPageCount() async {
    final count = await getPdfPageCount(widget.path);
    if (mounted) {
      setState(() {
        totalPages = count;
        isLoading = false; // Loading complete
      });
    }
  }

  /// Retrieves the total page count from the PDF document.
  Future<int> getPdfPageCount(String pdfPath) async {
    try {
      final data = await rootBundle.load(pdfPath);
      final document = PdfDocument(inputBytes: data.buffer.asUint8List());
      final pageCount = document.pages.count;
      document.dispose();
      return pageCount;
    } catch (e) {
      log('Error loading PDF page count: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    log("rebuild");
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : PdfDocumentLoader.openAsset(
                'assets/pdfs/cv.pdf',
                documentBuilder:
                    (context, pdfDocument, pageCount) => LayoutBuilder(
                      builder:
                          (context, constraints) => PageFlipWidget(
                            children: [
                              PdfPageView(
                                pdfDocument: pdfDocument,
                                pageNumber: 1,
                              ),
                            ],
                          ),
                    ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pdfViewerController.setZoomRatio(zoomRatio: 1);
        },
        child: const Text("Go"),
      ),
    );
  }
}

class DemoPage extends StatefulWidget {
  final int index;
  const DemoPage({super.key, required this.index});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("${widget.index}"));
  }
}
