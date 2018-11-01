import 'package:dev_epicture_2018/data/imgur.dart';
import 'package:dev_epicture_2018/ui/gallery/gallery.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GalleryTabs extends StatefulWidget {
  final String tag;

  GalleryTabs({this.tag = ''});

  @override
  _GalleryTabsState createState() => _GalleryTabsState(tag: this.tag);
}

class _GalleryTabsState extends State<GalleryTabs> with SingleTickerProviderStateMixin {
  TabController _tabController;
  final String tag;

  _GalleryTabsState({this.tag = ''});

  getData({int page = 0, String sort, String tag}) async {
    http.Response response;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (tag.isNotEmpty) {
      response = await http.get('https://api.imgur.com/3/gallery/t/' + tag + '/' + sort + '/' + page.toString() + '?client_id=4525911e004914a&album_previews=true&mature=true',
          headers: prefs.getString('access_token') != null ? {'Authorization': 'Bearer ' + prefs.getString('access_token')} : {});
      return Imgur.allFromResponseTag(response.body);
    } else {
      response = await http.get('https://api.imgur.com/3/gallery/' + sort + '/' + page.toString() + '?client_id=4525911e004914a&album_previews=true&mature=true',
          headers: prefs.getString('access_token') != null ? {'Authorization': 'Bearer ' + prefs.getString('access_token')} : {});
      return Imgur.allFromResponse(response.body);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 25, 25, 25),
      body: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: 'Hot',
              ),
              Tab(
                text: 'Top',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Gallery(
              dataCallback: (page) => getData(page: page, sort: 'hot', tag: this.tag),
            ),
            Gallery(
              dataCallback: (page) => getData(page: page, sort: 'top', tag: this.tag),
            )
          ],
        ),
      ),
    );
  }
}
