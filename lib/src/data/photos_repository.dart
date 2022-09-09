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

// Documentation about keepAlive and CancelToken:
// https://riverpod.dev/docs/concepts/modifiers/auto_dispose/#example-canceling-http-requests-when-no-longer-used
final firstPhotoProvider = FutureProvider.autoDispose.family<Photo, int>(
  (ref, albumId) async {
    // An object from package:dio that allows cancelling http requests
    final cancelToken = CancelToken();
    // When the provider is destroyed, cancel the http request
    ref.onDispose(() => cancelToken.cancel());
    // Fetch our data and pass our `cancelToken` for cancellation to work
    return ref
        .watch(photosRepositoryProvider)
        .fetchFirstPhoto(albumId, cancelToken: cancelToken);
  },
  // cache the response for some time
  cacheTime: const Duration(seconds: 30),
);
