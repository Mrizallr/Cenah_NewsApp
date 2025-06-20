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
      // ignore: avoid_print
      print('Error di fetchAllArticles: $e');
      throw Exception('Tidak dapat terhubung ke server.');
    }
  }

  Future<NewsResponse> fetchMyArticles() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseApiUrl/news/user/me'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return NewsResponse.fromJson(
          json.decode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception(
          'Gagal memuat artikel Anda (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception(
        'Gagal memuat artikel Anda: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  Future<bool> deleteArticle(String articleId) async {
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
            Uri.parse('$baseApiUrl/news/$articleId'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData['success'] == true;
      } else {
        throw Exception(
          'Gagal menghapus artikel (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception(
        'Gagal menghapus artikel: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  Future<bool> createArticle(Map<String, dynamic> articleData) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseApiUrl/news'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(articleData),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData['success'] == true;
      } else {
        throw Exception(
          'Gagal membuat artikel (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception(
        'Gagal membuat artikel: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  Future<List<String>> fetchCategoriesFromNews() async {
    try {
      final List<NewsArticle> allNews = await fetchAllArticles();
      final Set<String> uniqueCategories = {};
      for (var news in allNews) {
        // ignore: unnecessary_null_comparison
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

  Future<NewsArticle> fetchArticleById(String articleId) async {
    if (articleId.isEmpty) {
      throw Exception('ID artikel tidak boleh kosong');
    }

    try {
      final response = await http
          .get(Uri.parse('$baseApiUrl/news/$articleId'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return NewsArticle.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['message'] ?? 'Gagal memuat artikel');
        }
      } else {
        throw Exception(
          'Gagal memuat artikel (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception(
        'Gagal memuat artikel: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  Future<bool> updateArticle(
    String articleId,
    Map<String, dynamic> articleData,
  ) async {
    if (articleId.isEmpty) {
      throw Exception('ID artikel tidak boleh kosong');
    }

    final token = await _getToken();
    if (token == null) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    try {
      final response = await http
          .put(
            Uri.parse('$baseApiUrl/news/$articleId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(articleData),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData['success'] == true;
      } else {
        throw Exception(
          'Gagal memperbarui artikel (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception(
        'Gagal memperbarui artikel: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

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

  Future<List<NewsArticle>> fetchSavedArticles() async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Anda harus login untuk melihat artikel tersimpan.');

    final url = Uri.parse('$baseApiUrl/news/bookmarks/list');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      if (jsonData['success'] == true && jsonData['data'] != null) {
        final List<dynamic> bookmarksData = jsonData['data'];
        return bookmarksData
            .map((json) => NewsArticle.fromJson(json['article']))
            .toList();
      }
      return [];
    } else {
      final errorData = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(
        errorData['message'] ?? 'Gagal memuat artikel tersimpan.',
      );
    }
  }

  Future<bool> addBookmark(String articleId) async {
    final token = await _getToken();
    if (token == null)
      throw Exception('Anda harus login untuk menyimpan artikel.');

    final url = Uri.parse('$baseApiUrl/news/$articleId/bookmark');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true; // Berhasil disimpan
    } else {
      final errorData = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['message'] ?? 'Gagal menyimpan artikel.');
    }
  }

  Future<bool> removeBookmark(String articleId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Sesi tidak valid.');

    final url = Uri.parse('$baseApiUrl/news/$articleId/bookmark');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true; // Berhasil dihapus
    } else {
      final errorData = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['message'] ?? 'Gagal menghapus simpanan.');
    }
  }

  Future<bool> checkBookmarkStatus(String articleId) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('$baseApiUrl/news/$articleId/bookmark');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      if (jsonData['success'] == true && jsonData['data'] != null) {
        return jsonData['data']['isSaved'] ?? false;
      }
    }
    return false;
  }
}
