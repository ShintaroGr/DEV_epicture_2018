import 'package:dev_epicture_2018/data/imgur.dart';
import 'package:dev_epicture_2018/ui/gallery/gallery.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Favorite extends StatefulWidget {
  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  getData({int page = 0}) async {
    http.Response response;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    response = await http.get('https://api.imgur.com/3/account/me/favorites/' + page.toString(), headers: {'Authorization': 'Bearer ' + prefs.getString('access_token')});
    return Imgur.allFromResponse(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Gallery(
      dataCallback: (page) => getData(page: page),
    );
  }
}
