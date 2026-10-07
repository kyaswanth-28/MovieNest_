import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie.dart';

class MovieApiException implements Exception {
  final String message;

  MovieApiException(this.message);

  @override
  String toString() => message;
}

class MovieApiService {
  static const String _apiKey =
  String.fromEnvironment('TMDB_API_KEY');

  static const String _baseUrl =
      'https://api.themoviedb.org/3';

  void _checkKey() {
    if (_apiKey.isEmpty) {
      throw MovieApiException(
        'TMDB API key is missing. '
            'Run with --dart-define=TMDB_API_KEY=YOUR_KEY',
      );
    }
  }

  // ------------------------------------------------------------
  // POPULAR MOVIES
  // ------------------------------------------------------------

  Future<List<Movie>> getPopularMovies() async {
    _checkKey();

    final uri = Uri.parse(
      '$_baseUrl/movie/popular'
          '?api_key=$_apiKey'
          '&language=en-US'
          '&page=1',
    );

    final response = await http.get(uri);

    return _parseMovieList(response);
  }

  // ------------------------------------------------------------
  // SEARCH MOVIES
  // ------------------------------------------------------------

  Future<List<Movie>> searchMovies(String query) async {
    _checkKey();

    final uri = Uri.parse(
      '$_baseUrl/search/movie'
          '?api_key=$_apiKey'
          '&language=en-US'
          '&query=${Uri.encodeQueryComponent(query)}'
          '&page=1'
          '&include_adult=false',
    );

    final response = await http.get(uri);

    return _parseMovieList(response);
  }

  // ------------------------------------------------------------
  // MOVIES BY CATEGORY / GENRE
  // ------------------------------------------------------------

  Future<List<Movie>> getMoviesByGenre(int genreId) async {
    _checkKey();

    final uri = Uri.parse(
      '$_baseUrl/discover/movie'
          '?api_key=$_apiKey'
          '&language=en-US'
          '&sort_by=popularity.desc'
          '&with_genres=$genreId'
          '&include_adult=false'
          '&page=1',
    );

    final response = await http.get(uri);

    return _parseMovieList(response);
  }

  // ------------------------------------------------------------
  // MOVIE DETAILS
  // ------------------------------------------------------------

  Future<Movie> getMovieDetails(int id) async {
    _checkKey();

    final uri = Uri.parse(
      '$_baseUrl/movie/$id'
          '?api_key=$_apiKey'
          '&language=en-US',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw MovieApiException(
        'Could not load movie details '
            '(${response.statusCode}).',
      );
    }

    return Movie.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  // ------------------------------------------------------------
  // PARSE MOVIE LIST
  // ------------------------------------------------------------

  List<Movie> _parseMovieList(http.Response response) {
    if (response.statusCode != 200) {
      throw MovieApiException(
        'Request failed (${response.statusCode}). '
            'Please try again.',
      );
    }

    final body =
    jsonDecode(response.body) as Map<String, dynamic>;

    final results =
        body['results'] as List<dynamic>? ?? [];

    return results
        .map(
          (item) => Movie.fromJson(
        item as Map<String, dynamic>,
      ),
    )
        .where(
          (movie) => movie.posterPath.isNotEmpty,
    )
        .toList();
  }
}