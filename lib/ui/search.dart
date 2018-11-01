import 'package:dev_epicture_2018/data/imgur.dart';
import 'package:dev_epicture_2018/ui/imgur/simple_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Define a Custom Form Widget
class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

// Define a corresponding State class. This class will hold the data related to
// our Form.
class _SearchState extends State<Search> {
  List<Imgur> _imgurs = [];
  String _searchText;
  int _currentPage = 0;

  void search(String text) {
    setState(() {
      this._searchText = text;
    });
    _loadImgur(page: 0);
  }

  Future<void> _loadImgur({int page = 0}) async {
    http.Response response;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    response = await http.get(
        'https://api.imgur.com/3/gallery/search/hot?client_id=4525911e004914a&album_previews=true&mature=true&q=' + this._searchText + '/' + page.toString(),
        headers: prefs.getString('access_token') != null ? {'Authorization': 'Bearer ' + prefs.getString('access_token')} : {});
    setState(() {
      if (_imgurs.isEmpty)
        _imgurs = Imgur.allFromResponse(response.body);
      else {
        _imgurs = new List.from(_imgurs)..addAll(Imgur.allFromResponse(response.body));
      }
    });
  }

  Widget _buildImgurListTile(BuildContext context, int index) {
    var imgur = _imgurs[index];

    return new ImgurCard(
      imgur: imgur,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_searchText == null || _searchText.isEmpty) {
      content = new Center(
        child: new Icon(
          Icons.search,
          size: 80.0,
          color: Colors.white,
        ),
      );
    } else if (_imgurs.isEmpty) {
      content = new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      content = new ListView.builder(
        itemCount: _imgurs.length,
        itemBuilder: _buildImgurListTile,
      );
    }

    return Scaffold(
      appBar: new AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Please enter a search term',
            hintStyle: new TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
            fillColor: Colors.white,
          ),
          style: new TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
          onSubmitted: (text) {
            search(text);
          },
        ),
      ),
      body: content,
      backgroundColor: Color.fromARGB(255, 25, 25, 25),
    );
  }
}
