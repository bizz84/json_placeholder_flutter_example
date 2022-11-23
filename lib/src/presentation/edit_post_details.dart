import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_placeholder_flutter_example/src/data/posts_repository.dart';
import 'package:json_placeholder_flutter_example/src/domain/post.dart';
import 'package:json_placeholder_flutter_example/src/presentation/edit_post_details_controller.dart';

class EditPostDetailsScreen extends StatelessWidget {
  const EditPostDetailsScreen({super.key, required this.postId});
  final int postId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit post $postId'),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final postAsync = ref.watch(fetchPostProvider(postId));
          return postAsync.when(
            data: (post) => EditPostDetailsForm(post: post),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text(e.toString())),
          );
        },
      ),
    );
  }
}

class EditPostDetailsForm extends ConsumerStatefulWidget {
  const EditPostDetailsForm({super.key, required this.post});
  final Post post;

  @override
  ConsumerState<EditPostDetailsForm> createState() => _LeaveReviewFormState();
}

class _LeaveReviewFormState extends ConsumerState<EditPostDetailsForm> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.post.title;
    _bodyController.text = widget.post.body;
  }

  @override
  void dispose() {
    // * TextEditingControllers should be always disposed
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editPostDetailsControllerProvider);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Builder(builder: (context) {
        return Builder(builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bodyController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () => ref
                        .read(editPostDetailsControllerProvider.notifier)
                        .updatePost(
                          previousPost: widget.post,
                          title: _titleController.text,
                          body: _bodyController.text,
                          onSuccess: Navigator.of(context).pop,
                        ),
                child: const Text('Submit'),
              )
            ],
          );
        });
      }),
    );
  }
}
