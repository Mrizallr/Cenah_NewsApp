import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cenah_news/src/models/news_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsService {
  final String baseApiUrl = 'https://rest-api-berita.vercel.app/api/v1';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Pastikan key token sesuai dengan yang disimpan saat login di AuthProvider
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

  // Mengambil semua berita dari API untuk mendapatkan kategori
  Future<List<NewsArticle>> fetchAllArticles() async {
    final url = Uri.parse('$baseApiUrl/news');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> newsData = responseData['data']['articles'];
        return newsData.map((json) => NewsArticle.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat semua artikel dari server');
      }
    } catch (e) {
      print('Error di fetchAllArticles: $e');
      throw Exception('Tidak dapat terhubung ke server.');
    }
  }

  // Mengambil daftar kategori unik dari semua berita
  Future<List<String>> fetchCategoriesFromNews() async {
    try {
      final List<NewsArticle> allNews = await fetchAllArticles();
      final Set<String> uniqueCategories = {};
      for (var news in allNews) {
        if (news.category != null && news.category!.isNotEmpty) {
          uniqueCategories.add(news.category!);
        }
      }
      return uniqueCategories.toList();
    } catch (e) {
      print('Error di fetchCategoriesFromNews: $e');
      throw Exception('Gagal mengambil daftar kategori.');
    }
  }

  // Mengambil berita terkait berdasarkan kategori
  Future<List<NewsArticle>> fetchRelatedArticles(
    String category, {
    int limit = 3,
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
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }


  // --- FUNGSI-FUNGSI BARU UNTUK BOOKMARK ---

  /// GET /news/bookmarks/list - Mengambil daftar artikel yang di-bookmark
  Future<List<NewsArticle>> fetchSavedArticles() async {
    final token = await _getToken();
    if (token == null) throw Exception('Anda harus login untuk melihat artikel tersimpan.');

    final url = Uri.parse('$baseApiUrl/news/bookmarks/list');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      if (jsonData['success'] == true && jsonData['data'] != null) {
        final List<dynamic> bookmarksData = jsonData['data'];
        return bookmarksData.map((json) => NewsArticle.fromJson(json['article'])).toList();
      }
      return [];
    } else {
       final errorData = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['message'] ?? 'Gagal memuat artikel tersimpan.');
    }
  }

  /// POST /news/{id}/bookmark - Menyimpan artikel
  Future<void> addBookmark(String articleId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Anda harus login untuk menyimpan artikel.');

    final url = Uri.parse('$baseApiUrl/news/$articleId/bookmark');
    final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode != 200 && response.statusCode != 201) {
       final errorData = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['message'] ?? 'Gagal menyimpan artikel.');
    }
  }

  /// DELETE /news/{id}/bookmark - Menghapus artikel dari simpanan
  Future<void> removeBookmark(String articleId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Sesi tidak valid.');

    final url = Uri.parse('$baseApiUrl/news/$articleId/bookmark');
    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode != 200) {
      final errorData = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['message'] ?? 'Gagal menghapus simpanan.');
    }
  }

  /// GET /news/{id}/bookmark - Mengecek status bookmark
  Future<bool> checkBookmarkStatus(String articleId) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('$baseApiUrl/news/$articleId/bookmark');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      if (jsonData['success'] == true && jsonData['data'] != null) {
          return jsonData['data']['isSaved'] ?? false;
      }
    }
    return false;
  }
}
