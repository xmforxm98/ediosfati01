import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

class TestUploadScreen extends StatefulWidget {
  const TestUploadScreen({super.key});

  @override
  State<TestUploadScreen> createState() => _TestUploadScreenState();
}

class _TestUploadScreenState extends State<TestUploadScreen> {
  bool _isUploading = false;
  String _uploadStatus = '';

  Future<void> _uploadTestImages() async {
    setState(() {
      _isUploading = true;
      _uploadStatus = 'Starting upload...';
    });

    try {
      final storage = FirebaseStorage.instance;

      // login1.png ~ login4.png 개별적으로 업로드
      for (int i = 1; i <= 4; i++) {
        setState(() {
          _uploadStatus += '\nReading login$i.png from assets...';
        });

        try {
          // assets에서 각 이미지 읽기
          final ByteData data = await rootBundle.load(
            'assets/images/backgrounds/login$i.png',
          );
          final Uint8List bytes = data.buffer.asUint8List();

          setState(() {
            _uploadStatus += '\nUploading login$i.png to Firebase Storage...';
          });

          final ref = storage.ref().child('images/backgrounds/login$i.png');

          await ref.putData(bytes);
          final url = await ref.getDownloadURL();

          setState(() {
            _uploadStatus += '\n✅ login$i.png uploaded successfully!';
            _uploadStatus += '\n📝 URL: $url\n';
          });
        } catch (e) {
          setState(() {
            _uploadStatus += '\n❌ Failed to upload login$i.png: $e\n';
          });
        }
      }

      setState(() {
        _uploadStatus += '\n🎉 Upload completed!';
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _uploadStatus = '❌ Error: $e';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Upload'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF1a1a1a),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Upload login1.png ~ login4.png to Firebase Storage',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadTestImages,
              child: Text(
                _isUploading ? 'Uploading...' : 'Upload Login Images',
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _uploadStatus,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
