import 'package:dev_epicture_2018/ui/gallery/gallery.dart';
import 'package:flutter/material.dart';

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
              sort: 'hot',
              tag: this.tag,
            ),
            Gallery(
              sort: 'top',
              tag: this.tag,
            )
          ],
        ),
      ),
    );
  }
}
