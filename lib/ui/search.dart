import 'package:dev_epicture_2018/data/imgur.dart';
import 'package:dev_epicture_2018/ui/gallery/gallery.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String _searchText;
  final GlobalKey<GalleryState> _key = GlobalKey<GalleryState>();

  void search(String text) {
    setState(() {
      this._searchText = text;
    });
    _key.currentState.refresh();
  }

  getData({int page = 0}) async {
    http.Response response;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    response = await http.get('https://api.imgur.com/3/gallery/search/hot/' + page.toString() + '?client_id=4525911e004914a&album_previews=true&mature=true&q=' + this._searchText,
        headers: prefs.getString('access_token') != null ? {'Authorization': 'Bearer ' + prefs.getString('access_token')} : {});
    return Imgur.allFromResponse(response.body);
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_searchText == null || _searchText.isEmpty) {
      content = Center(
        child: Icon(
          Icons.search,
          size: 80.0,
          color: Colors.white,
        ),
      );
    } else {
      content = Gallery(
        key: _key,
        dataCallback: (page) => getData(page: page),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Please enter a search term',
            hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
            fillColor: Colors.white,
          ),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
          onSubmitted: (text) => search(text),
        ),
      ),
      body: content,
      backgroundColor: Color.fromARGB(255, 25, 25, 25),
    );
  }
}
