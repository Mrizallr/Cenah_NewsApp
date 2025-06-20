import 'package:flutter/material.dart';
import 'package:cenah_news/src/models/news_model.dart';

class ArticleCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback? onTap;
  final List<Widget>? actions;

  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    article.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image),
                        ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                article.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text(article.category),
                    visualDensity: VisualDensity.compact,
                  ),
                  const Spacer(),
                  if (actions != null) ...actions!,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
