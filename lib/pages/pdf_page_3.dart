import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_flip/page_flip.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfTextViewer extends StatefulWidget {
  final String path;
  const PdfTextViewer({super.key, required this.path});

  @override
  State<PdfTextViewer> createState() => _PdfTextViewerState();
}

class _PdfTextViewerState extends State<PdfTextViewer> {
  bool isLoading = true;
  List<String> displayPages = [];
  late PageController _pageController;
  bool isListView = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);
    extractAndSplitText();
  }

  Future<void> extractAndSplitText() async {
    try {
      final data = await rootBundle.load(widget.path);
      final pdfBytes = data.buffer.asUint8List();
      final document = PdfDocument(inputBytes: pdfBytes);

      // Extract text and split into pages that fit the screen
      for (int i = 0; i < document.pages.count; i++) {
        final text = PdfTextExtractor(
          document,
        ).extractText(startPageIndex: i, endPageIndex: i);
        final splitPages = _splitTextForDisplay(text);
        displayPages.addAll(splitPages);
      }

      document.dispose();
      setState(() => isLoading = false);
    } catch (e) {
      log('Error extracting PDF text: $e');
      setState(() {
        isLoading = false;
        displayPages = ['Error loading PDF: $e'];
      });
    }
  }

  List<String> _splitTextForDisplay(String text) {
    const maxLinesPerPage = 40; // Adjust based on your needs
    const maxCharsPerLine = 80; // Adjust based on your needs

    List<String> pages = [];
    List<String> lines = [];

    // Split text into lines
    var currentLines = text.split('\n');

    for (var line in currentLines) {
      if (line.length > maxCharsPerLine) {
        // Split long lines
        while (line.isNotEmpty) {
          int end =
              line.length > maxCharsPerLine ? maxCharsPerLine : line.length;
          lines.add(line.substring(0, end));
          line = line.substring(end);
        }
      } else {
        lines.add(line);
      }
    }

    // Group lines into pages
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

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Text Viewer'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isListView = !isListView;
              });
            },
            icon: Icon(isListView ? Icons.list : Icons.grid_4x4),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : displayPages.isEmpty
              ? const Center(child: Text('No text found in PDF'))
              : isListView
              ? PageFlipWidget(
                children: List.generate(displayPages.length, (index) {
                  return buildPage(displayPages[index], index);
                }),
              )
              : SfPdfViewer.asset(
                widget.path,
                canShowScrollHead: true,
                interactionMode: PdfInteractionMode.selection,
                initialPageNumber: 0,
                canShowScrollStatus: true,
                maxZoomLevel: 10,
                initialZoomLevel: 1,
                pageLayoutMode: PdfPageLayoutMode.continuous,
                scrollDirection: PdfScrollDirection.vertical,
                initialScrollOffset: const Offset(10, 80),
              ),
    );
  }

  Widget buildPage(String text, int pageNumber) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
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
            'Page ${pageNumber + 1}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16.0))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
