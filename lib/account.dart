import 'dart:async';
import 'dart:io';

import 'package:dev_epicture_2018/ui/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Account {
  static Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') != null;
  }

  static Future<Stream<String>> server() async {
    final StreamController<String> onCode = StreamController();
    HttpServer server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    server.listen((HttpRequest request) async {
      request.response
        ..statusCode = 200
        ..headers.set("Content-Type", ContentType.html.mimeType)
        ..write("<html><body bgcolor='#000000'></body></html>"
            "<script>"
            "if (location.hash.substring(1)) {console.log('http://localhost:8080/?' + location.hash.substring(1));window.location = 'http://localhost:8080/?' + location.hash.substring(1);}"
            "</script>");
      await request.response.close();
      if (request.uri.queryParameters.isNotEmpty) {
        await server.close(force: true);
        onCode.add(request.uri.queryParameters["access_token"]);
        onCode.add(request.uri.queryParameters["refresh_token"]);
        onCode.close();
        return onCode.stream;
      }
    });
    return onCode.stream;
  }

  static Widget buildLogoutButton(BuildContext context) {
    return MaterialButton(
      child: Row(
        children: <Widget>[
          Icon(
            Icons.exit_to_app,
            color: Colors.white,
          ),
          Text(
            " Logout",
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
      onPressed: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        while (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      },
    );
  }

  static Widget buildLoginButton(BuildContext context, {Color textColor = Colors.black, bool showIcon = false}) {
    return MaterialButton(
      child: Row(
        children: <Widget>[
          showIcon
              ? Icon(
                  Icons.account_circle,
                  color: textColor,
                )
              : Container(),
          Text(
            " Login",
            style: TextStyle(color: textColor),
          )
        ],
      ),
      onPressed: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebviewScaffold(
                  url: "https://api.imgur.com/oauth2/authorize?client_id=4525911e004914a&response_type=token",
                  appBar: AppBar(
                    title: const Text('Login'),
                  ),
                  withJavascript: true,
                  clearCache: true,
                  clearCookies: true,
                  userAgent: 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36',
                ),
          ),
        );
        Stream<String> onCode = await server();
        List<String> tokens = [];
        await onCode.forEach((value) {
          tokens.add(value);
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', tokens[0]);
        await prefs.setString('refresh_token', tokens[1]);
        while (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      },
    );
  }

  static Future<Map<String, String>> getHeader({bool important = false, @required BuildContext context}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('access_token') != null) {
      return {'Authorization': 'Bearer ' + prefs.getString('access_token')};
    } else {
      if (important) {
        await showDialog<Null>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('You must be logged in to do that !'),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                buildLoginButton(context),
              ],
            );
          },
        );
        if (prefs.getString('access_token') == null) {
          return {};
        }
        return {'Authorization': 'Bearer ' + prefs.getString('access_token')};
      } else {
        return {};
      }
    }
  }
}
