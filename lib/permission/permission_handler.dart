import 'package:flutter/widgets.dart';
import 'package:photo_manager/photo_manager.dart';

class PermissionHandler {

  static Future<bool> requestPhotoPermission() async{
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    if(state.isAuth){
      debugPrint("Permission Granted");
      return true;
    }else{
      PhotoManager.openSetting();
      return false;
    }
  }

  
}