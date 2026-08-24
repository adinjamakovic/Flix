import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ReportPreview extends StatelessWidget {
  const ReportPreview({
    super.key,
    required this.title,
    required this.fileName,
    required this.buildReport,
  });

  final String title;
  final String fileName;
  final Future<Uint8List> Function() buildReport;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        build: (PdfPageFormat format) => buildReport(),
        pdfFileName: fileName,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        initialPageFormat: PdfPageFormat.a4,
        padding: const EdgeInsets.all(24),
      ),
    );
  }
}
