import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cenah_news/src/models/news_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsService {
  final String baseApiUrl = 'https://rest-api-berita.vercel.app/api/v1';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Mengambil daftar berita utama atau berdasarkan kategori
  Future<NewsResponse> fetchNews(String apiUrl) async {
    if (apiUrl.isEmpty) {
      throw Exception("URL tidak boleh kosong");
    }

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return NewsResponse.fromJson(
          json.decode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception('Gagal memuat berita (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception(
        'Gagal memuat berita: Terjadi kesalahan jaringan atau parsing.',
      );
    }
  }

  // Mengambil berita terkait berdasarkan kategori
  Future<List<NewsArticle>> fetchRelatedArticles(
    String category, {
    int limit = 3, // Ambil 3 berita terkait secara default
  }) async {
    try {
      final response = await http
          .get(Uri.parse('$baseApiUrl/news?category=$category&limit=$limit'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        if (jsonData['success'] == true &&
            jsonData['data'] != null &&
            jsonData['data']['articles'] != null) {
          return List<NewsArticle>.from(
            jsonData['data']['articles'].map((x) => NewsArticle.fromJson(x)),
          );
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Mengecek status bookmark sebuah artikel
  Future<bool> checkBookmarkStatus(String articleId) async {
    if (articleId.isEmpty) {
      throw Exception('ID artikel tidak boleh kosong');
    }

    final token = await _getToken();
    if (token == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseApiUrl/news/$articleId/bookmark'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return jsonData['data']['isSaved'] ?? false;
        }
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Menambahkan artikel ke bookmark
  Future<bool> addBookmark(String articleId) async {
    if (articleId.isEmpty) {
      throw Exception('ID artikel tidak boleh kosong');
    }

    final token = await _getToken();
    if (token == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseApiUrl/news/$articleId/bookmark'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData['success'] == true;
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['message'] ?? 'Gagal menyimpan artikel');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  // Menghapus artikel dari bookmark
  Future<bool> removeBookmark(String articleId) async {
    if (articleId.isEmpty) {
      throw Exception('ID artikel tidak boleh kosong');
    }

    final token = await _getToken();
    if (token == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    try {
      final response = await http
          .delete(
            Uri.parse('$baseApiUrl/news/$articleId/bookmark'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData['success'] == true;
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['message'] ?? 'Gagal menghapus simpanan');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  // Fungsi-fungsi lain dari service Anda bisa diletakkan di sini...
}
