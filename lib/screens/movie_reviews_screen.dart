import 'dart:convert';

import 'package:flutter/material.dart';
import '../api_service.dart';
import 'add_edit_review_screen.dart';

class MovieReviewsScreen extends StatefulWidget {
  final String username;

  const MovieReviewsScreen({Key? key, required this.username}) : super(key: key);

  @override
  _MovieReviewsScreenState createState() => _MovieReviewsScreenState();
}

class _MovieReviewsScreenState extends State<MovieReviewsScreen> {
  final _apiService = ApiService();
  List<dynamic> _reviews = [];

  String statusText = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviews = await _apiService.getReviews(widget.username);
    if (reviews.isEmpty) {
      statusText = 'Belum ada review. Tambahkan sekarang!';
    }
    setState(() {
      _reviews = reviews;
    });
  }

  void _deleteReview(String id) async {
    final success = await _apiService.deleteReview(id);
    if (success) {
      _loadReviews();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus review')),
      );
    }
  }

  void _doLike(Map item) async {
    final success = await _apiService.doLike(item);

    if (success) {
      _loadReviews();
      print('Refresh');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Something went wrong')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Film Saya'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditReviewScreen(username: widget.username),
                ),
              );
              if (result == true) _loadReviews();
            },
          ),
        ],
      ),
      body: _reviews.isEmpty
          ? Center(child: Text(statusText))
          : ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return ListTile(
                  title: Text(review['title']),
                  subtitle: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.star, color: Colors.amber[400], size: 12,),
                          Text(' '),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${review['rating']}/10'),
                          Text(review['comment']),
                        ],
                      )
                    ],
                  ),
                  isThreeLine: true,
                  leading: SizedBox(
                    height: 100.0,
                    width: 50.0,
                    child: review['poster'] != '' ? Image.memory(base64Decode(review['poster'])) : Text('No Image', textAlign: TextAlign.center,),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          review['isLiked'] == 0 ? Icons.thumb_up_outlined : Icons.thumb_up,
                          color: review['isLiked'] == 0 ? Colors.black87 : Colors.lightBlue,
                        ),
                        onPressed: () => _doLike(review),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditReviewScreen(
                                username: widget.username,
                                review: review,
                              ),
                            ),
                          );
                          if (result == true) _loadReviews();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteReview(review['_id']),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
