import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class About {
  Future<void> showAboutDialog(context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String versionName = packageInfo.version;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: SvgPicture.asset(
                      "assets/seren.svg",
                      width: 100,
                      alignment: Alignment.centerLeft,
                    )),
                Text(versionName, style: const TextStyle(fontSize: 12)),
                const Text('\nmade by', style: TextStyle(fontSize: 12)),
                SvgPicture.asset(
                  "assets/orllewin.svg",
                  width: 100,
                  alignment: Alignment.centerLeft,
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('orllewin.uk',
                  style: TextStyle(
                    color: Color(0xFFF65E5E),
                    fontWeight: FontWeight.normal,
                  )),
              onPressed: () {
                launchWebsite();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Close',
                  style: TextStyle(
                    color: Color(0xFFF65E5E),
                    fontWeight: FontWeight.normal,
                  )),
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
