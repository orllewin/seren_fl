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
