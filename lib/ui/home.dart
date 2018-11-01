import 'dart:async';
import 'dart:io';

import 'package:dev_epicture_2018/ui/favorite/favorite.dart';
import 'package:dev_epicture_2018/ui/gallery/gallery_tabs.dart';
import 'package:dev_epicture_2018/ui/my_gallery/gallery.dart';
import 'package:dev_epicture_2018/ui/search.dart';
import 'package:dev_epicture_2018/ui/tag/tag_list.dart';
import 'package:dev_epicture_2018/ui/upload/upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _currentIndex = 0;
  List<Widget> _children = [new GalleryTabs(), new Search(), new Favorite(), new MyGallery()];

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

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<Stream<String>> _server() async {
    final StreamController<String> onCode = new StreamController();
    HttpServer server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    server.listen((HttpRequest request) async {
      request.response
        ..statusCode = 200
        ..headers.set("Content-Type", ContentType.html.mimeType)
        ..write("<html><body bgcolor='#000000'></body></html>"
            "<script>"
            "if (location.hash.substring(1)) {console.log('http://localhost:8080/?' + location.hash.substring(1));window.location = 'http://localhost:8080/?' + location.hash.substring(1);}"
            "</script>");
      await request.response.close();
      if (request.uri.queryParameters.isNotEmpty) {
        await server.close(force: true);
        onCode.add(request.uri.queryParameters["access_token"]);
        onCode.add(request.uri.queryParameters["refresh_token"]);
        onCode.close();
        return onCode.stream;
      }
    });
    return onCode.stream;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        bottomNavigationBar: new Theme(
          data: Theme.of(context)
              .copyWith(canvasColor: Colors.black, primaryColor: Colors.white, textTheme: Theme.of(context).textTheme.copyWith(caption: new TextStyle(color: Colors.grey))),
          child: new BottomNavigationBar(
            onTap: onTabTapped,
            type: BottomNavigationBarType.fixed,
            currentIndex: this._currentIndex,
            items: [
              new BottomNavigationBarItem(
                icon: new Icon(Icons.home),
                title: new Text("Home"),
              ),
              new BottomNavigationBarItem(
                icon: new Icon(Icons.search),
                title: new Text("Search"),
              ),
              new BottomNavigationBarItem(
                icon: new Icon(Icons.favorite),
                title: new Text("Favorite"),
              ),
              new BottomNavigationBarItem(
                icon: new Icon(Icons.image),
                title: new Text("My"),
              ),
            ],
          ),
        ),
        drawer: Drawer(
          child: new Scaffold(
            appBar: new AppBar(
              automaticallyImplyLeading: false,
              title: new ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  new MaterialButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                          builder: (context) => WebviewScaffold(
                                url: "https://api.imgur.com/oauth2/authorize?client_id=4525911e004914a&response_type=token",
                                appBar: new AppBar(
                                  title: const Text('Login'),
                                ),
                                withZoom: true,
                                withLocalStorage: true,
                                withJavascript: true,
                                userAgent: 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36',
                              ),
                        ),
                      );
                      Stream<String> onCode = await _server();
                      List<String> tokens = [];
                      await onCode.forEach((value) {
                        tokens.add(value);
                      });
                      Navigator.pop(context);
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString('access_token', tokens[0]);
                      await prefs.setString('refresh_token', tokens[1]);
                    },
                    child: new Row(
                      children: <Widget>[
                        new Icon(
                          Icons.account_circle,
                          color: Colors.white,
                        ),
                        new Text(
                          " Login",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  new MaterialButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        new MaterialPageRoute(builder: (context) => Upload()),
                      );
                    },
                    child: new Row(
                      children: <Widget>[
                        new Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        new Text(
                          " Upload",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: new TagListPage(),
          ),
        ),
        appBar: new AppBar(
          title: new Text('Epicture {Imgur}'),
          actions: <Widget>[],
        ),
        backgroundColor: Color.fromARGB(255, 50, 50, 50),
        body: this._children[this._currentIndex]);
  }
}
