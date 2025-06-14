import 'package:flutter/material.dart';
import 'services/legal_documents_service.dart';

class TermsOfUseScreen extends StatefulWidget {
  const TermsOfUseScreen({super.key});

  @override
  State<TermsOfUseScreen> createState() => _TermsOfUseScreenState();
}

class _TermsOfUseScreenState extends State<TermsOfUseScreen> {
  LegalDocument? _termsDocument;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTermsOfUse();
  }

  Future<void> _loadTermsOfUse() async {
    try {
      final document = await LegalDocumentsService.getTermsOfUse();
      setState(() {
        _termsDocument = document;
        _isLoading = false;
        if (document == null) {
          _errorMessage = 'Failed to load Terms of Use.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred while loading Terms of Use: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_termsDocument?.title ?? 'Terms of Use'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadTermsOfUse();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_termsDocument == null) {
      return const Center(
        child: Text(
          'Terms of Use not found.',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _termsDocument!.content,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            'Version: ${_termsDocument!.version}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            'Last Updated: ${_formatDate(_termsDocument!.updatedAt)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
