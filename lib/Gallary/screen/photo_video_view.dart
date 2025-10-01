import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class PhotoVideoView extends StatefulWidget {
  final List<AssetEntity> data;
  final int index;
  const PhotoVideoView({super.key, required this.data, required this.index});

  @override
  State<PhotoVideoView> createState() => _PhotoVideoViewState();
}

class _PhotoVideoViewState extends State<PhotoVideoView> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.data[widget.index].type == AssetType.video) {
      widget.data[widget.index].file.then((file) {
        if (file != null) {
          _controller = VideoPlayerController.file(file)
            ..initialize().then((_) {
              setState(() {});
              _controller.play();
            });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return PageView.builder(
      itemCount: widget.data.length,
       controller: PageController(initialPage: widget.index),
      itemBuilder: (context, indexx) {
        return FutureBuilder(future: widget.data[indexx].originBytes, builder: (context, snapshot) {
      if(snapshot.connectionState == ConnectionState.waiting){
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      if(snapshot.hasData && snapshot.data != null){
        return PhotoView(
            imageProvider: MemoryImage( snapshot.data!,),
            enableRotation: true,
        );
      }
      return Center(
        child: Text('faild to launch image....',
        style: TextStyle(color: Colors.white),
        ),
      );
    },);
    },);
  }
}