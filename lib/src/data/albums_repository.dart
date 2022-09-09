import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_placeholder_flutter_example/src/api/api_error.dart';
import 'package:json_placeholder_flutter_example/src/api/dio_provider.dart';
import 'package:json_placeholder_flutter_example/src/domain/album.dart';

class AlbumsRepository {
  AlbumsRepository({required this.dio});
  final Dio dio;

  Future<List<Album>> fetchAlbums({CancelToken? cancelToken}) async {
    try {
      // add artificial delay to test loading UI
      //await Future.delayed(const Duration(seconds: 1));
      final response = await dio.get(
        'https://jsonplaceholder.typicode.com/albums',
        cancelToken: cancelToken,
      );
      switch (response.statusCode) {
        case 200:
          // get the list of results
          final albums = response.data as List<dynamic>;
          // map them to a List<Album>
          return albums.map((album) => Album.fromJson(album)).toList();
        case 404:
          throw const APIError.notFound();
        default:
          throw const APIError.unknown();
      }
    } on SocketException catch (_) {
      throw const APIError.noInternetConnection();
    }
  }
}

final albumsRepositoryProvider = Provider<AlbumsRepository>((ref) {
  return AlbumsRepository(
    dio: ref.watch(dioProvider),
  );
});

// Note: pull to refresh will cause this issue with autoDispose & keepAlive
// https://github.com/rrousselGit/riverpod/issues/1302
final albumsProvider = FutureProvider<List<Album>>((ref) async {
  // An object from package:dio that allows cancelling http requests
  final cancelToken = CancelToken();
  // When the provider is destroyed, cancel the http request
  ref.onDispose(() => cancelToken.cancel());
  // Fetch our data and pass our `cancelToken` for cancellation to work
  final response =
      ref.watch(albumsRepositoryProvider).fetchAlbums(cancelToken: cancelToken);
  // If the request completed successfully, keep the state
  //ref.keepAlive();
  return response;
});
