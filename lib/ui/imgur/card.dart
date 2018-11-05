import 'package:dev_epicture_2018/data/imgur.dart';
import 'package:dev_epicture_2018/ui/imgur/details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImgurCard extends StatefulWidget {
  final Imgur imgur;

  ImgurCard({this.imgur});

  @override
  _ImgurCardState createState() => _ImgurCardState(imgur: this.imgur);
}

class _ImgurCardState extends State<ImgurCard> {
  Imgur imgur;

  _ImgurCardState({this.imgur});

  Future voteUp(Imgur imgur) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (imgur.vote == 'up') {
      await http.post('https://api.imgur.com/3/gallery/' + imgur.id + '/vote/veto', headers: {'Authorization': 'Bearer ' + prefs.getString('access_token')});
      setState(() {
        imgur.vote = 'veto';
        imgur.points -= 1;
      });
    } else if (imgur.vote == null || imgur.vote == 'veto') {
      await http.post('https://api.imgur.com/3/gallery/' + imgur.id + '/vote/up', headers: {'Authorization': 'Bearer ' + prefs.getString('access_token')});
      setState(() {
        imgur.vote = 'up';
        imgur.points += 1;
      });
    } else {
      await http.post('https://api.imgur.com/3/gallery/' + imgur.id + '/vote/up', headers: {'Authorization': 'Bearer ' + prefs.getString('access_token')});
      setState(() {
        imgur.vote = 'up';
        imgur.points += 2;
      });
    }
  }

  Future voteDown(Imgur imgur) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (imgur.vote == 'down') {
      await http.post('https://api.imgur.com/3/gallery/' + imgur.id + '/vote/veto', headers: {'Authorization': 'Bearer ' + prefs.getString('access_token')});
      setState(() {
        imgur.vote = 'veto';
        imgur.points += 1;
      });
    } else if (imgur.vote == null || imgur.vote == 'veto') {
      await http.post('https://api.imgur.com/3/gallery/' + imgur.id + '/vote/down', headers: {'Authorization': 'Bearer ' + prefs.getString('access_token')});
      setState(() {
        imgur.vote = 'down';
        imgur.points -= 1;
      });
    } else {
      await http.post('https://api.imgur.com/3/gallery/' + imgur.id + '/vote/down', headers: {'Authorization': 'Bearer ' + prefs.getString('access_token')});
      setState(() {
        imgur.vote = 'down';
        imgur.points -= 2;
      });
    }
  }

  Future fav(Imgur imgur) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (imgur.isAlbum)
      await http.post('https://api.imgur.com/3/album/' + imgur.id + '/favorite', headers: {'Authorization': 'Bearer ' + prefs.getString('access_token')});
    else
      await http.post('https://api.imgur.com/3/image/' + imgur.id + '/favorite', headers: {'Authorization': 'Bearer ' + prefs.getString('access_token')});
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: InkWell(
        onTap: () {},
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 15.0, 4.0, 4.0),
            child: Column(
              children: <Widget>[
                Text(
                  imgur.title,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Divider(
                  color: Colors.grey,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImgurDetails(imgur: imgur),
                      ),
                    );
                  },
                  child: Image(
                    image: AdvancedNetworkImage(
                      imgur.cover == null ? imgur.link : 'https://i.imgur.com/' + imgur.cover + '.png',
                      useDiskCache: true,
                    ),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
