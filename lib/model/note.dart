import 'dart:convert';

class Note {
  late String title;
  late String content;

  Note({this.title = "Untitled", this.content = ""});

  Note.fromJson(String jsonString) {
    var json = jsonDecode(jsonString);
    title = json["title"];
    content = json["content"];
  }

  Note.fromDoc(Map<String, dynamic> doc) {
    title = doc["title"];
    content = doc["content"];
  }

  Map<String, dynamic> toDoc() {
    return <String, dynamic>{"title": title, "content": content};
  }

  String toJson() {
    Map<String, String> json = {"title": title, "content": content};
    return jsonEncode(json);
  }
}
