import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_flip/page_flip.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// A widget that displays PDF text content with a page-flip effect.
class PdfFlipViewer extends StatefulWidget {
  /// The asset path to the PDF file.
  final String path;

  const PdfFlipViewer({super.key, required this.path});

  @override
  State<PdfFlipViewer> createState() => _PdfFlipViewerState();
}

class _PdfFlipViewerState extends State<PdfFlipViewer> {
  final GlobalKey<PageFlipWidgetState> _pageFlipKey =
      GlobalKey<PageFlipWidgetState>();
  List<String> _displayPages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _extractAndPrepareText();
  }

  /// Extracts text from PDF and prepares it for display.
  Future<void> _extractAndPrepareText() async {
    try {
      final pdfBytes = await _loadPdfBytes();
      final document = PdfDocument(inputBytes: pdfBytes);
      await _processPdfPages(document);
      document.dispose();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _handleError(e);
    }
  }

  /// Loads PDF bytes from assets.
  Future<Uint8List> _loadPdfBytes() async {
    final data = await rootBundle.load(widget.path);
    return data.buffer.asUint8List();
  }

  /// Processes each PDF page and splits text into display pages.
  Future<void> _processPdfPages(PdfDocument document) async {
    final extractor = PdfTextExtractor(document);
    for (int i = 0; i < document.pages.count; i++) {
      final text = extractor.extractText(startPageIndex: i, endPageIndex: i);
      _displayPages.addAll(_splitTextForDisplay(text));
    }
  }

  /// Splits text into multiple pages based on size constraints.
  List<String> _splitTextForDisplay(String text) {
    const int maxLinesPerPage = 40;
    const int maxCharsPerLine = 80;

    List<String> pages = [];
    List<String> lines = [];

    for (var line in text.split('\n')) {
      while (line.isNotEmpty) {
        final end =
            line.length > maxCharsPerLine ? maxCharsPerLine : line.length;
        lines.add(line.substring(0, end));
        line = line.substring(end);
      }
    }

    String currentPage = '';
    int lineCount = 0;

    for (var line in lines) {
      if (lineCount >= maxLinesPerPage) {
        pages.add(currentPage.trim());
        currentPage = '';
        lineCount = 0;
      }
      currentPage += '$line\n';
      lineCount++;
    }

    if (currentPage.isNotEmpty) {
      pages.add(currentPage.trim());
    }

    return pages.isEmpty ? [text] : pages; // Ensure at least one page
  }

  /// Handles errors during PDF processing.
  void _handleError(dynamic error) {
    log('Error processing PDF: $error');
    if (mounted) {
      setState(() {
        _isLoading = false;
        _displayPages = ['Error loading PDF: $error'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Flip Viewer')),
      body: _buildBody(),
    );
  }

  /// Builds the main content based on loading state.
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_displayPages.isEmpty) {
      return const Center(child: Text('No text found in PDF'));
    }
    return PageFlipWidget(
      key: _pageFlipKey,
      backgroundColor: Colors.grey,
      duration: const Duration(milliseconds: 800),
      children: [
        for (int i = 0; i < _displayPages.length; i++)
          _PageContent(
            text: _displayPages[i],
            pageNumber: i + 1,
            isLastPage: i == _displayPages.length - 1,
          ),
      ],
    );
  }
}

/// A widget representing a single page of content.
class _PageContent extends StatelessWidget {
  final String text;
  final int pageNumber;
  final bool isLastPage;

  const _PageContent({
    required this.text,
    required this.pageNumber,
    required this.isLastPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(color: Colors.grey, spreadRadius: 2, blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Page $pageNumber',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              isLastPage && text.trim().isEmpty ? 'The End' : text,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
