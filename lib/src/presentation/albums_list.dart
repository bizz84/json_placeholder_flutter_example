import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_placeholder_flutter_example/src/data/albums_repository.dart';
import 'package:json_placeholder_flutter_example/src/data/photos_repository.dart';
import 'package:json_placeholder_flutter_example/src/domain/album.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class AlbumsListScreen extends StatelessWidget {
  const AlbumsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Albums'),
      ),
      body: const AlbumsList(),
    );
  }
}

class AlbumsList extends ConsumerWidget {
  const AlbumsList({Key? key}) : super(key: key);

  static const imageSize = 150.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(albumsProvider);
    return albumsAsync.when(
      error: (e, st) => Center(child: Text(e.toString())),
      loading: () => const Center(child: CircularProgressIndicator()),
      data: (albums) => RefreshIndicator(
        onRefresh: () => ref.refresh(albumsProvider.future),
        child: GridView.builder(
          itemCount: albums.length,
          itemBuilder: (context, index) => AlbumCover(
            album: albums[index],
            size: imageSize,
          ),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: imageSize,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.5,
          ),
        ),
      ),
    );
  }
}

class AlbumCover extends ConsumerWidget {
  const AlbumCover({super.key, required this.album, this.size = 150});
  final Album album;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoAsync = ref.watch(firstPhotoProvider(album.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        photoAsync.when(
            error: (e, st) => Center(child: Text(e.toString())),
            loading: () => SizedBox(
                  width: size,
                  height: size,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            data: (photo) => OptimizedCacheImage(
                  imageUrl: photo.thumbnailUrl,
                  width: size,
                  height: size,
                  placeholder: (_, __) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, __, error) => Center(
                    child: Text(
                      error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
            // https://github.com/Baseflow/flutter_cached_network_image/issues/336
            // CachedNetworkImage(
            //   width: size,
            //   height: size,
            //   imageUrl: photo.thumbnailUrl,
            //   placeholder: (_, __) =>
            //       const Center(child: CircularProgressIndicator()),
            //   errorWidget: (_, __, error) => Center(
            //     child: Text(
            //       error.toString(),
            //       style: const TextStyle(color: Colors.red),
            //     ),
            //   ),
            // ),
            ),
        Text(
          album.title,
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }
}
