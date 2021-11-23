import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class About {
  Future<void> showAboutDialog(context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String versionName = packageInfo.version;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[const Text('Seren', style: TextStyle(fontSize: 26)), Text(versionName, style: const TextStyle(fontSize: 12)), const Text('\nMade by'), const Text('Orllewin', style: TextStyle(fontSize: 20))],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('orllewin.uk'),
              onPressed: () {
                launchWebsite();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  launchWebsite() async {
    const url = "https://orllewin.uk";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
  }
}
