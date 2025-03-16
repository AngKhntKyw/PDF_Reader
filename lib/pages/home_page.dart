import 'package:flutter/material.dart';
import 'package:pdf_reader/pages/pdf_page_2.dart';
import 'package:pdf_reader/pages/pdf_page_3.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const PdfTextViewer(path: "assets/pdfs/cv.pdf"),
                ),
              );
            },
            title: Text("CV"),
            trailing: Icon(Icons.arrow_right),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const PdfTextViewer(path: "assets/pdfs/example.pdf"),
                ),
              );
            },
            title: Text("Mya Than Tint"),
            trailing: Icon(Icons.arrow_right),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const PdfPage2(path: "assets/pdfs/example.pdf"),
                ),
              );
            },
            title: Text("PDF Page"),
            trailing: Icon(Icons.arrow_right),
          ),
        ],
      ),
    );
  }
}
