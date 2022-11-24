import 'package:json_placeholder_flutter_example/src/data/posts_repository.dart';
import 'package:json_placeholder_flutter_example/src/domain/post.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_post_details_controller.g.dart';

@riverpod
class EditPostDetailsController extends _$EditPostDetailsController {
  bool mounted = true;
  @override
  FutureOr<void> build() {
    ref.onDispose(() => mounted = false);
    // nothing to do
  }

  Future<void> updatePost({
    required Post previousPost,
    required String title,
    required String body,
    required void Function() onSuccess,
  }) async {
    // * if nothing has changed, return early
    if (previousPost.title == title && previousPost.body == body) {
      onSuccess();
      return;
    }
    state = const AsyncLoading();
    final updated = previousPost.copyWith(title: title, body: body);
    final postsRepository = ref.read(postsRepositoryProvider);
    final newState =
        await AsyncValue.guard(() => postsRepository.updatePost(updated));
    // on success, invalidate the FutureProvider that fetches the post data
    if (newState is AsyncData) {
      ref.invalidate(fetchPostProvider(updated.id));
    }
    if (mounted) {
      // * only set the state if the controller hasn't been disposed
      state = newState;
      if (state.hasError == false) {
        onSuccess();
      }
    }
  }
}
