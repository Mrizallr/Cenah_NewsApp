import 'package:cenah_news/src/services/news_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditArticleScreen extends StatefulWidget {
  final String articleId;

  const EditArticleScreen({super.key, required this.articleId});

  @override
  State<EditArticleScreen> createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends State<EditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _readTimeController;
  late TextEditingController _imageUrlController;
  late TextEditingController _tagsController;

  String _category = 'Technology';
  bool _isTrending = false;
  bool _isLoading = false;
  bool _initialized = false;
  final List<String> _tags = [];

  final List<String> _categories = [
    'Technology',
    'Sports',
    'Health',
    'Business',
    'Entertainment',
    'Science',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _readTimeController = TextEditingController();
    _imageUrlController = TextEditingController();
    _tagsController = TextEditingController();

    _loadArticleData();
  }

  Future<void> _loadArticleData() async {
    setState(() => _isLoading = true);

    try {
      final article = await Provider.of<NewsService>(
        context,
        listen: false,
      ).fetchArticleById(widget.articleId);

      setState(() {
        _titleController.text = article.title;
        _contentController.text = article.content;
        _readTimeController.text = article.readTime;
        _imageUrlController.text = article.imageUrl;
        _category = article.category;
        _isTrending = article.isTrending;
        _tags.addAll(article.tags);
        _initialized = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat artikel: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateArticle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final articleData = {
        "title": _titleController.text,
        "category": _category,
        "readTime": _readTimeController.text,
        "imageUrl": _imageUrlController.text,
        "isTrending": _isTrending,
        "tags": _tags,
        "content": _contentController.text,
      };

      final success = await Provider.of<NewsService>(
        context,
        listen: false,
      ).updateArticle(widget.articleId, articleData);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel berhasil diperbarui!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addTag() {
    if (_tagsController.text.isNotEmpty &&
        !_tags.contains(_tagsController.text)) {
      setState(() {
        _tags.add(_tagsController.text.trim());
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _readTimeController.dispose();
    _imageUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized && _isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Artikel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _updateArticle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Artikel
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Artikel*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Kategori
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Kategori*',
                  border: OutlineInputBorder(),
                ),
                items:
                    _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _category = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Waktu Baca
              TextFormField(
                controller: _readTimeController,
                decoration: const InputDecoration(
                  labelText: 'Waktu Baca* (contoh: 5 menit)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Waktu baca tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // URL Gambar
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'URL gambar tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              if (_imageUrlController.text.isNotEmpty)
                Image.network(
                  _imageUrlController.text,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Text('Gambar tidak dapat dimuat'),
                        ),
                      ),
                ),
              const SizedBox(height: 20),

              // Trending Toggle
              SwitchListTile(
                title: const Text('Jadikan artikel trending'),
                value: _isTrending,
                onChanged: (bool value) {
                  setState(() {
                    _isTrending = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Tags
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tags'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tagsController,
                          decoration: const InputDecoration(
                            hintText: 'Tambahkan tag',
                            border: OutlineInputBorder(),
                          ),
                          onFieldSubmitted: (value) => _addTag(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTag,
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children:
                        _tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeTag(tag),
                          );
                        }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Konten Artikel
              TextFormField(
                controller: _contentController,
                maxLines: 15,
                decoration: const InputDecoration(
                  labelText: 'Konten Artikel*',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konten tidak boleh kosong';
                  }
                  if (value.length < 100) {
                    return 'Konten terlalu pendek (min 100 karakter)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateArticle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'SIMPAN PERUBAHAN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
