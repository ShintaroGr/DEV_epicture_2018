import 'package:dev_epicture_2018/account.dart';
import 'package:dev_epicture_2018/ui/gallery/gallery_tabs.dart';
import 'package:dev_epicture_2018/ui/gallery/my.dart';
import 'package:dev_epicture_2018/ui/gallery/search.dart';
import 'package:dev_epicture_2018/ui/tag/tag_list.dart';
import 'package:dev_epicture_2018/ui/upload/upload.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _currentIndex = 0;
  bool logged = false;
  List<Widget> _children = [GalleryTabs(), Search(), MyDetails()];

  Future checkLogin() async {
    final isLogged = await Account.isAuthenticated();
    setState(() {
      logged = isLogged;
    });
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
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
                icon: Icon(Icons.account_circle),
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
                  logged
                      ? Account.buildLogoutButton(context)
                      : Account.buildLoginButton(
                          context,
                          textColor: Colors.white,
                          showIcon: true,
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
