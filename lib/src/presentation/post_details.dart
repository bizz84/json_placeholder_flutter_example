import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_placeholder_flutter_example/src/data/posts_repository.dart';
import 'package:json_placeholder_flutter_example/src/presentation/edit_post_details.dart';

class PostDetailsScreen extends ConsumerWidget {
  const PostDetailsScreen({super.key, required this.postId});
  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(fetchPostProvider(postId));
    return Scaffold(
      appBar: AppBar(title: Text('Post $postId')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: postAsync.when(
          data: (post) => Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(post.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 32),
              Text(post.body),
              const Spacer(),
              ElevatedButton(
                child: const Text('Edit'),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditPostDetailsScreen(postId: post.id),
                )),
              )
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text(e.toString())),
        ),
      ),
    );
  }
}
