import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                movie.posterUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF1A1D25),
                  child: const Center(child: Icon(Icons.movie_outlined, size: 44)),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFF1A1D25),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFC107)),
              const SizedBox(width: 3),
              Text(movie.rating.toStringAsFixed(1),
                  style: TextStyle(color: Colors.grey.shade400)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  movie.releaseDate.isEmpty ? 'N/A' : movie.releaseDate.substring(0, 4),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
