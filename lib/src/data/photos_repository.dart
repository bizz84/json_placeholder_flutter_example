import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_placeholder_flutter_example/src/api/api_error.dart';
import 'package:json_placeholder_flutter_example/src/api/dio_provider.dart';
import 'package:json_placeholder_flutter_example/src/domain/photo.dart';

class PhotosRepository {
  PhotosRepository({required this.dio});
  final Dio dio;

  Future<Photo> fetchFirstPhoto(int albumId, {CancelToken? cancelToken}) async {
    try {
      final response = await dio.get(
        'https://jsonplaceholder.typicode.com/albums/$albumId/photos',
        cancelToken: cancelToken,
      );
      switch (response.statusCode) {
        case 200:
          // get the list of results
          final photos = response.data as List<dynamic>;
          // map them to a List<Album>
          return Photo.fromJson(photos[0]);
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

final photosRepositoryProvider = Provider<PhotosRepository>((ref) {
  return PhotosRepository(
    dio: ref.watch(dioProvider),
  );
});

final firstPhotoProvider =
    FutureProvider.autoDispose.family<Photo, int>((ref, albumId) async {
  return ref.watch(photosRepositoryProvider).fetchFirstPhoto(albumId);
});