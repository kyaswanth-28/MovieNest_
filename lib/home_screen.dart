import 'dart:async';

import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/movie_api_service.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MovieApiService _api = MovieApiService();

  final TextEditingController _searchController =
  TextEditingController();

  Timer? _debounce;

  List<Movie> _movies = [];

  bool _loading = true;

  String? _error;

  String _selectedCategory = 'All';

  // TMDB genre IDs
  final Map<String, int> _genreIds = {
    'Action': 28,
    'Comedy': 35,
    'Drama': 18,
    'Horror': 27,
    'Romance': 10749,
    'Animation': 16,
    'Thriller': 53,
  };

  final List<String> _categories = [
    'All',
    'Action',
    'Comedy',
    'Drama',
    'Horror',
    'Romance',
    'Animation',
    'Thriller',
  ];

  @override
  void initState() {
    super.initState();

    _loadPopularMovies();
  }

  @override
  void dispose() {
    _debounce?.cancel();

    _searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD POPULAR MOVIES
  // ============================================================

  Future<void> _loadPopularMovies() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final movies = await _api.getPopularMovies();

      if (!mounted) return;

      setState(() {
        _movies = movies;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  // ============================================================
  // LOAD CATEGORY
  // ============================================================

  Future<void> _loadCategory(String category) async {
    setState(() {
      _selectedCategory = category;
      _loading = true;
      _error = null;
    });

    try {
      List<Movie> movies;

      if (category == 'All') {
        movies = await _api.getPopularMovies();
      } else {
        final genreId = _genreIds[category];

        if (genreId == null) {
          movies = [];
        } else {
          movies = await _api.getMoviesByGenre(genreId);
        }
      }

      if (!mounted) return;

      setState(() {
        _movies = movies;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 500),
          () {
        _searchMovies(value);
      },
    );

    setState(() {});
  }

  Future<void> _searchMovies(String query) async {
    final text = query.trim();

    if (text.isEmpty) {
      _loadCategory(_selectedCategory);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final movies = await _api.searchMovies(text);

      if (!mounted) return;

      setState(() {
        _movies = movies;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),

      appBar: AppBar(
        backgroundColor: const Color(0xFF17141A),
        elevation: 0,

        title: const Text(
          'MovieNest',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading
                ? null
                : () {
              _loadCategory(_selectedCategory);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // SEARCH BAR
            _buildSearchBar(),

            // CATEGORY BAR
            _buildCategoryBar(),

            // MOVIES
            Expanded(
              child: _buildMovieContent(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        10,
      ),

      child: TextField(
        controller: _searchController,

        onChanged: _onSearchChanged,

        style: const TextStyle(
          color: Colors.white,
        ),

        decoration: InputDecoration(
          hintText: 'Search movies...',

          hintStyle: TextStyle(
            color: Colors.grey.shade500,
          ),

          prefixIcon: const Icon(
            Icons.search,
            color: Colors.white70,
          ),

          suffixIcon:
          _searchController.text.isNotEmpty
              ? IconButton(
            onPressed: () {
              _searchController.clear();

              _loadCategory(
                _selectedCategory,
              );

              setState(() {});
            },
            icon: const Icon(
              Icons.clear,
              color: Colors.white70,
            ),
          )
              : null,

          filled: true,

          fillColor: const Color(0xFF171A22),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          contentPadding:
          const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY BAR
  // ============================================================

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 50,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),

        itemCount: _categories.length,

        itemBuilder: (context, index) {
          final category = _categories[index];

          final selected =
              category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(
              right: 8,
            ),

            child: ChoiceChip(
              label: Text(category),

              selected: selected,

              onSelected: (_) {
                _searchController.clear();

                _loadCategory(category);
              },

              labelStyle: TextStyle(
                color: selected
                    ? Colors.black
                    : Colors.white,

                fontWeight: FontWeight.w600,
              ),

              selectedColor:
              const Color(0xFFFFB4A8),

              backgroundColor:
              const Color(0xFF171A22),

              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // MOVIE CONTENT
  // ============================================================

  Widget _buildMovieContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (_movies.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: () {
        return _loadCategory(
          _selectedCategory,
        );
      },

      child: LayoutBuilder(
        builder: (context, constraints) {
          int columns;

          if (constraints.maxWidth >= 1300) {
            columns = 5;
          } else if (constraints.maxWidth >= 1000) {
            columns = 4;
          } else if (constraints.maxWidth >= 700) {
            columns = 3;
          } else {
            columns = 2;
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              24,
            ),

            physics:
            const AlwaysScrollableScrollPhysics(),

            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,

              // Fixed height = no huge empty card.
              mainAxisExtent: 390,

              crossAxisSpacing: 14,

              mainAxisSpacing: 18,
            ),

            itemCount: _movies.length,

            itemBuilder: (context, index) {
              return _buildMovieCard(
                _movies[index],
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // MOVIE CARD
  // ============================================================

  Widget _buildMovieCard(Movie movie) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),

      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (_) {
              return MovieDetailScreen(
                movie: movie,
              );
            },
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF151820),

          borderRadius:
          BorderRadius.circular(14),
        ),

        clipBehavior: Clip.antiAlias,

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // POSTER
            SizedBox(
              height: 270,

              width: double.infinity,

              child: movie.posterUrl.isNotEmpty
                  ? Image.network(
                movie.posterUrl,

                fit: BoxFit.cover,

                errorBuilder:
                    (context, error, stack) {
                  return _posterPlaceholder();
                },

                loadingBuilder: (
                    context,
                    child,
                    progress,
                    ) {
                  if (progress == null) {
                    return child;
                  }

                  return _posterLoading();
                },
              )
                  : _posterPlaceholder(),
            ),

            // DETAILS
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                10,
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    movie.title,

                    maxLines: 1,

                    overflow:
                    TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 15,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      if (movie.releaseDate
                          .isNotEmpty)
                        Text(
                          movie.releaseDate
                              .length >= 4
                              ? movie.releaseDate
                              .substring(0, 4)
                              : movie.releaseDate,

                          style:
                          const TextStyle(
                            color:
                            Colors.white60,
                            fontSize: 12,
                          ),
                        ),

                      const SizedBox(width: 10),

                      const Icon(
                        Icons.star,
                        size: 14,
                        color:
                        Color(0xFFFFC107),
                      ),

                      const SizedBox(width: 3),

                      Text(
                        movie.rating
                            .toStringAsFixed(1),

                        style:
                        const TextStyle(
                          color:
                          Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    movie.overview,

                    maxLines: 2,

                    overflow:
                    TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: Colors.white54,

                      fontSize: 11,

                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // POSTER PLACEHOLDER
  // ============================================================

  Widget _posterPlaceholder() {
    return Container(
      width: double.infinity,

      color: const Color(0xFF242833),

      child: const Center(
        child: Icon(
          Icons.movie_outlined,

          color: Colors.white38,

          size: 42,
        ),
      ),
    );
  }

  // ============================================================
  // POSTER LOADING
  // ============================================================

  Widget _posterLoading() {
    return Container(
      width: double.infinity,

      color: const Color(0xFF242833),

      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,

          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(
              Icons.cloud_off,

              size: 60,

              color: Colors.white38,
            ),

            const SizedBox(height: 18),

            const Text(
              'Something went wrong',

              style: TextStyle(
                color: Colors.white,

                fontSize: 20,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _error ?? 'Unable to load movies.',

              textAlign: TextAlign.center,

              maxLines: 4,

              overflow:
              TextOverflow.ellipsis,

              style: const TextStyle(
                color: Colors.white54,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                _loadCategory(
                  _selectedCategory,
                );
              },

              icon: const Icon(
                Icons.refresh,
              ),

              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              Icons.movie_filter_outlined,

              size: 65,

              color: Colors.white30,
            ),

            SizedBox(height: 18),

            Text(
              'No movies found',

              style: TextStyle(
                color: Colors.white,

                fontSize: 20,

                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'Try another category or search.',

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}