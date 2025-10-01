import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallary/Gallary/screen/album_view.dart';
import 'package:gallary/main.dart';
import 'package:gallary/permission/permission_service.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

class GallaryPage extends StatefulWidget {
  const GallaryPage({super.key});

  @override
  State<GallaryPage> createState() => _GallaryPageState();
}

class _GallaryPageState extends State<GallaryPage> {
  List<AssetPathEntity> _albums = [];

  @override
  void initState() {
    super.initState();
    loadAlbums();
  }

  Future<void> loadAlbums() async {
    final albums = await PermissionService.fetchAlbums();
    setState(() {
      _albums = albums;
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Gallary')),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 3,
          mainAxisSpacing: 4,
          childAspectRatio: 0.75,
        ),
        itemCount: _albums.length,
        itemBuilder: (context, index) {
          final album = _albums[index];

          return FutureBuilder<List<AssetEntity>>(
            future: album.getAssetListRange(start: 0, end: 1),
            builder: (context, albumSnap) {
              Widget placeholder = Container(color: Colors.grey[800]);

              Widget thumbnailWidget = placeholder;
              if (albumSnap.hasData && albumSnap.data!.isNotEmpty) {
                final asset = albumSnap.data!.first;
                thumbnailWidget = FutureBuilder<Uint8List?>(
                  future: asset.thumbnailDataWithSize(const ThumbnailSize(300, 300)),
                  builder: (context, thumbSnap) {
                    if (thumbSnap.hasData && thumbSnap.data != null) {
                      return Container(
                        height: mq.height * 0.2,
                        width: mq.width * 0.3,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: MemoryImage(thumbSnap.data!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }
                    return Container(
                      height: mq.height * 0.2,
                      width: mq.width * 0.3,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                );
              }

              return GestureDetector(
                onTap: () {
                  Get.to(() => AlbumView(album: album,));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Center(child: thumbnailWidget)),
                      Text(
                        album.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      FutureBuilder<int>(
                        future: album.assetCountAsync,
                        builder: (context, countSnap) {
                          return Text(
                            '${countSnap.data ?? 0} items',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
