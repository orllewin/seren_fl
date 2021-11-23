import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'gemtext.dart';

class Response {
  Response._(this.responseCode, this.meta);

  static const responseCodeEmpty = -1;
  static const responseCodeNoAddress = -2;
  static const responseCodeTimeout = -3;
  static const responseParsed = -4;

  final int responseCode;
  final String meta;

  factory Response.empty() = Empty;
  factory Response.gemtext(int responseCode, String meta, String body) = Gemtext;
  factory Response.error(int responseCode, String meta) = Error;
  factory Response.other(int responseCode, String meta) = Other;
}

class Empty extends Response {
  Empty() : super._(Response.responseCodeEmpty, "");
}

class Parsed extends Response {
  Parsed(this.rawGemtext, this.lines, this.error) : super._(Response.responseParsed, "");
  final String? rawGemtext;
  final List<GemtextLine> lines;
  final String? error;
}

class Gemtext extends Response {
  Gemtext(int responseCode, String meta, this.body) : super._(responseCode, meta);
  final String body;
}

class Error extends Response {
  Error(int responseCode, String meta) : super._(responseCode, meta);
}

class Other extends Response {
  Other(int responseCode, String meta) : super._(responseCode, meta);
}

class Gemini {
  Future<Response> geminiRequest(String address) async {
    var uri = Uri.tryParse(address);

    if (uri == null) {
      return Response.error(Response.responseCodeNoAddress, "Address is null");
    }

    var port = uri.hasPort ? uri.port : 1965;
    var socket = await RawSecureSocket.connect(uri.host, port, timeout: const Duration(seconds: 7), onBadCertificate: (X509Certificate cert) {
      //this allows self-signed certs
      return true;
    });

    var response = Response.empty();
    socket.timeout(const Duration(seconds: 7), onTimeout: (socket) {
      response = Response.error(Response.responseCodeTimeout, "Request timed out");
      socket.close();
    });

    String body = "";

    socket.write(const Utf8Encoder().convert(address + "\r\n"));

    await socket.listen((event) {
      switch (event) {
        case RawSocketEvent.read:
          var bytes = socket.read();

          if (bytes != null) {
            //this is probably a bad way of doing things but what even is Dart?
            final content = String.fromCharCodes(bytes);
            body = body + content;
          }

          break;
        case RawSocketEvent.write:
          //NOOP
          break;
        case RawSocketEvent.readClosed:
          socket.close();
          break;
        case RawSocketEvent.closed:
          socket.close();
          break;
        default:
          throw "Unexpected event $event";
      }
    }).asFuture();
    socket.close();

    var firstLine = LineSplitter.split(body).first;
    var responseCodeStr = firstLine.split(" ").first.trim();
    var responseCode = int.parse(responseCodeStr);
    var meta = firstLine.replaceAll(responseCodeStr, "").trim();

    log("meta: $meta");

    if (responseCode == 20 && meta == "text/gemini") {
      response = Response.gemtext(20, meta, body.replaceFirst(firstLine, "").trim());
    } else {
      response = Response.other(responseCode, meta);
    }

    return response;
  }
}
