import 'dart:convert';

class Imgur {
  final String id;
  final String title;
  final String link;
  final String cover;
  final bool isAlbum;
  final String author;
  final int commentCount;
  bool favorite;
  int favoriteCount;
  int points;
  String vote;

  Imgur({this.id, this.title, this.link, this.cover, this.isAlbum, this.commentCount, this.favoriteCount, this.points, this.vote, this.favorite = false, this.author});

  factory Imgur.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'video/mp4')
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
        favorite: (json['favorite'] ?? false),
        author: json['account_url'],
      );
    return null;
  }

  static List<Imgur> allFromResponse(String response) {
    var decodedJson = json.decode(response).cast<String, dynamic>();

    var list = decodedJson['data'].cast<Map<String, dynamic>>().map((obj) => Imgur.fromJson(obj)).toList().cast<Imgur>();
    list.removeWhere((value) => value == null);
    list.where((x) => x == null).forEach(print);
    return list;
  }

  static List<Imgur> allFromResponseTag(String response) {
    var decodedJson = json.decode(response).cast<String, dynamic>();

    return decodedJson['data']['items'].cast<Map<String, dynamic>>().map((obj) => Imgur.fromJson(obj)).toList().cast<Imgur>();
  }
}
