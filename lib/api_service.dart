import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://crudcrud.com/api/3c065e0bcb86471daf0058baa0af35ad';

  Future<bool> registerUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkUsernameExists(String username) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
      if (response.statusCode == 200) {
        final List users = jsonDecode(response.body);
        return users.any((user) => user['username'] == username);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginUser(String username, String password) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
      if (response.statusCode == 200) {
        final List users = jsonDecode(response.body);
        return users.any((user) => user['username'] == username && user['password'] == password);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getReviews(String username) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reviews'));
      if (response.statusCode == 200) {
        final List reviews = jsonDecode(response.body);
        return reviews.where((review) => review['username'] == username).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> addReview(String username, String title, int rating, String comment, String poster, bool isLiked) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'title': title, 'rating': rating, 'comment': comment, 'poster': poster, 'isLiked': isLiked ? 1 : 0}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error adding review: $e');
      return false;
    }
  }

  Future<bool> updateReview(String id, String username, String title, int rating, String comment, String poster, bool isLiked) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reviews/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'title': title, 'rating': rating, 'comment': comment, 'poster': poster, 'isLiked': isLiked ? 1 : 0}),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating review: $e');
      return false;
    }
  }

 Future<bool> deleteReview(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/reviews/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }

  Future<bool> doLike(Map item) async {
    try {
      int isLiked = item['isLiked'] == 1 ? 0 : 1;
      final response = await http.put(
        Uri.parse('$baseUrl/reviews/${item['_id']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': item['username'], 'title': item['title'], 'rating': item['rating'], 'comment': item['comment'], 'poster': item['poster'], 'isLiked': isLiked}),
      );
      print('lewat ${item['_id']}');
      print('isLiked ${item['isLiked']} ${isLiked}');
      print('response ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error while liking / unlike review: $e');
      return false;
    }
  }
}
