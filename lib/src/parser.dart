import 'models.dart';
import 'dart:convert';
import 'utils.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:html/dom.dart';

class Parser {

  final String canteenName;
  final dynamic website;
  final String baseUrl;
  final DateTime date;
  final int mId;
  
  Document _doc;
  
  Parser(this.canteenName, this.website, this.baseUrl, {this.date, this.mId}) {
    assert(this.canteenName!=null);
    assert(this.website!=null);
    assert(this.baseUrl!=null);
    _doc = parse(this.website, encoding: "utf8");
    assert(_doc!=null);
  }

  static DateTime parseDateFromString(String dateString) {
    var formatter = new DateFormat("'Angebote  am' EEEE, dddd. MMMM yyyy", "de_DE");
    return formatter.parse(dateString);
  }

}

class CanteenParser extends Parser {

  CanteenParser(canteenName, website, baseUrl, {DateTime date, int mId})
      : super(canteenName, website, baseUrl, date: date, mId: mId);

  Menu parseMenu() {
    var result = new Menu(this.canteenName, this.date);
    var uuid = new Uuid();

    var tables = _doc.querySelectorAll("#spalterechtsnebenmenue > table");
    for (var table in tables) {
      if (table.id == "aktionen") {
        // TODO: Aktionen table parsing
      } else {

        var dateString = table.querySelector("thead > tr > th:first-child")?.text;
        if (dateString != null) {
          var date = Parser.parseDateFromString(dateString);
          var rows = table.querySelectorAll("tbody > tr");
          for (var row in rows) {

            var hasMealsThisDate = row.getElementsByClassName("keinangebot").isEmpty;
            if (hasMealsThisDate) {

              var isInfoRatherThanMeal = row.getElementsByClassName("info").isNotEmpty;
              if (isInfoRatherThanMeal) {

                var info = new Info()
                  ..canteenName = this.canteenName
                  ..text = row.getElementsByClassName("info").first.text
                  ..date = date
                  ..id = uuid.v4();
                result.items.add(info);

              } else {

                var hasMealName = row.getElementsByClassName("text").isNotEmpty;
                if (hasMealName) {
                  var meal = new Meal()
                    ..name = row.getElementsByClassName("text").first.text
                    ..date = date
                    ..canteenName = this.canteenName
                    ..category = "food";
                  meal.text = meal.name;
                  var urlDetailTag = row.getElementsByClassName("text").first.getElementsByTagName("a");
                  if (urlDetailTag.isNotEmpty) {
                    var urlDetail = urlDetailTag.first.attributes['href'];
                    if (urlDetail != null && urlDetail.isNotEmpty) {
                      // Cut the trailing part
                      var truncateIndex = urlDetail.indexOf("?");
                      urlDetail = urlDetail.substring(0, truncateIndex == -1 ? urlDetail.length : truncateIndex);
                      meal.urlDetail = PathUtils.getAbsUrl(this.baseUrl, urlDetail);

                      // Fetch the meal id from the url
                      meal.id = new RegExp(r"details\-([0-9]+)\.html").firstMatch(urlDetail)?.group(1);
                    }
                  }
                  var priceTag = row.getElementsByClassName("preise");
                  if (priceTag.isNotEmpty) {
                    meal.price = priceTag.first.text;
                  }
                  meal.urlImages = row.querySelectorAll("td.stoffe > a > img").map((imgTag) {
                    var imgUrl = imgTag.attributes["src"];
                    if (imgUrl != null) {
                      imgUrl = PathUtils.getAbsUrl(this.baseUrl, imgUrl);
                    }
                    return imgUrl;
                  }).toList();
                  if (this.mId != null && this.mId != -1 && date != null && meal.id != null) {
                    var mensaPart = "m${this.mId}";
                    var datePart = new DateFormat("yyyyMM").format(date);
                    meal.urlPicture = "https://bilderspeiseplan.studentenwerk-dresden.de/$mensaPart/$datePart/${meal.id}.jpg";
                    meal.urlThumbnail = "https://bilderspeiseplan.studentenwerk-dresden.de/$mensaPart/$datePart/thumbs/${meal.id}.jpg";
                  }
                  result.items.add(meal);
                }
              }
            }
          }
        }
      }
    }

    return result;
  }

