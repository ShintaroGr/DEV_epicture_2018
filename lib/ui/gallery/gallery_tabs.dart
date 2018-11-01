import 'package:dev_epicture_2018/ui/gallery/gallery.dart';
import 'package:flutter/material.dart';

class GalleryTabs extends StatefulWidget {
  final String tag;

  GalleryTabs({this.tag = ''});

  @override
  _GalleryTabsState createState() => new _GalleryTabsState(tag: this.tag);
}

class _GalleryTabsState extends State<GalleryTabs> with SingleTickerProviderStateMixin {
  TabController _tabController;
  final String tag;

  _GalleryTabsState({this.tag = ''});

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
    return new Scaffold(
      backgroundColor: Color.fromARGB(255, 25, 25, 25),
      body: new Scaffold(
        appBar: new AppBar(
          automaticallyImplyLeading: false,
          title: new TabBar(
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
        body: new TabBarView(
          controller: _tabController,
          children: <Widget>[
            ImgurList(
              sort: 'hot',
              tag: this.tag,
            ),
            ImgurList(
              sort: 'top',
              tag: this.tag,
            )
          ],
        ),
      ),
    );
  }
}
