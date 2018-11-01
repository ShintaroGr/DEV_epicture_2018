import 'dart:convert';

class Tag {
  final String name;
  final String displayName;
  final String backgroundHash;
  final String accent;
  final String description;

  Tag({this.name, this.displayName, this.backgroundHash, this.accent, this.description});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(name: json['name'], displayName: json['display_name'], backgroundHash: json['background_hash'], accent: json['accent'], description: json['description']);
  }

  static List<Tag> allFromResponse(String response) {
    var decodedJson = json.decode(response).cast<String, dynamic>();

    return decodedJson['data']['tags'].cast<Map<String, dynamic>>().map((obj) => Tag.fromJson(obj)).toList().cast<Tag>();
  }
}
