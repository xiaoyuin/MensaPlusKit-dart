import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'exceptions.dart';
import 'parser.dart';
import 'utils.dart';

class Canteen {
  String name = "";
  String fullName = "";
  String address = "";
  String city = "";
  String urlDetail = "";
  String urlOpenTimes = "";
  String urlAnsprechpartner = "";
  String urlLageplan = "";
  String urlLogo = "";
  String urlMeals = "";
  String urlMealsW1 = "";
  String urlMealsW2 = "";
  Map notes = new Map();

  String coordinates = "";

  // new properties since 1.4.0
  num mId = -1;

  Canteen.fromJson(Map json) {
    assert(json != null);

    this.name = json["name"];
    this.fullName = json["fullName"];
    this.address = json["address"];
    this.city = json["city"];
    this.urlDetail = json["urlDetail"];
    this.urlOpenTimes = json["urlOpenTimes"];
    this.urlAnsprechpartner = json["urlAnsprechpartner"];
    this.urlLageplan = json["urlLageplan"];
    this.urlLogo = json["urlLogo"];
    this.urlMeals = json["urlMeals"];
    this.urlMealsW1 = json["urlMealsW1"];
    this.urlMealsW2 = json["urlMealsW2"];
    this.notes = JSON.decode(json["notes"] ?? "{}");
    this.coordinates = json["coordinates"];

    this.mId = json["mId"] ?? -1;
  }

  /// Asynchronously get meals on some date
  ///
  /// return a list of meals or empty list
  Future<Menu> getMenu(DateTime dateTime) async {
    var urls = [this.urlMeals, this.urlMealsW1, this.urlMealsW2];
    var url = urls[TimeUtils.getWeekIndexRelativeToToday(dateTime)];

    if (url == null) {
      throw new NoURLException();
    }

    await initializeDateFormatting("de_DE");

    var response = await http.get(url);

    if (response.statusCode == 200) {
      var parser = new CanteenParser(this.name, response.bodyBytes, url,
          date: dateTime, mId: this.mId);
      return parser.parseMenu();
    } else {
      throw new SWDDServerException();
    }

    return null;
  }

  Future<Canteen> getDetail() async {
    var url = this.urlDetail;

    if (url == null) {
      throw new NoURLException();
    }

    var response = await http.get(url);

    if (response.statusCode == 200) {
      var parser =
          new CanteenParser(this.name, response.bodyBytes, url, mId: this.mId);

      this.urlLogo = parser.parseCanteenUrlLogo() ?? this.urlLogo;

      this.notes = parser.parseCanteenIntroduction(this.notes);
    } else {
      throw new SWDDServerException();
    }
    return this;
  }

  Future<Canteen> getOpeningTimes() async {
    var url = this.urlOpenTimes;

    if (url == null) {
      throw new NoURLException();
    }

    var response = await http.get(url);

    if (response.statusCode == 200) {
      var parser =
          new CanteenParser(this.name, response.bodyBytes, url, mId: this.mId);

      this.notes = parser.parseCanteenOpeningTimes(this.notes);
    } else {
      throw new SWDDServerException();
    }
    return this;
  }

  bool hasMenu() {
    return urlMeals != null && urlMeals.isNotEmpty;
  }

  @override
  bool operator ==(other) {
    if (other is Canteen) {
      return other.name == this.name;
    }
    return false;
  }

  @override
  int get hashCode => this.name.hashCode;
}

/// One day's menu of a canteen
///
/// contains a list of MenuItems, a date, and the canteen name it belongs to
class Menu {
  String canteenName;
  DateTime date;
  List<MenuItem> items = [];

  Menu(this.canteenName, this.date);
}

/// An item in a menu
///
/// contains an id, a text representing the main content of this item,
/// a date, and the canteen name it belongs to
class MenuItem {
  String id;
  String text;
  DateTime date;
  String canteenName;

  final DateTime createdAt = new DateTime.now();
}

/// One kind of MenuItem, representing a meal in the menu
///
/// apart from the fields inherited from MenuItem (i.e. an id, a text representing the main content of this item,
/// a date, and the canteen name it belongs to), contains also at least a meal name, a web url for meal details,
/// a price, and a list of image urls for food elements.
///
/// more fields (urlPicture, urlThumbnail, slot, notes) could be obtained from calling getMealDetail()
///
/// for a meal, the text equals to the meal name
class Meal extends MenuItem {
  /// the name of this meal
  String name = "";

  /// so far no use, is "food" normally for a meal
  String category = "";
  String slot = "";
  String urlDetail = "";
  String urlPicture = "";
  String urlThumbnail = "";
  Map notes = new Map();
  String price = "";

  // New property since > 0.9.6
  List urlImages = new List();

  Future<Meal> getMealDetail() async {
    var url = urlDetail;
    if (url == null || url.isEmpty) {
      return this;
    }

    var response = await http.get(url);

    if (response.statusCode == 200) {
      var parser = new MealParser(this.canteenName, response.bodyBytes, url);

      if (this.urlPicture == null) {
        this.urlPicture = parser.parseMealUrlPicture();
      }
      this.slot = parser.parseMealSlot();
      this.notes = parser.parseMealNotes();

      this.urlThumbnail ??= this.urlPicture;
      this.urlPicture ??= this.urlThumbnail;
    } else {
      throw new SWDDServerException();
    }

    return this;
  }
}

/// An info item
class Info extends MenuItem {}
