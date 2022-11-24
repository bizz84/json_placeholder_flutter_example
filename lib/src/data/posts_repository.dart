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

  Future<List<Post>> fetchPosts({CancelToken? cancelToken}) => _run<List<Post>>(
        request: () => dio.get(
          'https://jsonplaceholder.typicode.com/posts',
          cancelToken: cancelToken,
        ),
        parse: (data) {
          // get the list of results
          final posts = data as List<dynamic>;
          // map them to a List<Album>
          return posts.map((post) => Post.fromJson(post)).toList();
        },
      );

  Future<Post> fetchPost(int postId, {CancelToken? cancelToken}) => _run<Post>(
        request: () => dio.get(
          'https://jsonplaceholder.typicode.com/posts/$postId',
          cancelToken: cancelToken,
        ),
        parse: (data) => Post.fromJson(data),
      );

  // Note: this method submits the data, but the backend won't actually update it
  Future<void> updatePost(Post post, {CancelToken? cancelToken}) => _run<void>(
        request: () => dio.put(
          'https://jsonplaceholder.typicode.com/posts/${post.id}',
          data: post.toJson(),
          cancelToken: cancelToken,
        ),
        parse: (data) {},
      );

  // Generic method to make a request and parse the response data
  Future<T> _run<T>({
    required Future<Response> Function() request,
    required T Function(dynamic) parse,
  }) async {
    try {
      // add artificial delay to test loading UI
      //await Future.delayed(const Duration(seconds: 1));
      final response = await request();
      switch (response.statusCode) {
        case 200:
          return parse(response.data);
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

@riverpod
Future<Post> fetchPost(FetchPostRef ref, int postId) {
  // print('init: fetchPost($postId)');
  // ref.onCancel(() => print('cancel: fetchPost($postId)'));
  // ref.onResume(() => print('resume: fetchPost($postId)'));
  // ref.onDispose(() => print('dispose: fetchPost($postId)'));
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
