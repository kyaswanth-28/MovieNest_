import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_api_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final _api = MovieApiService();
  late Movie _movie;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final detailed = await _api.getMovieDetails(widget.movie.id);
      if (!mounted) return;
      setState(() {
        _movie = detailed;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _duration(int? runtime) {
    if (runtime == null || runtime <= 0) return 'N/A';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 360,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _movie.backdropUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFF171A22)),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.10),
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Text(
                      _movie.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_loading) const LinearProgressIndicator(),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Detailed data could not be loaded. Showing available information.',
                        style: TextStyle(color: Colors.orange.shade300),
                      ),
                    ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoChip(icon: Icons.star_rounded,
                          text: _movie.rating.toStringAsFixed(1)),
                      _InfoChip(icon: Icons.calendar_month_outlined,
                          text: _movie.releaseDate.isEmpty ? 'N/A' : _movie.releaseDate),
                      _InfoChip(icon: Icons.language, text: _movie.language),
                      _InfoChip(icon: Icons.schedule, text: _duration(_movie.runtime)),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text('Overview',
                      style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    _movie.overview.isEmpty ? 'No overview available.' : _movie.overview,
                    style: TextStyle(
                      height: 1.6,
                      fontSize: 15,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF171A22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: Colors.white70),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}
