import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:json_placeholder_flutter_example/src/api/api_error.dart';
import 'package:json_placeholder_flutter_example/src/api/dio_provider.dart';
import 'package:json_placeholder_flutter_example/src/domain/post.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'posts_repository.g.dart';

class PostsRepository {
  PostsRepository({required this.dio});
  final Dio dio;

  Future<List<Post>> fetchPosts({CancelToken? cancelToken}) async {
    try {
      // add artificial delay to test loading UI
      //await Future.delayed(const Duration(seconds: 1));
      final response = await dio.get(
        'https://jsonplaceholder.typicode.com/posts',
        cancelToken: cancelToken,
      );
      switch (response.statusCode) {
        case 200:
          // get the list of results
          final posts = response.data as List<dynamic>;
          // map them to a List<Album>
          return posts.map((post) => Post.fromJson(post)).toList();
        case 404:
          throw const APIError.notFound();
        default:
          throw const APIError.unknown();
      }
    } on SocketException catch (_) {
      throw const APIError.noInternetConnection();
    }
  }

  Future<Post> fetchPost(int postId, {CancelToken? cancelToken}) async {
    print('dio: fetchPost($postId)');
    try {
      // add artificial delay to test loading UI
      //await Future.delayed(const Duration(seconds: 1));
      final response = await dio.get(
        'https://jsonplaceholder.typicode.com/posts/$postId',
        cancelToken: cancelToken,
      );
      switch (response.statusCode) {
        case 200:
          return Post.fromJson(response.data);
        case 404:
          throw const APIError.notFound();
        default:
          throw const APIError.unknown();
      }
    } on SocketException catch (_) {
      throw const APIError.noInternetConnection();
    }
  }

  // Note: this method submits the data, but the backend won't actually update it
  Future<void> updatePost(Post post, {CancelToken? cancelToken}) async {
    try {
      final response = await dio.put(
        'https://jsonplaceholder.typicode.com/posts/${post.id}',
        data: post.toJson(),
        cancelToken: cancelToken,
      );
      switch (response.statusCode) {
        case 200:
          return;
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

@Riverpod(keepAlive: true)
PostsRepository postsRepository(PostsRepositoryRef ref) {
  return PostsRepository(dio: ref.watch(dioProvider));
}

// final postsRepositoryProvider = Provider<PostsRepository>((ref) {
//   return PostsRepository(
//     dio: ref.watch(dioProvider),
//   );
// });

@riverpod
Future<List<Post>> fetchPosts(FetchPostsRef ref) {
  // An object from package:dio that allows cancelling http requests
  final cancelToken = CancelToken();
  // When the provider is destroyed, cancel the http request
  ref.onDispose(() => cancelToken.cancel());
  // Fetch our data and pass our `cancelToken` for cancellation to work
  return ref
      .watch(postsRepositoryProvider)
      .fetchPosts(cancelToken: cancelToken);
}

// final fetchPostsProvider = FutureProvider.autoDispose<List<Post>>((ref) {
//   // An object from package:dio that allows cancelling http requests
//   final cancelToken = CancelToken();
//   // When the provider is destroyed, cancel the http request
//   ref.onDispose(() => cancelToken.cancel());
//   // Fetch our data and pass our `cancelToken` for cancellation to work
//   return ref
//       .watch(postsRepositoryProvider)
//       .fetchPosts(cancelToken: cancelToken);
// });

@Riverpod(keepAlive: false)
Future<Post> fetchPost(FetchPostRef ref, int postId) {
  print('init: fetchPost($postId)');
  ref.onCancel(() => print('cancel: fetchPost($postId)'));
  ref.onResume(() => print('resume: fetchPost($postId)'));
  ref.onDispose(() => print('dispose: fetchPost($postId)'));
  // ref.onAddListener(() => print('addListener: fetchPost($postId)'));
  // ref.onRemoveListener(() => print('removeListener: fetchPost($postId)'));
  // get the [KeepAliveLink]
  final link = ref.keepAlive();
  // a timer to be used by the callbacks below
  Timer? timer;
  // An object from package:dio that allows cancelling http requests
  final cancelToken = CancelToken();
  // When the provider is destroyed, cancel the http request
  ref.onDispose(() {
    timer?.cancel();
    cancelToken.cancel();
  });
  // When the last listener is removed, start a timer to dispose the cached data
  ref.onCancel(() {
    // start a 30 second timer
    timer = Timer(const Duration(seconds: 5), () {
      // dispose on timeout
      link.close();
    });
  });
  // If the provider is listened again after it was paused, cancel the timer
  ref.onResume(() {
    timer?.cancel();
  });

  // Fetch our data and pass our `cancelToken` for cancellation to work
  return ref
      .watch(postsRepositoryProvider)
      .fetchPost(postId, cancelToken: cancelToken);
}

// final fetchPostProvider =
//     FutureProvider.autoDispose.family<Post, int>((ref, postId) {
//   // An object from package:dio that allows cancelling http requests
//   final cancelToken = CancelToken();
//   // When the provider is destroyed, cancel the http request
//   ref.onDispose(() => cancelToken.cancel());
//   // Fetch our data and pass our `cancelToken` for cancellation to work
//   return ref
//       .watch(postsRepositoryProvider)
//       .fetchPost(postId, cancelToken: cancelToken);
// });
