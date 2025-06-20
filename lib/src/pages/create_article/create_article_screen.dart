import 'package:cenah_news/src/services/news_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateArticleScreen extends StatefulWidget {
  const CreateArticleScreen({super.key});

  @override
  State<CreateArticleScreen> createState() => _CreateArticleScreenState();
}

class _CreateArticleScreenState extends State<CreateArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController(
    text: "testinggggg",
  );
  final TextEditingController _contentController = TextEditingController(
    text:
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
  );
  final TextEditingController _readTimeController = TextEditingController(
    text: "3 menit",
  );
  final TextEditingController _imageUrlController = TextEditingController(
    text: "https://picsum.photos/200",
  );
  final TextEditingController _tagsController = TextEditingController(
    text: "tags",
  );

  String _category = 'Technology';
  bool _isTrending = false;
  bool _isLoading = false;
  final List<String> _tags = [];

  final List<String> _categories = [
    'Technology',
    'Sports',
    'Health',
    'Business',
    'Entertainment',
    'Science',
  ];

  Future<void> _submitArticle() async {
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
      ).createArticle(articleData);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel berhasil dibuat!')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Artikel Baru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _submitArticle,
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
              const SizedBox(height: 20),
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
              TextFormField(
                controller: _contentController,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Konten Artikel*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konten tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitArticle,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Simpan Artikel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
