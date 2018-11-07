import 'package:dev_epicture_2018/account.dart';
import 'package:dev_epicture_2018/data/comment.dart';
import 'package:dev_epicture_2018/data/imgur.dart';
import 'package:dev_epicture_2018/ui/imgur/comment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';

class ImgurDetails extends StatefulWidget {
  final Imgur imgur;

  ImgurDetails({this.imgur});

  @override
  _ImgurDetailsState createState() => _ImgurDetailsState(imgur: this.imgur);
}

class _ImgurDetailsState extends State<ImgurDetails> {
  Imgur imgur;
  List<Comment> _comments = [];

  _ImgurDetailsState({this.imgur});

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future voteUp(Imgur imgur) async {
    http.Response response;
    if (imgur.vote == 'up') {
      response = await http.post(
        'https://api.imgur.com/3/gallery/' + imgur.id + '/vote/veto',
        headers: await Account.getHeader(context: context, important: true),
      );
      if (response.statusCode == 200)
        setState(() {
          imgur.vote = 'veto';
          imgur.points -= 1;
        });
    } else if (imgur.vote == null || imgur.vote == 'veto') {
      response = await http.post(
        'https://api.imgur.com/3/gallery/' + imgur.id + '/vote/up',
        headers: await Account.getHeader(context: context, important: true),
      );
      if (response.statusCode == 200)
        setState(() {
          imgur.vote = 'up';
          imgur.points += 1;
        });
    } else {
      response = await http.post(
        'https://api.imgur.com/3/gallery/' + imgur.id + '/vote/up',
        headers: await Account.getHeader(context: context, important: true),
      );
      if (response.statusCode == 200)
        setState(() {
          imgur.vote = 'up';
          imgur.points += 2;
        });
    }
  }

  Future voteDown(Imgur imgur) async {
    http.Response response;
    if (imgur.vote == 'down') {
      response = await http.post(
        'https://api.imgur.com/3/gallery/' + imgur.id + '/vote/veto',
        headers: await Account.getHeader(context: context, important: true),
      );
      if (response.statusCode == 200)
        setState(() {
          imgur.vote = 'veto';
          imgur.points += 1;
        });
    } else if (imgur.vote == null || imgur.vote == 'veto') {
      response = await http.post(
        'https://api.imgur.com/3/gallery/' + imgur.id + '/vote/down',
        headers: await Account.getHeader(context: context, important: true),
      );
      if (response.statusCode == 200)
        setState(() {
          imgur.vote = 'down';
          imgur.points -= 1;
        });
    } else {
      response = await http.post(
        'https://api.imgur.com/3/gallery/' + imgur.id + '/vote/down',
        headers: await Account.getHeader(context: context, important: true),
      );
      if (response.statusCode == 200)
        setState(() {
          imgur.vote = 'down';
          imgur.points -= 2;
        });
    }
  }

  Future fav(Imgur imgur) async {
    http.Response response;
    if (imgur.isAlbum)
      response = await http.post(
        'https://api.imgur.com/3/album/' + imgur.id + '/favorite',
        headers: await Account.getHeader(context: context, important: true),
      );
    else
      response = await http.post(
        'https://api.imgur.com/3/image/' + imgur.id + '/favorite',
        headers: await Account.getHeader(context: context, important: true),
      );
    if (response.statusCode == 200)
      setState(() {
        if (imgur.favoriteCount != null) {
          if (imgur.favorite)
            imgur.favoriteCount -= 1;
          else
            imgur.favoriteCount += 1;
        }
        imgur.favorite = !imgur.favorite;
      });
  }

  Future<void> _loadComments() async {
    http.Response response;
    response = await http.get(
      'https://api.imgur.com/3/gallery/' + imgur.id + '/comments?client_id=4525911e004914a',
      headers: await Account.getHeader(context: context),
    );
    setState(() {
      _comments = Comment.allFromResponse(response.body);
    });
  }

  Widget _buildCommentTile(int index) {
    var comment = _comments[index];

    return CommentCard(comment: comment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 25, 25, 25),
      appBar: AppBar(
        title: Text(imgur.title),
      ),
      body: ListView(
        cacheExtent: 500,
        children: <Widget>[
          Image(
            image: AdvancedNetworkImage(
              imgur.cover == null ? imgur.link : 'https://i.imgur.com/' + imgur.cover + '.png',
              useDiskCache: true,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () async {
                      await voteUp(imgur);
                    },
                    icon: Icon(
                      Icons.arrow_upward,
                      color: imgur.vote == "up" ? Colors.white : Colors.grey,
                    ),
                  ),
                  Text(
                    imgur.points.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () async {
                      await voteDown(imgur);
                    },
                    icon: Icon(
                      Icons.arrow_downward,
                      color: imgur.vote == "down" ? Colors.white : Colors.grey,
                    ),
                  ),
                ],
              ),
              FlatButton.icon(
                onPressed: () async {
                  await fav(imgur);
                },
                icon: imgur.favorite
                    ? Icon(
                        Icons.favorite,
                        color: Colors.white,
                      )
                    : Icon(
                        Icons.favorite_border,
                        color: Colors.grey,
                      ),
                label: Text(
                  (imgur.favoriteCount ?? '').toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              FlatButton.icon(
                onPressed: () {
                  Share.share(imgur.title + '\n' + imgur.link);
                },
                icon: Icon(
                  Icons.share,
                  color: Colors.white,
                ),
                label: Text(
                  'Share',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ]..addAll(List.generate(_comments.length, _buildCommentTile)),
      ),
    );
  }
}
