import 'dart:async';

import 'package:dev_epicture_2018/data/imgur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyGallery extends StatefulWidget {
  @override
  _MyGalleryState createState() => new _MyGalleryState();
}

class _MyGalleryState extends State<MyGallery> {
  List<Imgur> _imgurs;
  int _currentPage;
  ScrollController _scrollController;
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;

  @override
  void initState() {
    _loadImgur();
    _currentPage = 0;
    _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = 200.0;
      if (maxScroll - currentScroll <= delta) {
        this._currentPage += 1;
        _loadImgur(page: _currentPage);
      }
    });
    super.initState();
  }

  @override
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadImgur({int page = 0}) async {
    http.Response response;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    response = await http.get(
      'https://api.imgur.com/3/account/me/images/' + page.toString() + '?client_id=4525911e004914a&album_previews=true&mature=true',
      headers: {'Authorization': 'Bearer ' + prefs.getString('access_token')},
    );
    setState(() {
      if (_imgurs == null || _imgurs.isEmpty)
        _imgurs = Imgur.allFromResponse(response.body);
      else {
        _imgurs = new List.from(_imgurs)..addAll(Imgur.allFromResponse(response.body));
      }
    });
  }

  Widget _buildMyGalleryTile(BuildContext context, int index) {
    var imgur = _imgurs[index];

    return new Card(
      color: Colors.black,
      margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: new InkWell(
        onTap: () {},
        child: new Center(
          child: new Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 15.0, 4.0, 4.0),
            child: new Column(
              children: <Widget>[
                Text(
                  imgur.title == null ? '' : imgur.title,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Divider(
                  color: Colors.grey,
                ),
                Image(
                  image: AdvancedNetworkImage(
                    imgur.cover == null ? imgur.link : 'https://i.imgur.com/' + imgur.cover + '.png',
                    useDiskCache: true,
                  ),
                ),
                ButtonTheme.bar(
                  // make buttons use the appropriate styles for cards
                  child: ButtonBar(
                    children: <Widget>[
                      FlatButton.icon(
                        icon: Icon(Icons.delete_forever),
                        label: Text('Delete'),
                        onPressed: () async {
                          http.Response response;
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          response = await http.delete(
                            'https://api.imgur.com/3/account/me/image/' + imgur.id + '?client_id=4525911e004914a&album_previews=true&mature=true',
                            headers: {'Authorization': 'Bearer ' + prefs.getString('access_token')},
                          );
                          setState(() {
                            _imgurs.removeAt(_imgurs.indexWhere((item) => item.id == imgur.id));
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_imgurs == null) {
      content = new Center(
        child: new CircularProgressIndicator(),
      );
    } else if (_imgurs.isEmpty) {
      content = new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Icon(
              Icons.search,
              size: 150,
              color: Colors.white,
            ),
            new Text('Nohting to show here', style: TextStyle(color: Colors.white, fontSize: 20),),
          ],
        ),
      );
    } else {
      content = RefreshIndicator(
        color: Colors.black,
        key: _refreshIndicatorKey,
        onRefresh: () {
          setState(() {
            _imgurs = [];
            _loadImgur();
          });
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _imgurs.length,
          itemBuilder: _buildMyGalleryTile,
        ),
      );
    }

    return new Scaffold(
      backgroundColor: Color.fromARGB(255, 50, 50, 50),
      body: content,
    );
  }
}
