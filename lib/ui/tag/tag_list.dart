import 'dart:async';

import 'package:dev_epicture_2018/data/tags.dart';
import 'package:dev_epicture_2018/ui/gallery/tagged.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:http/http.dart' as http;

class TagListPage extends StatefulWidget {
  @override
  _TagListPageState createState() => _TagListPageState();
}

class _TagListPageState extends State<TagListPage> {
  List<Tag> _tags = [];

  @override
  void initState() {
    super.initState();
    _loadTag();
  }

  Future<void> _loadTag() async {
    http.Response response = await http.get('https://api.imgur.com/3/tags?client_id=4525911e004914a');

    setState(() {
      _tags += Tag.allFromResponse(response.body);
    });
  }

  Widget _buildTagListTile(BuildContext context, int index) {
    var tag = _tags[index];

    return Card(
      color: Colors.black,
      margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AdvancedNetworkImage(
              'https://i.imgur.com/' + tag.backgroundHash + '.png',
              useDiskCache: true,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: MaterialButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TagPage(tag: tag.name)),
            );
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 15.0, 4.0, 15.0),
              child: Column(
                children: <Widget>[
                  Text(
                    tag.displayName,
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_tags.isEmpty) {
      content = Center(
        child: CircularProgressIndicator(),
      );
    } else {
      content = ListView.builder(
        itemCount: _tags.length,
        itemBuilder: _buildTagListTile,
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Tags'),
      ),
      backgroundColor: Color.fromARGB(255, 50, 50, 50),
      body: content,
    );
  }
}
