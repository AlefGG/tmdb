import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dart_lesson/configuration/configuration.dart';
import 'package:dart_lesson/domain/api_client/movie_api_client.dart';
import 'package:dart_lesson/domain/entity/movie.dart';
import 'package:dart_lesson/domain/entity/popular_movie_response.dart';

part 'movie_list_event.dart';
part 'movie_list_state.dart';

class MovieListBloc extends Bloc<MovieListEvent, MovieListState> {
  final _movieApiClient = MovieApiClient();

  MovieListBloc(
    MovieListState initialState,
  ) : super(initialState) {
    on<MovieListEvent>((event, emit) async {
      if (event is MovieListLoadNextPageEvent) {
        await onMovieListLoadNextPageEvent(event, emit);
      } else if (event is MovieListLoadResetEvent) {
        await onMovieListLoadResetEvent(event, emit);
      } else if (event is MovieListLoadSearchMovieEvent) {
        await onMovieListLoadSearchMovieEvent(event, emit);
      }
    }, transformer: sequential());
  }

  Future<void> onMovieListLoadNextPageEvent(
    MovieListLoadNextPageEvent event,
    Emitter<MovieListState> emit,
  ) async {
    if (state.isSearchMode) {
      final container = await _loadNextPage(
        state.searchMovieContainer,
        (nextPage) async {
          final result = await _movieApiClient.searchMovie(
            nextPage,
            event.locale,
            state.searchQuery,
            Configuration.apiKey,
          );
          return result;
        },
      );
      if (container != null) {
        final newState = state.copyWith(searchMovieContainer: container);
        emit(newState);
      }
    } else {
      final container = await _loadNextPage(
        state.popularMovieContainer,
        (nextPage) async {
          final result = await _movieApiClient.popularMovie(
            nextPage,
            event.locale,
            Configuration.apiKey,
          );
          return result;
        },
      );
      if (container != null) {
        final newState = state.copyWith(popularMovieContainer: container);
        emit(newState);
      }
    }
  }

  Future<MovieListContainer?> _loadNextPage(
    MovieListContainer container,
    Future<PopularMovieResponse> Function(int) loader,
  ) async {
    if (container.isComplete) return null;
    final nextPage = state.popularMovieContainer.currentPage + 1;
    final result = await loader(nextPage);

    final movies = List<Movie>.from(container.movies)..addAll(result.movies);
    final newContainer = container.copyWith(
      movies: movies,
      currentPage: result.page,
      totalPage: result.totalPages,
    );
    return newContainer;
  }

  Future<void> onMovieListLoadResetEvent(
    MovieListLoadResetEvent event,
    Emitter<MovieListState> emit,
  ) async {
    emit(const MovieListState.initial());
  }

  Future<void> onMovieListLoadSearchMovieEvent(
    MovieListLoadSearchMovieEvent event,
    Emitter<MovieListState> emit,
  ) async {
    if (state.searchQuery == event.query) return;
    final newState = state.copyWith(
      searchQuery: event.query,
      searchMovieContainer: const MovieListContainer.initial(),
    );
    emit(newState);
  }
}
