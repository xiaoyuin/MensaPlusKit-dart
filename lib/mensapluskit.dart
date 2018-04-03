/// Support for doing something awesome.
///
/// More dartdocs go here.
library mensapluskit;

export 'src/models.dart';
export 'src/exceptions.dart';

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:mensapluskit/src/models.dart';
import 'package:mensapluskit/src/parser.dart';
import 'package:mensapluskit/src/utils.dart';
import 'package:mensapluskit/src/exceptions.dart';

/// Entry point of MensaPlusKit
///
/// Calling MensaPlusKit.getCanteens() will asynchronously return a list of Canteen objects available
///
/// A Canteen object has methods for retrieving menus for some exact dates
class MensaPlusKit {

  static List<Canteen> _canteens;

  static final String URL_TODAY = "http://www.studentenwerk-dresden.de/mensen/speiseplan/";
  static final String URL_TOMORROW = "http://www.studentenwerk-dresden.de/mensen/speiseplan/morgen.html";

  static Future<List<Canteen>> getCanteens() async {
    if (_canteens == null) {
      _canteens = await loadCanteensFromFile(new File("lib/src/canteens.json"));
    }
    return _canteens;
  }

  static Future<List<Canteen>> loadCanteensFromFile(File file) async {
    List canteens = JSON.decode(await file.readAsString());

    _canteens = canteens.map((c) => new Canteen.fromJson(c)).toList();
    return _canteens;
  }

  static List<Canteen> loadCanteensFromString(String json) {
    List canteens = JSON.decode(json);

    _canteens = canteens.map((c) => new Canteen.fromJson(c)).toList();
    return _canteens;
  }

  static Future<List<Menu>> getTodayMenus() async {
    var response = await http.get(URL_TODAY);

    if (response.statusCode == 200) {

      var parser = new MenuParser("", response.bodyBytes, URL_TODAY, TimeUtils.transformToDateOnly(new DateTime.now()));

      return parser.parseDayMenus();

    } else {
      throw new SWDDServerException();
    }
  }

  static Future<List<Menu>> getTomorrowMenus() async {
    var response = await http.get(URL_TOMORROW);

    if (response.statusCode == 200) {

      var parser = new MenuParser("", response.bodyBytes, URL_TOMORROW, TimeUtils.transformToDateOnly(new DateTime.now().add(new Duration(days: 1))));

      return parser.parseDayMenus();

    } else {
      throw new SWDDServerException();
    }

    return null;
  }

}
