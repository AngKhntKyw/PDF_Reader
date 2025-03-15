import 'package:flutter/material.dart';
import 'package:pdf_reader/pages/pdf_page_3.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      home: PdfTextViewer(path: 'assets/pdfs/cv.pdf'),
      // home: RealisticPageCurlDemo(),
    );
  }
}
