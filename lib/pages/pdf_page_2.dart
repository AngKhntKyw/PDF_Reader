import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfPage2 extends StatefulWidget {
  final String path;
  const PdfPage2({super.key, required this.path});

  @override
  State<PdfPage2> createState() => _PdfPage2State();
}

class _PdfPage2State extends State<PdfPage2>
    with SingleTickerProviderStateMixin {
  final pdfViewerController = PdfViewerController();
  final pageFlipController = GlobalKey<PageFlipWidgetState>();

  int totalPages = 0;
  bool isLoading = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    // loadPageCount();
  }

  // // Loads the total page count of the PDF asynchronously.
  // Future<void> loadPageCount() async {
  //   final count = await getPdfPageCount(widget.path);
  //   if (mounted) {
  //     setState(() {
  //       totalPages = count;
  //       isLoading = false; // Loading complete
  //     });
  //   }
  // }

  // /// Retrieves the total page count from the PDF document.
  // Future<int> getPdfPageCount(String pdfPath) async {
  //   try {
  //     final data = await rootBundle.load(pdfPath);
  //     final document = PdfDocument(inputBytes: data.buffer.asUint8List());
  //     final pageCount = document.pages.count;
  //     document.dispose();
  //     return pageCount;
  //   } catch (e) {
  //     log('Error loading PDF page count: $e');
  //     return 0;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    log("rebuild");
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : PdfDocumentLoader.openAsset(
                widget.path,
                documentBuilder: (context, pdfDocument, pageCount) {
                  if (pageCount == 0) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return PageFlipWidget(
                    key: pageFlipController,

                    cutoffForward: 1,
                    cutoffPrevious: 1,
                    initialIndex: 0,
                    lastPage: Center(child: Text("THE END!")),
                    children: [
                      ...List.generate(pageCount, (index) {
                        return PageFlipBuilder(
                          isRightSwipe: false,
                          amount: _animation,
                          pageIndex: index,
                          key: PageStorageKey(index + 1),
                          child: Center(
                            child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              color: Colors.white,
                              child: PdfPageView(pageNumber: index + 1),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          log("${pageFlipController.currentState!.pages}");
        },
        child: const Text("Go"),
      ),
    );
  }
}

class DemoPage extends StatelessWidget {
  final int index;
  const DemoPage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text("$index")],
      ),
    );
  }
}
