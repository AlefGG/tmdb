part of 'movie_list_bloc.dart';

class MovieListEvent {}

class MovieListLoadNextPageEvent extends MovieListEvent {
  final String locale;

  MovieListLoadNextPageEvent(this.locale);
}

class MovieListLoadResetEvent extends MovieListEvent {}

class MovieListLoadSearchMovieEvent extends MovieListEvent {
  final String query;

  MovieListLoadSearchMovieEvent(this.query);
}
