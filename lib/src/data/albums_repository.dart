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

final albumsProvider = FutureProvider.autoDispose<List<Album>>((ref) async {
  return ref.watch(albumsRepositoryProvider).fetchAlbums();
});
