import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PermissionService {

  static Future<bool> requestPhotoPermission() async {
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    return state.isAuth;
  }

  static Future<void> showPermissionAlert(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text(
          'This app needs access to your photos to display your gallery.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  static Future<void> openAppSettings() async {
    await PhotoManager.openSetting();
  }

  static Future<List<AssetPathEntity>> fetchAlbums() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      debugPrint("Permission not granted");
      PhotoManager.openSetting();
      return [];
    } 
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      onlyAll: false,
    );
    return albums;

    
  }

    
}
