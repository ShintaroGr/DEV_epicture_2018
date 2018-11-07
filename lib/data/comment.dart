import 'dart:convert';

class Comment {
  final int id;
  final String comment;
  final String author;
  final List<Comment> children;
  String vote;
  int points;

  Comment({this.id, this.comment, this.author, this.children, this.vote, this.points});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      comment: json['comment'],
      author: json['author'],
      children: Comment.getChildren(json),
      vote: json['vote'],
      points: json['points'],
    );
  }

  static List<Comment> allFromResponse(String response) {
    var decodedJson = json.decode(response).cast<String, dynamic>();

    if (decodedJson['success'] == true) {
      return decodedJson['data'].cast<Map<String, dynamic>>().map((obj) => Comment.fromJson(obj)).toList().cast<Comment>();
    }
    return [];
  }

  static List<Comment> getChildren(Map<String, dynamic> json) {
    return json['children'].cast<Map<String, dynamic>>().map((obj) => Comment.fromJson(obj)).toList().cast<Comment>();
  }
}
