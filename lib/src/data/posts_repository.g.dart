// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// ignore_for_file: avoid_private_typedef_functions, non_constant_identifier_names, subtype_of_sealed_class, invalid_use_of_internal_member, unused_element, constant_identifier_names, unnecessary_raw_strings, library_private_types_in_public_api

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

String $postsRepositoryHash() => r'093d4416ecc27591c9ecf0829dc5699a2c892db5';

/// See also [postsRepository].
final postsRepositoryProvider = Provider<PostsRepository>(
  postsRepository,
  name: r'postsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : $postsRepositoryHash,
);
typedef PostsRepositoryRef = ProviderRef<PostsRepository>;
String $fetchPostsHash() => r'0a591967398542511cb5415372d3623f1415fbb8';

/// See also [fetchPosts].
final fetchPostsProvider = AutoDisposeFutureProvider<List<Post>>(
  fetchPosts,
  name: r'fetchPostsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : $fetchPostsHash,
);
typedef FetchPostsRef = AutoDisposeFutureProviderRef<List<Post>>;
String $fetchPostHash() => r'1461029093d7d02f08ab35c21511b9ca7150663d';

/// See also [fetchPost].
class FetchPostProvider extends AutoDisposeFutureProvider<Post> {
  FetchPostProvider(
    this.postId,
  ) : super(
          (ref) => fetchPost(
            ref,
            postId,
          ),
          from: fetchPostProvider,
          name: r'fetchPostProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : $fetchPostHash,
        );

  final int postId;

  @override
  bool operator ==(Object other) {
    return other is FetchPostProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

typedef FetchPostRef = AutoDisposeFutureProviderRef<Post>;

/// See also [fetchPost].
final fetchPostProvider = FetchPostFamily();

class FetchPostFamily extends Family<AsyncValue<Post>> {
  FetchPostFamily();

  FetchPostProvider call(
    int postId,
  ) {
    return FetchPostProvider(
      postId,
    );
  }

  @override
  AutoDisposeFutureProvider<Post> getProviderOverride(
    covariant FetchPostProvider provider,
  ) {
    return call(
      provider.postId,
    );
  }

  @override
  List<ProviderOrFamily>? get allTransitiveDependencies => null;

  @override
  List<ProviderOrFamily>? get dependencies => null;

  @override
  String? get name => r'fetchPostProvider';
}
