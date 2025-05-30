import 'package:permission_handler/permission_handler.dart';


class PermisstionHandler{
  //hàm cấp quyền để vào thư viện 
  Future<bool> requestGalleryPermission() async {
  var status = await Permission.storage.status;

  if (!status.isGranted) {
    status = await Permission.storage.request();
  }

  return status.isGranted;
}
}