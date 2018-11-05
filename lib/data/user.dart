import 'dart:convert';

class User {
  final int id;
  final String url;
  final String bio;
  final String avatar;
  final String cover;
  final int reputation;
  final String reputationName;

  User({this.id, this.url, this.bio, this.cover, this.avatar, this.reputation, this.reputationName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      url: json['url'],
      bio: json['bio'],
      cover: json['cover'],
      avatar: json['avatar'],
      reputation: json['reputation'],
      reputationName: json['reputation_name'],
    );
  }

  static List<User> allFromResponse(String response) {
    var decodedJson = json.decode(response).cast<String, dynamic>();

    return decodedJson['data'].cast<Map<String, dynamic>>().map((obj) => User.fromJson(obj)).toList().cast<User>();
  }

  static User fromResponse(String response) {
    var decodedJson = json.decode(response)['data'].cast<String, dynamic>();

    return User.fromJson(decodedJson);
  }
}
