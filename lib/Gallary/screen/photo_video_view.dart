import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';

class PhotoVideoView extends StatelessWidget {
  final List<AssetEntity> data;
  final int index;
  const PhotoVideoView({super.key, required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    
    return PageView.builder(
      itemCount: data.length,
       controller: PageController(initialPage: index),
      itemBuilder: (context, indexx) {
        return FutureBuilder(future: data[indexx].originBytes, builder: (context, snapshot) {
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