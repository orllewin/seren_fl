import 'dart:developer';

import 'package:flutter/material.dart';

class AddressBar extends StatelessWidget {
  const AddressBar({Key? key, required this.autoload, required this.address, this.onHome, this.onAddress, this.onOverflow}) : super(key: key);

  static const menuSearch = 0;
  static const menuAddBookmark = 1;
  static const menuViewSource = 2;
  static const menuShare = 3;
  static const menuBookmarks = 4;
  static const menuHistory = 5;
  static const menuIdentities = 6;
  static const menuSettings = 7;
  static const menuAbout = 8;

  final bool autoload;
  final String address;
  final onHome;
  final onAddress;
  final onOverflow;

  @override
  Widget build(BuildContext context) {
    if (autoload) onAddress(address);
    return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.all(4.0),
            child: ClipOval(
              child: Material(
                color: Colors.white, // Button color
                child: InkWell(
                  splashColor: Colors.grey, // Splash color
                  onTap: onHome,
                  child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.home,
                        color: Colors.red,
                        size: 25.0,
                      )),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(200, 200, 200, .2),
                borderRadius: BorderRadius.circular(32),
              ),
              child: TextField(
                controller: TextEditingController()..text = address,
                keyboardType: TextInputType.url,
                onSubmitted: (value) {
                  log("Address value: $value");
                  onAddress(value);
                },
                decoration: const InputDecoration(
                  hintStyle: TextStyle(fontSize: 12),
                  hintText: 'gemini://',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                ),
                textInputAction: TextInputAction.go,
              ),
            ),
            flex: 20,
          ),
          PopupMenuButton<int>(
              onSelected: (value) {
                onOverflow(value);
              },
              itemBuilder: (context) => [
                    const PopupMenuItem(
                      child: Text("Search"),
                      value: menuSearch,
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      child: Text("Add bookmark"),
                      value: menuAddBookmark,
                    ),
                    const PopupMenuItem(
                      child: Text("View source"),
                      value: menuViewSource,
                    ),
                    const PopupMenuItem(
                      child: Text("Share"),
                      value: menuShare,
                    ),
                    PopupMenuDivider(),
                    const PopupMenuItem(
                      child: Text("Bookmarks"),
                      value: menuBookmarks,
                    ),
                    const PopupMenuItem(
                      child: Text("History"),
                      value: menuHistory,
                    ),
                    const PopupMenuItem(
                      child: Text("Identities"),
                      value: menuIdentities,
                    ),
                    PopupMenuDivider(),
                    const PopupMenuItem(
                      child: Text("Settings"),
                      value: menuSettings,
                    ),
                    const PopupMenuItem(
                      child: Text("About"),
                      value: menuAbout,
                    ),
                  ])
        ]));
  }
}
