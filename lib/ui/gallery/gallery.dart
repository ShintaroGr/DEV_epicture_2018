import 'dart:async';

import 'package:dev_epicture_2018/data/imgur.dart';
import 'package:dev_epicture_2018/ui/imgur/card.dart';
import 'package:flutter/material.dart';

class Gallery extends StatefulWidget {
  final cardActions;
  final dataCallback;

  Gallery({@required this.dataCallback, this.cardActions, Key key}) : super(key: key);

  @override
  GalleryState createState() => GalleryState(dataCallback: this.dataCallback, cardActions: this.cardActions);
}

class GalleryState extends State<Gallery> {
  final cardActions;
  List<Imgur> _imgurs;
  int _currentPage;
  ScrollController _scrollController;
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;
  final dataCallback;

  GalleryState({@required this.dataCallback, this.cardActions});

  refresh() {
    setState(() {
      this._imgurs = null;

      this.dataCallback(this._currentPage).then((res) {
        if (!this.mounted) {
          return;
        }
        setState(() {
          this._currentPage = 0;
          this._imgurs = res;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadImgur(page: 0);
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
  }

  @override
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadImgur({int page = 0}) async {
    List<Imgur> response = await dataCallback(page);
    if (this.mounted) {
      setState(() {
        if (_imgurs == null || _imgurs.isEmpty)
          _imgurs = response;
        else {
          _imgurs = List.from(_imgurs)..addAll(response);
        }
      });
    }
  }

  Widget _buildGalleryTile(BuildContext context, int index) {
    var imgur = _imgurs[index];

    return ImgurCard(
      actionBar: this.cardActions,
      imgur: imgur,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_imgurs == null) {
      content = Center(
        child: CircularProgressIndicator(),
      );
    } else if (_imgurs.isEmpty) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.search,
              size: 150,
              color: Colors.white,
            ),
            Text(
              'Nohting to show here',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      );
    } else {
      content = RefreshIndicator(
        color: Colors.black,
        key: _refreshIndicatorKey,
        onRefresh: () {
          setState(() {
            _imgurs = null;
            _loadImgur();
          });
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _imgurs.length,
          itemBuilder: _buildGalleryTile,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 25, 25, 25),
      body: content,
    );
  }
}
