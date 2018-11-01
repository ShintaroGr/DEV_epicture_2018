import 'dart:async';
import 'dart:io';

import 'package:dev_epicture_2018/ui/gallery/favorite.dart';
import 'package:dev_epicture_2018/ui/gallery/gallery_tabs.dart';
import 'package:dev_epicture_2018/ui/gallery/my.dart';
import 'package:dev_epicture_2018/ui/gallery/search.dart';
import 'package:dev_epicture_2018/ui/tag/tag_list.dart';
import 'package:dev_epicture_2018/ui/upload/upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _currentIndex = 0;
  List<Widget> _children = [GalleryTabs(), Search(), Favorite(), MyGallery()];

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
    final StreamController<String> onCode = StreamController();
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
    return Scaffold(
        bottomNavigationBar: Theme(
          data: Theme.of(context)
              .copyWith(canvasColor: Colors.black, primaryColor: Colors.white, textTheme: Theme.of(context).textTheme.copyWith(caption: TextStyle(color: Colors.grey))),
          child: BottomNavigationBar(
            onTap: onTabTapped,
            type: BottomNavigationBarType.fixed,
            currentIndex: this._currentIndex,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Text("Home"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                title: Text("Search"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                title: Text("Favorite"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.image),
                title: Text("My"),
              ),
            ],
          ),
        ),
        drawer: Drawer(
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebviewScaffold(
                                url: "https://api.imgur.com/oauth2/authorize?client_id=4525911e004914a&response_type=token",
                                appBar: AppBar(
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
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.account_circle,
                          color: Colors.white,
                        ),
                        Text(
                          " Login",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Upload()),
                      );
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        Text(
                          " Upload",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: TagListPage(),
          ),
        ),
        appBar: AppBar(
          title: Text('Epicture {Imgur}'),
          actions: <Widget>[],
        ),
        backgroundColor: Color.fromARGB(255, 50, 50, 50),
        body: this._children[this._currentIndex]);
  }
}
