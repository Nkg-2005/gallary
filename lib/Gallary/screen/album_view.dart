import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallary/Gallary/screen/photo_video_view.dart';
import 'package:gallary/main.dart';
import 'package:get/route_manager.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumView extends StatefulWidget {
  final AssetPathEntity album;

  const AlbumView({super.key, required this.album});

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  List<AssetEntity> asset = [];

  @override
  void initState() {
    super.initState();
    loadAsset();
  }

  Future<void> loadAsset() async {
    final _asset = await widget.album.getAssetListPaged(page: 0, size: 100);
    setState(() {
      asset = _asset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.album.name)),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 3,
          mainAxisSpacing: 4,
          childAspectRatio: 0.9,
        ),
        itemCount: asset.length,
        itemBuilder: (BuildContext context, int index) {
          final _asset = asset[index];
          return FutureBuilder<Uint8List?>(
            future: _asset.thumbnailDataWithSize(ThumbnailSize(300, 300)),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: mq.height * 0.1,
                  width: mq.width * 0.3,

                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }
              if (snapshot.hasData && snapshot.data != null) {
                return GestureDetector(
                  onTap: () {
                    Get.to(() => PhotoVideoView(data: asset,index: index,));
                  },
                  child: Container(
                    height: mq.height * 0.2,
                    width: mq.width * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: MemoryImage(snapshot.data!),
                        fit: BoxFit.cover
                      ),
                    ),
                  ),
                );
                
              }
              return Container(color: Colors.grey[800]);
            },
          );
        },
      ),
    );
  }
}
