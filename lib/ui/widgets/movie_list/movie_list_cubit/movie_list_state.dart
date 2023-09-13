part of 'movie_list_cubit.dart';

class MovieListRowData {
  final int id;
  final String? posterPath;
  final String title;
  final String releaseDate;
  final String overview;
  MovieListRowData({
    required this.id,
    required this.posterPath,
    required this.title,
    required this.releaseDate,
    required this.overview,
  });
}

class MovieListCubitState {
  final List<MovieListRowData> movies;
  final String localeTag;

  MovieListCubitState({
    required this.movies,
    required this.localeTag,
  });

  //generat ==() and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MovieListCubitState &&
        runtimeType == other.runtimeType &&
        other.movies == movies &&
        other.localeTag == localeTag;
  }

  @override
  int get hashCode => movies.hashCode ^ localeTag.hashCode;

  //copywith

  MovieListCubitState copyWith({
    List<MovieListRowData>? movies,
    String? localeTag,
    String? searchQuery,
  }) {
    return MovieListCubitState(
      movies: movies ?? this.movies,
      localeTag: localeTag ?? this.localeTag,
    );
  }
}
