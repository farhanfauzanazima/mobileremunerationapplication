import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  int _currentPage = 0;
  int _totalPages  = 0;
  bool _isReady    = false;
  PDFViewController? _pdfController;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as Map<String, dynamic>;
    final String filePath = args['path'];
    final String title    = args['title'] ?? 'Slip Gaji';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_isReady)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: filePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            onRender: (pages) {
              setState(() {
                _totalPages = pages ?? 0;
                _isReady    = true;
              });
            },
            onViewCreated: (controller) {
              _pdfController = controller;
            },
            onPageChanged: (page, total) {
              setState(() {
                _currentPage = page ?? 0;
                _totalPages  = total ?? 0;
              });
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $error'),
                  backgroundColor: AppTheme.accent,
                ),
              );
            },
          ),

          // Loading indicator
          if (!_isReady)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primary),
                  SizedBox(height: 16),
                  Text('Memuat PDF...',
                      style: TextStyle(color: AppTheme.textMuted)),
                ],
              ),
            ),
        ],
      ),

      // Navigasi halaman
      bottomNavigationBar: _isReady && _totalPages > 1
          ? Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _currentPage > 0
                        ? () => _pdfController?.setPage(
                            _currentPage - 1)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    color: AppTheme.primary,
                  ),
                  Text(
                    'Halaman ${_currentPage + 1} dari $_totalPages',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 13),
                  ),
                  IconButton(
                    onPressed: _currentPage < _totalPages - 1
                        ? () => _pdfController?.setPage(
                            _currentPage + 1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    color: AppTheme.primary,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}