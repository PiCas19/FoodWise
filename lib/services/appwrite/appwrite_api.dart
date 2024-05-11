import 'package:flutter/widgets.dart';
import 'package:appwrite/appwrite.dart';
import '../../constants/constants.dart';

class AppwriteAPI extends ChangeNotifier {
  late final Client client;
  AppwriteAPI() {
    client = Client();
    initClient();
  }

  initClient() {
    client
        .setEndpoint(APPWRITE_URL)
        .setProject(APPWRITE_PROJECT_ID)
        .setSelfSigned();
  }
}