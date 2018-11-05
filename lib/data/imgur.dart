import 'dart:convert';

class Imgur {
  final String id;
  final String title;
  final String link;
  final String cover;
  final bool isAlbum;
  final int commentCount;
  bool favorite;
  int favoriteCount;
  int points;
  String vote;

  Imgur({this.id, this.title, this.link, this.cover, this.isAlbum, this.commentCount, this.favoriteCount, this.points, this.vote, this.favorite = false});

  factory Imgur.fromJson(Map<String, dynamic> json) {
    return Imgur(
        id: json['id'],
        title: json['title'],
        link: json['link'],
        cover: json['cover'],
        isAlbum: json['is_album'],
        commentCount: json['comment_count'],
        favoriteCount: json['favorite_count'],
        points: json['points'],
        vote: json['vote'],
        favorite: (json['favorite'] ?? false));
  }

  static List<Imgur> allFromResponse(String response) {
    var decodedJson = json.decode(response).cast<String, dynamic>();

    return decodedJson['data'].cast<Map<String, dynamic>>().map((obj) => Imgur.fromJson(obj)).toList().cast<Imgur>();
  }

  static List<Imgur> allFromResponseTag(String response) {
    var decodedJson = json.decode(response).cast<String, dynamic>();

    return decodedJson['data']['items'].cast<Map<String, dynamic>>().map((obj) => Imgur.fromJson(obj)).toList().cast<Imgur>();
  }
}
