import 'package:dart_lesson/configuration/configuration.dart';
import 'package:dart_lesson/domain/api_client/account_api_client.dart';
import 'package:dart_lesson/domain/api_client/movie_api_client.dart';
import 'package:dart_lesson/domain/data_providers/session_data_provider.dart';
import 'package:dart_lesson/domain/entity/popular_movie_response.dart';
import 'package:dart_lesson/domain/local_entity/movie_details_local.dart';

class MovieService {
  final _movieApiClient = MovieApiClient();
  final _sessionDataProvider = SessionDataProvider();
  final _accountApiClient = AccountApiClient();

  Future<PopularMovieResponse> popularMovie(int page, String locale) async =>
      _movieApiClient.popularMovie(
        page,
        locale,
        Configuration.apiKey,
      );

  Future<PopularMovieResponse> searchMovie(
    int page,
    String locale,
    String query,
  ) async =>
      _movieApiClient.searchMovie(
        page,
        locale,
        query,
        Configuration.apiKey,
      );

  Future<MovieDetailsLocal> loadDetails({
    required int movieId,
    required String locale,
    required String apiKey,
  }) async {
    final movieDetails = await _movieApiClient.movieDetails(
        movieId, locale, Configuration.apiKey);
    final sessionId = await _sessionDataProvider.getSessionId();
    var isFavourite = false;
    if (sessionId != null) {
      isFavourite = await _movieApiClient.isFavorite(
          movieId, sessionId, Configuration.apiKey);
    }

    return MovieDetailsLocal(details: movieDetails, isFavorite: isFavourite);
  }

  Future<void> updateFavorite({
    required int movieId,
    required bool isFavorite,
  }) async {
    final sessionId = await _sessionDataProvider.getSessionId();
    final accountId = await _sessionDataProvider.getAccountId();

    if (sessionId == null || accountId == null) return;
    await _accountApiClient.markAsFavorite(
      accountId: accountId,
      sessionId: sessionId,
      mediaType: MediaType.movie,
      mediaId: movieId,
      isFavorite: isFavorite,
    );
  }
}
