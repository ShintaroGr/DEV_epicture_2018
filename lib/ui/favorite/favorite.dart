import 'dart:async';

import 'package:dev_epicture_2018/data/imgur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Favorite extends StatefulWidget {
  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  List<Imgur> _imgurs = [];
  int _currentPage;
  ScrollController _scrollController;
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;

  @override
  void initState() {
    _loadImgur();
    _currentPage = 0;
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    _scrollController = ScrollController();
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
    response = await http.get('https://api.imgur.com/3/account/me/favorites/' + page.toString(), headers: {'Authorization': 'Bearer ' + prefs.getString('access_token')});
    setState(() {
      if (_imgurs.isEmpty)
        _imgurs = Imgur.allFromResponse(response.body);
      else {
        _imgurs = List.from(_imgurs)..addAll(Imgur.allFromResponse(response.body));
      }
    });
  }

  Widget _buildFavoriteTile(BuildContext context, int index) {
    var imgur = _imgurs[index];

    return Card(
      color: Colors.black,
      margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: InkWell(
        onTap: () {},
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 15.0, 4.0, 4.0),
            child: Column(
              children: <Widget>[
                Text(
                  imgur.title,
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
                  child: ButtonBar(
                    children: <Widget>[
                      FlatButton.icon(
                        icon: Icon(Icons.favorite_border),
                        label: Text('Unfavorite'),
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          if (imgur.isAlbum)
                            await http.post('https://api.imgur.com/3/album/' + imgur.id + '/favorite', headers: {'Authorization': 'Bearer ' + prefs.getString('access_token')});
                          else
                            await http.post('https://api.imgur.com/3/image/' + imgur.id + '/favorite', headers: {'Authorization': 'Bearer ' + prefs.getString('access_token')});
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

    if (_imgurs.isEmpty) {
      content = Center(
        child: CircularProgressIndicator(),
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
          return null;
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _imgurs.length,
          itemBuilder: _buildFavoriteTile,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 50, 50, 50),
      body: content,
    );
  }
}
