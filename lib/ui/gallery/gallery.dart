import 'dart:async';

import 'package:dev_epicture_2018/data/imgur.dart';
import 'package:dev_epicture_2018/ui/imgur/simple_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ImgurList extends StatefulWidget {
  final String tag;
  final String sort;

  ImgurList({this.tag = '', this.sort = 'hot'});

  @override
  _ImgurListState createState() => new _ImgurListState(tag: this.tag, sort: this.sort);
}

class _ImgurListState extends State<ImgurList> {
  List<Imgur> _imgurs = [];
  int _currentPage;
  ScrollController _scrollController;
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;
  final String tag;
  final String sort;

  _ImgurListState({this.tag = '', this.sort = 'hot'});

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
    if (this.tag.isNotEmpty) {
      response = await http.get(
          'https://api.imgur.com/3/gallery/t/' + this.tag + '/' + this.sort + '/' + page.toString() + '?client_id=4525911e004914a&album_previews=true&mature=true',
          headers: prefs.getString('access_token') != null ? {'Authorization': 'Bearer ' + prefs.getString('access_token')} : {});
      setState(() {
        if (_imgurs.isEmpty)
          _imgurs = Imgur.allFromResponseTag(response.body);
        else {
          _imgurs = new List.from(_imgurs)..addAll(Imgur.allFromResponse(response.body));
        }
      });
    } else {
      response = await http.get('https://api.imgur.com/3/gallery/' + this.sort + '/' + page.toString() + '?client_id=4525911e004914a&album_previews=true&mature=true',
          headers: prefs.getString('access_token') != null ? {'Authorization': 'Bearer ' + prefs.getString('access_token')} : {});
      setState(() {
        if (_imgurs.isEmpty)
          _imgurs = Imgur.allFromResponse(response.body);
        else {
          _imgurs = new List.from(_imgurs)..addAll(Imgur.allFromResponse(response.body));
        }
      });
    }
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

    if (_imgurs.isEmpty) {
      content = new Center(
        child: new CircularProgressIndicator(),
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
          itemBuilder: _buildImgurListTile,
        ),
      );
    }

    return new Scaffold(
      backgroundColor: Color.fromARGB(255, 25, 25, 25),
      body: content,
    );
  }
}
