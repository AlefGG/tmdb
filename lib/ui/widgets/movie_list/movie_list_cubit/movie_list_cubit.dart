import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dart_lesson/domain/blocs/movie_list_bloc/movie_list_bloc.dart';
import 'package:dart_lesson/domain/entity/movie.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'movie_list_state.dart';

class MovieListCubit extends Cubit<MovieListCubitState> {
  final MovieListBloc movieListBloc;
  late final StreamSubscription<MovieListState> movieListBlocSubscription;
  late DateFormat _dateFormat;
  Timer? searchDeboubce;

  MovieListCubit({
    required this.movieListBloc,
  }) : super(
          MovieListCubitState(
            movies: <MovieListRowData>[],
            localeTag: '',
          ),
        ) {
    Future.microtask(
      () {
        _onState(movieListBloc.state);
        movieListBlocSubscription = movieListBloc.stream.listen(_onState);
      },
    );
  }

  void _onState(MovieListState state) {
    final movies = state.movies.map(_makeRowData).toList();
    final newState = this.state.copyWith(movies: movies);
    emit(newState);
  }

  void setupLocale(String localeTag) {
    if (state.localeTag == localeTag) return;
    final newState = state.copyWith(localeTag: localeTag);
    emit(newState);
    _dateFormat = DateFormat.yMMMMd(localeTag);
    movieListBloc.add(MovieListLoadResetEvent());
    movieListBloc.add(MovieListLoadNextPageEvent(localeTag));
  }

  void showedMovieAtIndex(int index) {
    if (index < state.movies.length - 1) return;
    movieListBloc.add(MovieListLoadNextPageEvent(state.localeTag));
  }

  void searchMovie(String text) async {
    searchDeboubce?.cancel();
    searchDeboubce = Timer(const Duration(milliseconds: 300), () async {
      movieListBloc.add(MovieListLoadSearchMovieEvent(text));
      movieListBloc.add(MovieListLoadNextPageEvent(state.localeTag));
    });
  }

  @override
  Future<void> close() {
    movieListBlocSubscription.cancel();
    return super.close();
  }

  MovieListRowData _makeRowData(Movie movie) {
    final releaseDate = movie.releaseDate;
    final releaseDateTitle =
        releaseDate != null ? _dateFormat.format(releaseDate) : '';
    return MovieListRowData(
      id: movie.id,
      posterPath: movie.posterPath,
      title: movie.title,
      releaseDate: releaseDateTitle,
      overview: movie.overview,
    );
  }
}