  String parseCanteenUrlLogo() {
    var url = _doc.querySelector("#mensadetailslinks > div > img")?.attributes["src"];
    if (url == null) {
      return null;
    }
    return PathUtils.getAbsUrl(this.baseUrl, url);
  }
  
  Map parseCanteenNotes(Map oldNotes) {
    
    var json = oldNotes;
    var childNodes = _doc.getElementById("mensadetailsrechts")?.nodes;
    if (childNodes != null) {
      var i = 0;
      while (i < childNodes.length) {
        var node = childNodes[i];
        if (node is Element) {
          if (node.localName == "h2") {
            var title = node.text;
            var content = "";
            var j = i + 1;
            while (true) {
              if (j >= childNodes.length) {
                break;
              }
              var nodej = childNodes[j];
              if (nodej is Element) {
                if (nodej.localName == "h2") {
                  break;
                }else {
                  content += nodej.text;
                  j += 1;
                  continue;
                }
              } else if (nodej is Text) {
                content += nodej.text;
                j += 1;
                continue;
              }
              break;
            }
            if (content.isNotEmpty) {
              json[title] = content;
            }
            i = j;
          }
        }
      }
    }

    return json;
  }
}

class MealParser extends Parser {

  MealParser(canteenName, website, baseUrl, {DateTime date, int mId})
      : super(canteenName, website, baseUrl, date: date, mId: mId);

  String parseMealUrlPicture() {
    var urlPicture = _doc.getElementById("essenfoto")?.attributes["href"];
    if (urlPicture != null && urlPicture.contains("?")) {
      urlPicture = urlPicture.substring(0, urlPicture.indexOf("?"));
    }
    return urlPicture;
  }

  Map parseMealNotes() {
    var json = {};
    var div = _doc.querySelector("#speiseplandetailsrechts");
    var h2s = div?.getElementsByTagName("h2");
    var uls = div?.getElementsByTagName("ul");
    if (h2s != null && uls != null) {
      for (var i = 0; i < h2s.length; i++) {
        var h2 = h2s[i];
        if (i < uls.length) {
          var ul = uls[i];
          var lis = ul.getElementsByTagName("li");
          json[h2.text] = lis.map((li) => li.text);
        }
      }
    }
    return json;
  }

  String parseMealSlot() {
    var slot = _doc.querySelector("#speiseplandetails > h1")?.text;

    if (slot != null) {
      if (slot.contains("Abendangebot")) {
        return "Abendangebot";
      } else {
//        var startIndex = slot.indexOf("Angebot");
//        if (slot.contains(this.canteenName)) {
//          startIndex = slot.indexOf(this.canteenName) + this.canteenName.length;
//        }
//        var endIndex = slot.indexOf("vom");
//        if (startIndex != -1 && endIndex != -1) {
//          return slot.substring(startIndex, endIndex).trim();
//        }
        var slotMatch = new RegExp("${this.canteenName}(.+)vom").firstMatch(slot)?.group(1);
        if (slotMatch != null) {
          slotMatch = slotMatch.trim();
          return slotMatch.isEmpty ? null : slotMatch;
        }
      }
    }

    return slot;
  }

}

main() {

  print(new DateFormat("yyyyMM").format(new DateTime.now()));

  print(new RegExp(r"details\-([0-9]+)\.html").firstMatch("https://www.studentenwerk-dresden.de/mensen/speiseplan/details-200248.html?pni=2")?.group(1));

  var canteenName = "Mensa Stimm-Gabel";
  var tag = "BioMensa U-Boot Angebot Essen 1 vom Dienstag, 27.2.18";
  var slotMatch = new RegExp("${canteenName}(.+)vom").firstMatch(tag)?.group(1);

  print(slotMatch.trim());

}