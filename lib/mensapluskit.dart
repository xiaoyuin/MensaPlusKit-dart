/// Support for doing something awesome.
///
/// More dartdocs go here.
library mensapluskit;

export 'src/models.dart';

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:mensapluskit/src/models.dart';

/// Entry point of MensaPlusKit
///
/// Calling MensaPlusKit.getCanteens() will asynchronously return a list of Canteen objects available
///
/// A Canteen object has methods for retrieving menus for some exact dates
class MensaPlusKit {

  static Future<List<Canteen>> getCanteens() async {
    var file = new File("lib/src/canteens.json");
    List canteens = JSON.decode(await file.readAsString());

    return canteens.map((c) => new Canteen.fromJson(c)).toList();
  }

}
