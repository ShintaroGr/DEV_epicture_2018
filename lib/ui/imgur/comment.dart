import 'package:dev_epicture_2018/data/comment.dart';
import 'package:flutter/material.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;

  CommentCard({this.comment});

  @override
  _CommentCardState createState() => _CommentCardState(comment: this.comment);
}

class _CommentCardState extends State<CommentCard> {
  Comment comment;

  _CommentCardState({this.comment});

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
                          Text(
                            comment.author == null ? '' : comment.author,
                            style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: <Widget>[
                              Icon(Icons.comment, size: 15, color: Colors.white,),
                              Text(' ' +comment.children.length.toString(), style: TextStyle(fontSize: 15, color: Colors.white,),),
                            ],
                          )
                        ],
                      ),
                      Divider(height: 10,),
                      Text(
                        comment.comment == null ? '' : comment.comment,
                        style: TextStyle(fontSize: 12.0, color: Colors.white),
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
              : Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          comment.author == null ? '' : comment.author,
                          style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      comment.comment == null ? '' : comment.comment,
                      style: TextStyle(fontSize: 12.0, color: Colors.white),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
