import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_placeholder_flutter_example/src/data/posts_repository.dart';
import 'package:json_placeholder_flutter_example/src/presentation/post_details.dart';

class PostsListScreen extends StatelessWidget {
  const PostsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: const PostsList(),
    );
  }
}

class PostsList extends ConsumerWidget {
  const PostsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(fetchPostsProvider);
    return postsAsync.when(
      data: (posts) => ListView.separated(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return ListTile(
              leading: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.indigo,
                  //border:StadiumBorder(),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(post.id.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(color: Colors.white)),
                ),
              ),
              title: Text(post.title,
                  style: Theme.of(context).textTheme.subtitle1),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PostDetailsScreen(postId: post.id),
                ));
              });
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(e.toString())),
    );
  }
}
