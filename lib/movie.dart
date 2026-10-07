class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String backdropPath;
  final String overview;
  final double rating;
  final String releaseDate;
  final String language;
  final int? runtime;

  // TMDB genre IDs
  final List<int> genreIds;

  const Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.overview,
    required this.rating,
    required this.releaseDate,
    required this.language,
    this.runtime,
    this.genreIds = const [],
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<int> parsedGenreIds = [];

    // Used by TMDB movie lists
    if (json['genre_ids'] is List) {
      parsedGenreIds = (json['genre_ids'] as List)
          .whereType<num>()
          .map((id) => id.toInt())
          .toList();
    }

    // Used by TMDB movie details
    if (json['genres'] is List) {
      parsedGenreIds = (json['genres'] as List)
          .whereType<Map>()
          .map((genre) => genre['id'])
          .whereType<num>()
          .map((id) => id.toInt())
          .toList();
    }

    return Movie(
      id: json['id'] as int,

      title: (json['title'] ?? json['name'] ?? 'Untitled').toString(),

      posterPath: (json['poster_path'] ?? '').toString(),

      backdropPath: (json['backdrop_path'] ?? '').toString(),

      overview: (json['overview'] ?? 'No overview available.').toString(),

      rating: (json['vote_average'] as num?)?.toDouble() ?? 0,

      releaseDate:
      (json['release_date'] ?? json['first_air_date'] ?? '').toString(),

      language:
      (json['original_language'] ?? 'N/A').toString().toUpperCase(),

      runtime: (json['runtime'] as num?)?.toInt(),

      genreIds: parsedGenreIds,
    );
  }

  String get posterUrl {
    if (posterPath.isEmpty) {
      return '';
    }

    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get backdropUrl {
    if (backdropPath.isEmpty) {
      return posterUrl;
    }

    return 'https://image.tmdb.org/t/p/w1280$backdropPath';
  }
}