import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seren_fl/address_bar.dart';
import 'package:seren_fl/history/history.dart';
import 'package:seren_fl/uri_handler.dart';

import 'db/drift_database.dart';
import 'dialogs/about_dialog.dart';
import 'dialogs/share_dialog.dart';
import 'gemini.dart';
import 'gemtext.dart';

void main() async {
  runApp(Provider<SerenDatabase>(
    create: (context) => SerenDatabase(),
    child: SerenApp(),
    dispose: (context, db) => db.close(),
  ));
}

Map<int, Color> color = {
  50: Color.fromRGBO(200, 200, 200, .1),
  100: Color.fromRGBO(200, 200, 200, .2),
  200: Color.fromRGBO(200, 200, 200, .3),
  300: Color.fromRGBO(200, 200, 200, .4),
  400: Color.fromRGBO(200, 200, 200, .5),
  500: Color.fromRGBO(200, 200, 200, .6),
  600: Color.fromRGBO(200, 200, 200, .7),
  700: Color.fromRGBO(200, 200, 200, .8),
  800: Color.fromRGBO(200, 200, 200, .9),
  900: Color.fromRGBO(200, 200, 200, 1),
};

MaterialColor colorGCustom = MaterialColor(0xFFDEDEDE, color);

class SerenApp extends StatelessWidget {
  const SerenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seren',
      theme: ThemeData(
        fontFamily: 'GoogleSans',
        primarySwatch: colorGCustom,
      ),
      home: const SerenHomePage(title: 'Seren'),
    );
  }
}

class SerenHomePage extends StatefulWidget {
  const SerenHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<SerenHomePage> createState() => _SerenHomePageState();
}

class _SerenHomePageState extends State<SerenHomePage> {
  var uriHandler = UriHandler();

  var firstRun = true;
  String currentAddress = "gemini://seren.orllewin.uk";
  String? rawGemtext = "";
  List<GemtextLine> lines = [];
  String? error;
  List<String> runtimeHistory = [];

  static const defaultTextSize = 16.0;
  static const defaultPadding = 4.0;
  static const headerWeight = FontWeight.w400;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          log("onWillPop: History size: ${runtimeHistory.length}");
          for (var element in runtimeHistory) {
            log("onWillPop: History item: $element");
          }
          if (runtimeHistory.length > 1) {
            runtimeHistory.removeLast();
            onAddress(runtimeHistory.removeLast());
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: SizedBox(
              height: 75.0,
              child: AddressBar(autoload: firstRun, address: currentAddress, onHome: onHome, onAddress: onAddress, onOverflow: onOverflow),
            ),
            titleSpacing: 0.0,
            elevation: 0.0,
            toolbarHeight: 75.0,
          ),
          body: ListView.builder(
            itemCount: lines.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, position) {
              var item = lines[position];
              if (item is Regular) {
                return Padding(padding: const EdgeInsets.all(defaultPadding), child: Text(item.line, style: const TextStyle(fontSize: defaultTextSize)));
              } else if (item is Code) {
                return Text(item.line, style: const TextStyle(fontSize: defaultTextSize));
              } else if (item is Link) {
                return InkWell(
                  child: Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Text(
                        item.description ?? item.url ?? "Bad Link",
                        style: const TextStyle(fontSize: defaultTextSize, decoration: TextDecoration.underline),
                      )),
                  onTap: () {
                    log("Link clicked: ${item.url}");
                    onAddress(item.url!);
                  },
                );
              } else if (item is ImageLink) {
                return Padding(padding: const EdgeInsets.all(defaultPadding), child: Text(item.description ?? item.url ?? "Bad Link", style: const TextStyle(fontSize: defaultTextSize, decoration: TextDecoration.underline)));
              } else if (item is HeaderSmall) {
                return Padding(padding: const EdgeInsets.all(defaultPadding), child: Text(item.line, style: const TextStyle(fontSize: 20.0, fontWeight: headerWeight)));
              } else if (item is HeaderMedium) {
                return Padding(padding: const EdgeInsets.all(defaultPadding), child: Text(item.line, style: const TextStyle(fontSize: 24.0, fontWeight: headerWeight)));
              } else if (item is HeaderBig) {
                return Padding(padding: const EdgeInsets.all(defaultPadding), child: Text(item.line, style: const TextStyle(fontSize: 28.0, fontWeight: headerWeight)));
              } else if (item is ListItem) {
                return Padding(padding: const EdgeInsets.all(defaultPadding), child: Text(item.line, style: const TextStyle(fontSize: defaultTextSize)));
              } else if (item is Quote) {
                return Padding(padding: const EdgeInsets.all(defaultPadding), child: Text(item.line, style: const TextStyle(fontSize: defaultTextSize)));
              } else {
                return Padding(padding: const EdgeInsets.all(defaultPadding), child: Text(item.line, style: const TextStyle(fontSize: defaultTextSize)));
              }
            },
          ),
        ));
  }

  onHome() {
    log("Home clicked");
    runtimeHistory.clear();
    uriHandler.initialise("gemini://seren.orllewin.uk");
    onAddress(uriHandler.uri);
  }

  onOverflow(int menuId) {
    switch (menuId) {
      case AddressBar.menuSearch:
        log("Overflow clicked menuSearch");
        break;
      case AddressBar.menuAddBookmark:
        log("Overflow clicked menuAddBookmark");
        break;
      case AddressBar.menuViewSource:
        log("Overflow clicked menuViewSource");
        break;
      case AddressBar.menuShare:
        log("Overflow clicked menuShare");
        NativeShare().showShareDialog(uriHandler.uri);
        break;
      case AddressBar.menuBookmarks:
        log("Overflow clicked menuBookmarks");
        break;
      case AddressBar.menuHistory:
        log("Overflow clicked menuHistory");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return const HistoryScreen();
          }),
        );
        break;
      case AddressBar.menuIdentities:
        log("Overflow clicked menuIdentities");
        break;
      case AddressBar.menuSettings:
        log("Overflow clicked menuSettings");
        break;
      case AddressBar.menuAbout:
        log("Overflow clicked menuAbout");
        About().showAboutDialog(context);
        break;
      default:
        log("Overflow clicked, unknownId: $menuId");
    }
  }

  onAddress(String address) async {
    log("main onAddress: $address");

    uriHandler.resolve(address);

    var resolvedAddress = uriHandler.uri;

    var gemini = Gemini();
    var response = await gemini.geminiRequest(resolvedAddress);
    var parsedResponse = GemtextParser().parseResponse(response);

    if (parsedResponse.error == null) {
      //add resolvedAddress to history
      if (runtimeHistory.isEmpty || runtimeHistory.last != resolvedAddress) {
        if (runtimeHistory.isEmpty) {
          log("Adding $resolvedAddress to history, history is empty currently");
        } else {
          log("Adding $resolvedAddress to history, currently last history item: ${runtimeHistory.last}");
        }

        var title = GemtextParser().findTitle(parsedResponse);

        runtimeHistory.add(resolvedAddress);
        historyInsert(title, resolvedAddress);
      }
    }

    //todo - better way? - is this even necessary?
    List<String> updatedHistory = [];
    updatedHistory.addAll(runtimeHistory);

    setState(() {
      firstRun = false;
      currentAddress = resolvedAddress;
      rawGemtext = parsedResponse.rawGemtext;
      lines = parsedResponse.lines;
      error = parsedResponse.error;
      runtimeHistory = updatedHistory;
    });
  }

  Future historyInsert(String title, String address) async {
    Provider.of<SerenDatabase>(context, listen: false).addHistory(title, address);
  }
}
