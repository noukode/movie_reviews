import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api_service.dart';

class AddEditReviewScreen extends StatefulWidget {
  final String username;
  final Map<String, dynamic>? review;

  const AddEditReviewScreen({Key? key, required this.username, this.review}) : super(key: key);

  @override
  _AddEditReviewScreenState createState() => _AddEditReviewScreenState();
}

class _AddEditReviewScreenState extends State<AddEditReviewScreen> {
  final _titleController = TextEditingController();
  final _ratingController = TextEditingController();
  final _commentController = TextEditingController();
  final _apiService = ApiService();

  String _selectedImage = '';
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    if (widget.review != null) {
      _titleController.text = widget.review!['title'];
      _ratingController.text = widget.review!['rating'].toString();
      _commentController.text = widget.review!['comment'];
      _isLiked = widget.review!['isLiked'] == 1 ? true : false;

      setState(() {
        _selectedImage = widget.review!['poster'];
      });
    }
  }

  void _saveReview() async {
    final title = _titleController.text.trim();
    final rating = int.tryParse(_ratingController.text) ?? 0;
    final comment = _commentController.text.trim();

    // Validasi input
    if (title.isEmpty || rating < 1 || rating > 10 || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data tidak valid. Judul, komentar, dan rating (1-10) harus diisi.')),
      );
      return;
    }

    bool success;
    if (widget.review == null) {
      // Tambah review baru
      success = await _apiService.addReview(widget.username, title, rating, comment, _selectedImage, _isLiked);
    } else {
      // Edit review
      success = await _apiService.updateReview(widget.review!['_id'], widget.username, title, rating, comment, _selectedImage, _isLiked);
    }

    if (success) {
      Navigator.pop(context, true); // Berhasil, kembali ke layar sebelumnya
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan review')),
      );
    }
  }

  Future _pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage == null) return;

    final bytes = File(returnedImage.path).readAsBytesSync();

    String imageInBase64 = base64Encode(bytes);

    setState(() {
      _selectedImage = imageInBase64;
    });
  }

  Image _showImage(fileSelected) {
    Uint8List bytes = base64Decode(fileSelected);

    return Image.memory(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.review != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Review' : 'Tambah Review')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Judul Film'),
                readOnly: isEditMode, // Nonaktifkan input jika dalam mode edit
              ),
              TextField(
                controller: _ratingController,
                decoration: InputDecoration(labelText: 'Rating (1-10)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(labelText: 'Komentar'),
              ),
              MaterialButton(
                color: Colors.lightBlue,
                child: Text(
                  "Pilih Gambar",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  _pickImageFromGallery();
                },
              ),
              const SizedBox(height: 20,),
              Container(
                child: _selectedImage != '' ? _showImage(_selectedImage) : Text("Your selected Image will show in here"),
              ),
              ElevatedButton(
                onPressed: _saveReview,
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      )
    );
  }
}
