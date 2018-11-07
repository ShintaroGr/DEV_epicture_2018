import 'package:dev_epicture_2018/account.dart';
import 'package:dev_epicture_2018/data/imgur.dart';
import 'package:dev_epicture_2018/ui/imgur/details.dart';
import 'package:dev_epicture_2018/ui/imgur/userDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:flutter_advanced_networkimage/transition_to_image.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';

class ImgurCard extends StatefulWidget {
  final Imgur imgur;
  final actionBar;

  ImgurCard({@required this.imgur, this.actionBar});

  @override
  _ImgurCardState createState() => _ImgurCardState(imgur: this.imgur, actionBar: this.actionBar);
}

class _ImgurCardState extends State<ImgurCard> {
  bool cannotLoad = false;
  final actionBar;
  Imgur imgur;
  Size size;

  _ImgurCardState({this.imgur, this.actionBar});

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

  Widget _buildCardHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 15.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: AdvancedNetworkImage('https://imgur.com/user/' + imgur.author + '/avatar?maxwidth=290', scale: 5),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetails(username: imgur.author),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text(
                      imgur.title,
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    width: size.width * 0.7,
                  ),
                  Container(
                    child: Text(
                      imgur.author,
                      style: TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                    width: size.width * 0.7,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImgurDetails(imgur: imgur),
          ),
        );
      },
      child: TransitionToImage(
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
    );
  }

  Widget _buildActionBar() {
    return Row(
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
            imgur.favoriteCount != null ? imgur.favoriteCount.toString() : '',
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Card(
      color: Colors.black,
      margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 15.0, 4.0, 4.0),
          child: Column(
            children: <Widget>[
              _buildCardHeader(),
              _buildImage(),
              this.actionBar is Function ? this.actionBar(imgur) : _buildActionBar(),
            ],
          ),
        ),
      ),
    );
  }
}
