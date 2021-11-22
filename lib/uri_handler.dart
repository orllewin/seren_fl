//Port of class by the same name from Kotlin version of Seren
class UriHandler{

  String uri = "";
  String host = "";

  initialise(String uri){
    this.uri = uri;
    extractHost();
  }

  extractHost(){
    if(uri.isEmpty) return;

    String urn = uri.replaceFirst("gemini://", "");
    if(urn.contains("/")){
      host = urn.substring(0, urn.indexOf("/"));
    }else{
      host = urn;
    }
  }

  resolve(String reference){
    if(uri == "gemini://$host") uri = "$uri/";

    if(reference.startsWith("./")){
      removeInDirectoryReferences();
      initialise("$uri${reference.substring(2)}");
    }else if(reference.startsWith("//")){
      initialise("gemini:$reference");
    }else if(reference.startsWith("gemini://")){
      initialise(reference);
    }else if(reference.startsWith("/")){
      uri = "gemini://$host$reference";
    }else if(reference.startsWith("../")){
      removeInDirectoryReferences();
      int traversalCount = reference.split("../").length - 1;
      uri = traverse(traversalCount) + reference.replaceAll("../", "");
    }else{
      if(uri.endsWith("/")){
        uri = "${uri}$reference";
      }else{
        uri = "${uri.substring(0, uri.lastIndexOf("/"))}/$reference";
      }
    }
  }

  String traverse(int count){
    String path = uri.replaceFirst("gemini://$host", "");
    List<String> segments = path.split("/");
    segments.removeWhere((element) => element.isEmpty);
    var segmentCount = segments.length;
    var nouri = "gemini://$host";

    var index = 0;
    for(var segment in segments){
      if(index < segmentCount - count){
        nouri += "/$segment";
      }
    }

    return "$nouri/";
  }

  removeInDirectoryReferences(){
    if(!uri.endsWith("/")){
      uri = uri.substring(0, uri.lastIndexOf("/") + 1);
    }
  }

}