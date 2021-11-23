import 'package:share_plus/share_plus.dart';

class NativeShare{
  void showShareDialog(String text) async {
    await Share.share(text);
  }
}