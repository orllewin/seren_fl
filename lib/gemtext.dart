import 'dart:convert';
import 'dart:developer';

import 'gemini.dart';

class GemtextParser{
  Parsed parseResponse(Response response) {
    if (response is Empty) {
      log("Gemini response type: Empty");
      return Parsed(null, [], "${response.responseCode.toString()}: Empty");
    } else if (response is Gemtext) {
      log("Gemini response type: Gemtext");
      var rawLines = const LineSplitter().convert(response.body);
      List<GemtextLine> parsedLines = [];

      for (var line in rawLines) {
        if (line.startsWith("=>")) {
          //Link
          var segments = line.substring(2).trim().split(" ");

          log("Line: $line");

          String? url;
          String? description;

          if (segments.length < 2) {
            url = segments.first;
            description = null;
          } else {
            url = segments.first;
            description = segments.join(" ").replaceAll(url, "").trim();
          }

          //Image Link
          if (segments.first.toLowerCase().endsWith(".png") || segments.first.toLowerCase().endsWith(".jpg") || segments.first.toLowerCase().endsWith(".jpeg")) {
            parsedLines.add(GemtextLine.imageLink(line, url, description));
          } else {
            //Regular link
            parsedLines.add(GemtextLine.link(line, url, description));
          }
        } else if (line.startsWith("#")) {
          if (line.startsWith("###")) {
            parsedLines.add(GemtextLine.headerSmall(line.substring(3).trim()));
          } else if (line.startsWith("##")) {
            parsedLines.add(GemtextLine.headerMedium(line.substring(2).trim()));
          } else {
            parsedLines.add(GemtextLine.headerBig(line.substring(1).trim()));
          }
        } else if (line.startsWith(">")) {
          parsedLines.add(GemtextLine.quote(line.substring(1).trim()));
        } else {
          parsedLines.add(GemtextLine.regular(line));
        }
      }

      return Parsed(response.body, parsedLines, null);
    } else if (response is Error) {
      log("Gemini response type: Error");
      return Parsed(null, [], "${response.responseCode.toString()}: ${response.meta}");
    } else if (response is Other) {
      log("Gemini response type: Other");
      //Something we don't handle yet
      return Parsed(null, [], "${response.responseCode.toString()}: ${response.meta}");
    } else {
      return Parsed(null, [], "Unknown error");
    }
  }

  String findTitle(Response response) {

    var title = "Unknown";

    if(response is Parsed){
      response.lines.sublist(0,5).forEach((line) {
        if((line is HeaderBig || line is HeaderMedium || line is HeaderSmall) && title == "Unknown" ){
          title = line.line;
        }
      });
    }

    return title;
  }
}

class GemtextLine {
  GemtextLine._(this.line);
  final String line;

  factory GemtextLine.regular(String line) = Regular;
  factory GemtextLine.code(String line) = Code;
  factory GemtextLine.link(String line, String? url, String? description) = Link;
  factory GemtextLine.imageLink(String line, String? url, String? description) = ImageLink;
  factory GemtextLine.headerSmall(String line) = HeaderSmall;
  factory GemtextLine.headerMedium(String line) = HeaderMedium;
  factory GemtextLine.headerBig(String line) = HeaderBig;
  factory GemtextLine.listItem(String line) = ListItem;
  factory GemtextLine.quote(String line) = Quote;
}

class Regular extends GemtextLine {
  Regular(String line): super._(line);
}

class Code extends GemtextLine {
  Code(String line): super._(line);
}

class Link extends GemtextLine {
  Link(String line, this.url, this.description): super._(line);

  final String? url;
  final String? description;
}

class ImageLink extends GemtextLine {
  ImageLink(String line, this.url, this.description): super._(line);

  final String? url;
  final String? description;
}

class HeaderSmall extends GemtextLine {
  HeaderSmall(String line): super._(line);
}

class HeaderMedium extends GemtextLine {
  HeaderMedium(String line): super._(line);
}

class HeaderBig extends GemtextLine {
  HeaderBig(String line): super._(line);
}

class ListItem extends GemtextLine {
  ListItem(String line): super._(line);
}

class Quote extends GemtextLine {
  Quote(String line): super._(line);
}

