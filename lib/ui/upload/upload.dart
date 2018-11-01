import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Upload extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _UploadState();
}

class _ImgurData {
  String title = '';
  String description = '';
  String image = '';
}

class _UploadState extends State<Upload> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final _data = new _ImgurData();
  bool _uploading = false;

  Future getGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    List<int> imageBytes = image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  Future getCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    List<int> imageBytes = image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  void submit() async {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _uploading = true;
      });
      http.Response response = await http.post(
        'https://api.imgur.com/3/image?client_id=4525911e004914a',
        headers: {'Authorization': 'Bearer ' + prefs.getString('access_token')},
        body: {"image": _data.image, "title": _data.title, "description": _data.description},
      );
      setState(() {
        _uploading = false;
      });
      if (json.decode(response.body)["success"]) {
        Fluttertoast.showToast(msg: "Image uploaded", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.TOP, timeInSecForIos: 1, bgcolor: "#43A047", textcolor: '#ffffff');
      } else {
        Fluttertoast.showToast(msg: "Failed", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.TOP, timeInSecForIos: 1, bgcolor: "#F44336", textcolor: '#ffffff');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black,
      body: _uploading
          ? new Center(
              child: new CircularProgressIndicator(),
            )
          : new Container(
              alignment: new FractionalOffset(0.5, 0.5),
              padding: new EdgeInsets.all(20.0),
              child: new Form(
                key: this._formKey,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new TextFormField(
                      decoration: new InputDecoration(
                        hintText: 'Title',
                        filled: true,
                        fillColor: Colors.white70,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(50.0),
                          ),
                        ),
                      ),
                      onSaved: (String value) {
                        this._data.title = value;
                      },
                    ),
                    new ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new RaisedButton(
                          color: Colors.white30,
                          onPressed: () async {
                            this._data.image = await getCamera();
                            print(_data.image);
                          },
                          child: new Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                        new RaisedButton(
                          color: Colors.white30,
                          onPressed: () async {
                            this._data.image = await getGallery();
                            print(_data.image);
                          },
                          child: new Icon(
                            Icons.photo,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    new Container(
                      child: new RaisedButton(
                        shape: StadiumBorder(),
                        child: new Text(
                          'Upload',
                          style: new TextStyle(color: Colors.white),
                        ),
                        onPressed: () => submit(),
                        color: Colors.white30,
                      ),
                      margin: new EdgeInsets.only(top: 20.0),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
