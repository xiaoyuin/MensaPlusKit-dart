/// Support for doing something awesome.
///
/// More dartdocs go here.
library mensapluskit;

export 'src/models.dart';
export 'src/exceptions.dart';
export 'src/rss.dart';

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:mensapluskit/src/models.dart';
import 'package:mensapluskit/src/parser.dart';
import 'package:mensapluskit/src/utils.dart';
import 'package:mensapluskit/src/exceptions.dart';
import 'package:mensapluskit/src/rss.dart' as rss;

/// Entry point of MensaPlusKit
///
/// Calling MensaPlusKit.getCanteens() will asynchronously return a list of Canteen objects available
///
/// A Canteen object has methods for retrieving menus for some exact dates
class MensaPlusKit {
  static List<Canteen> _canteens;

  static final String URL_TODAY =
      "http://www.studentenwerk-dresden.de/mensen/speiseplan/";
  static final String URL_TOMORROW =
      "http://www.studentenwerk-dresden.de/mensen/speiseplan/morgen.html";
  static final String URL_RSS =
      "https://www.studentenwerk-dresden.de/feeds/speiseplan.rss";
  static final String URL_RSS_NEWS =
      "https://www.studentenwerk-dresden.de/feeds/news.rss";

  static Future<List<Canteen>> getCanteens() async {
    if (_canteens == null) {
      _canteens = await loadCanteensFromFile(new File("lib/src/canteens.json"));
    }
    return _canteens;
  }

  static Future<List<Canteen>> loadCanteensFromFile(File file) async {
    List canteens = jsonDecode(await file.readAsString());

    _canteens = canteens.map((c) => new Canteen.fromJson(c)).toList();
    return _canteens;
  }

  static List<Canteen> loadCanteensFromString(String json) {
    List canteens = jsonDecode(json);

    _canteens = canteens.map((c) => new Canteen.fromJson(c)).toList();
    return _canteens;
  }

  static Future<Map<String, int>> getTodayMenus() async {
    var response = await http.get(URL_RSS);

    if (response.statusCode == 200) {
      var channel = rss.Parser.parse(response.bodyBytes);
      var items = channel.items;
      var results = Map<String, int>();
      for (var item in items) {
        results.update(item.author, (count) => count + 1, ifAbsent: () => 1);
      }
      return results;
    } else {
      throw new SWDDServerException();
    }
  }

  static Future<Map<String, int>> getTomorrowMenus() async {
    var response = await http.get(URL_RSS + "?tag=morgen");

    if (response.statusCode == 200) {
      var channel = rss.Parser.parse(response.bodyBytes);
      var items = channel.items;
      var results = Map<String, int>();
      for (var item in items) {
        results.update(item.author, (count) => count + 1, ifAbsent: () => 1);
      }
      return results;
    } else {
      throw new SWDDServerException();
    }

  }

  static Future<rss.Channel> fetchNews() async {
    var response = await http.get(URL_RSS_NEWS);

    if (response.statusCode == 200) {
      var channel = rss.Parser.parse(response.bodyBytes);
      return channel;
    } else {
      throw new SWDDServerException();
    }
  }

}
