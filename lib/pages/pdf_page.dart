import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:page_flip/page_flip.dart';

class PDFViewerPage extends StatefulWidget {
  final String pdfPath;

  const PDFViewerPage({required this.pdfPath, super.key});

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  final _pageFlipController = GlobalKey<PageFlipWidgetState>();
  late final PdfViewerController _pdfViewerController;
  int? _totalPages;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadPageCount();
  }

  /// Loads the total page count of the PDF asynchronously.
  Future<void> _loadPageCount() async {
    final count = await _getPdfPageCount(widget.pdfPath);
    if (mounted) {
      setState(() => _totalPages = count);
    }
  }

  /// Retrieves the total page count from the PDF document.
  Future<int> _getPdfPageCount(String pdfPath) async {
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
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _totalPages == null
              ? const Center(child: CircularProgressIndicator())
              : _buildPageFlipViewer(),
    );
  }

  /// Builds the PageFlipWidget with PDF pages.
  Widget _buildPageFlipViewer() {
    return PageFlipWidget(
      key: _pageFlipController,
      backgroundColor: Colors.white,
      cutoffForward: 1.0,
      cutoffPrevious: 1.0,
      isRightSwipe: false,
      lastPage: _buildEndPage(),
      children: List.generate(
        _totalPages!,
        (index) => PaperPage(pdfPath: widget.pdfPath, pageNumber: index + 1),
      ),
    );
  }

  /// Builds the final page shown after all PDF pages.
  Widget _buildEndPage() {
    return Container(
      color: Colors.white,
      child: const Center(child: Text('THE END!')),
    );
  }
}

/// A single page in the PDF viewer with disabled drag gestures.
class PaperPage extends StatelessWidget {
  final String pdfPath;
  final int pageNumber;

  const PaperPage({required this.pdfPath, required this.pageNumber, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [_buildPdfViewer(), _buildGestureBlocker(context)],
    );
  }

  /// Configures the SfPdfViewer with specific settings.
  Widget _buildPdfViewer() {
    return SfPdfViewer.asset(
      pdfPath,
      canShowScrollHead: true,
      interactionMode: PdfInteractionMode.selection,
      initialPageNumber: pageNumber,
      canShowScrollStatus: true,
      maxZoomLevel: 10,
      initialZoomLevel: 1,
      pageLayoutMode: PdfPageLayoutMode.single,
      scrollDirection: PdfScrollDirection.horizontal,
      initialScrollOffset: const Offset(10, 80),
    );
  }

  /// Blocks drag gestures over the PDF viewer.
  Widget _buildGestureBlocker(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) {},
      onPanUpdate: (_) {},
      onPanEnd: (_) {},
      child: SizedBox.expand(
        // Use SizedBox.expand instead of Container with MediaQuery
        child: ColoredBox(
          color: Colors.black12,
          child: const Text('asdf'), // Consider removing if not needed
        ),
      ),
    );
  }
}
