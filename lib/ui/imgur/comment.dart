import 'dart:convert';

import 'package:dev_epicture_2018/data/comment.dart';
import 'package:dev_epicture_2018/ui/imgur/userDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;

  CommentCard({this.comment});

  @override
  _CommentCardState createState() => _CommentCardState(comment: this.comment);
}

class _CommentCardState extends State<CommentCard> {
  Comment comment;

  _CommentCardState({this.comment});

  String getName(String name) {
    if (name.length >= 30)
      return name.substring(0, 30) + '...';
    else
      return name;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
          child: comment.children.length != 0
              ? ExpansionTile(
                  backgroundColor: Color.fromARGB(255, 50, 50, 50),
                  trailing: SizedBox(
                    width: 0.0,
                    height: 0.0,
                  ),
                  title: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Image(
                            image: AdvancedNetworkImage(
                              'https://imgur.com/user/' + comment.author + '/avatar?maxwidth=290',
                              useDiskCache: true,
                              scale: 5,
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetails(username: comment.author),
                                ),
                              );
                            },
                            child: Text(
                              getName(comment.author) ?? '',
                              style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.comment,
                                size: 15,
                                color: Colors.white,
                              ),
                              Text(
                                ' ' + comment.children.length.toString(),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Divider(
                        height: 10,
                      ),
                      Text(
                        comment.comment == null ? '' : comment.comment,
                        style: TextStyle(fontSize: 12.0, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  children: <Widget>[]..addAll(
                      List.generate(
                        comment.children.length,
                        (index) {
                          return CommentCard(
                            comment: comment.children[index],
                          );
                        },
                      ),
                    ),
                )
              : Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Image(
                            image: AdvancedNetworkImage(
                              'https://imgur.com/user/' + comment.author + '/avatar?maxwidth=290',
                              useDiskCache: true,
                              scale: 5,
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetails(username: comment.author),
                                ),
                              );
                            },
                            child: Text(
                              getName(comment.author) ?? '',
                              style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '        ',
                            style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        comment.comment == null ? '' : comment.comment,
                        style: TextStyle(fontSize: 12.0, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
