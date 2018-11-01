import 'package:dev_epicture_2018/ui/gallery/gallery_tabs.dart';
import 'package:flutter/material.dart';

class TagPage extends StatefulWidget {
  final String tag;

  TagPage({this.tag = ''});

  @override
  _TagPageState createState() => new _TagPageState(tag: this.tag);
}

class _TagPageState extends State<TagPage> with SingleTickerProviderStateMixin {
  final String tag;

  _TagPageState({this.tag = ''});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text(this.tag)),
        backgroundColor: Color.fromARGB(255, 50, 50, 50),
        body: GalleryTabs(
          tag: this.tag,
        ));
  }
}
