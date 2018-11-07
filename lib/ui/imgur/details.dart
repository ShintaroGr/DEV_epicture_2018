import 'package:dev_epicture_2018/account.dart';
import 'package:dev_epicture_2018/data/comment.dart';
import 'package:dev_epicture_2018/data/imgur.dart';
import 'package:dev_epicture_2018/ui/imgur/comment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:flutter_advanced_networkimage/transition_to_image.dart';
import 'package:http/http.dart' as http;

class ImgurDetails extends StatefulWidget {
  final Imgur imgur;
  final actionBar;

  ImgurDetails({this.imgur, this.actionBar});

  @override
  _ImgurDetailsState createState() => _ImgurDetailsState(imgur: this.imgur, actionBar: this.actionBar);
}

class _ImgurDetailsState extends State<ImgurDetails> {
  Imgur imgur;
  final actionBar;
  List<Comment> _comments = [];

  _ImgurDetailsState({this.imgur, this.actionBar});

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future voteUp(Imgur imgur) async {
    http.Response response;
    String oldVote;
    int oldPoints;

    oldVote = imgur.vote;
    oldPoints = imgur.points;
    if (imgur.vote == 'up') {
      setState(() {
        imgur.vote = 'veto';
        imgur.points -= 1;
      });
      response = await http.post(
        'https://api.imgur.com/3/gallery/' + imgur.id + '/vote/veto',
        headers: await Account.getHeader(context: context, important: true),
      );
      if (response.statusCode != 200)
        setState(() {
          imgur.vote = oldVote;
          imgur.points = oldPoints;
        });
    } else if (imgur.vote == null || imgur.vote == 'veto') {
      setState(() {
        imgur.vote = 'up';
        imgur.points += 1;
      });
      response = await http.post(
        'https://api.imgur.com/3/gallery/' + imgur.id + '/vote/up',
        headers: await Account.getHeader(context: context, important: true),
      );
      if (response.statusCode != 200)
        setState(() {
          imgur.vote = oldVote;
          imgur.points = oldPoints;
        });
    } else {
      setState(() {
        imgur.vote = 'up';
        imgur.points += 2;
      });
      response = await http.post(
        'https://api.imgur.com/3/gallery/' + imgur.id + '/vote/up',
        headers: await Account.getHeader(context: context, important: true),
      );
      if (response.statusCode != 200)
        setState(() {
          imgur.vote = oldVote;
          imgur.points = oldPoints;
        });
    }
  }

  Future voteDown(Imgur imgur) async {
    http.Response response;
    String oldVote;
    int oldPoints;

    oldVote = imgur.vote;
    oldPoints = imgur.points;
    if (imgur.vote == 'down') {
      setState(() {
        imgur.vote = 'veto';
        imgur.points += 1;
      });
      response = await http.post(
        'https://api.imgur.com/3/gallery/' + imgur.id + '/vote/veto',
        headers: await Account.getHeader(context: context, important: true),
      );
      if (response.statusCode != 200)
        setState(() {
          imgur.vote = oldVote;
          imgur.points = oldPoints;
        });
    } else if (imgur.vote == null || imgur.vote == 'veto') {
      setState(() {
        imgur.vote = 'down';
        imgur.points -= 1;
      });
      response = await http.post(
        'https://api.imgur.com/3/gallery/' + imgur.id + '/vote/down',
        headers: await Account.getHeader(context: context, important: true),
      );
      if (response.statusCode != 200)
        setState(() {
          imgur.vote = oldVote;
          imgur.points = oldPoints;
        });
    } else {
      setState(() {
        imgur.vote = 'down';
        imgur.points -= 2;
      });
      response = await http.post(
        'https://api.imgur.com/3/gallery/' + imgur.id + '/vote/down',
        headers: await Account.getHeader(context: context, important: true),
      );
      if (response.statusCode != 200)
        setState(() {
          imgur.vote = oldVote;
          imgur.points = oldPoints;
        });
    }
  }

  Future fav(Imgur imgur) async {
    http.Response response;
    int oldFavoriteCount = imgur.favoriteCount;
    setState(() {
      if (imgur.favoriteCount != null) {
        if (imgur.favorite)
          imgur.favoriteCount -= 1;
        else
          imgur.favoriteCount += 1;
      }
      imgur.favorite = !imgur.favorite;
    });
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
    if (response.statusCode != 200)
      setState(() {
        imgur.favoriteCount = oldFavoriteCount;
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
          TransitionToImage(
            AdvancedNetworkImage(
              imgur.cover == null ? imgur.link : 'https://i.imgur.com/' + imgur.cover + '.gif',
              useDiskCache: true,
              retryLimit: 2,
            ),
            placeholder: const Icon(
              Icons.close,
              size: 50,
            ),
          ),
          actionBar(imgur),
        ]..addAll(List.generate(_comments.length, _buildCommentTile)),
      ),
    );
  }
}
