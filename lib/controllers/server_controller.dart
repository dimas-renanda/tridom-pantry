import 'package:get/get.dart';

class ServerController extends GetxController {
  final RxBool isRunning = false.obs;
  final RxString serverAddress = ''.obs;
  final RxInt serverPort = 8080.obs;

  void setServerStatus(bool status, String address, int port) {
    isRunning.value = status;
    serverAddress.value = address;
    serverPort.value = port;
  }

  void stopServer() {
    isRunning.value = false;
    serverAddress.value = '';
  }
}
