import 'package:html/parser.dart' as parser;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;

class Channel {
  String title;
  String link;
  String description;
  String language;
  DateTime pubDate;
  List<Item> items = List();
}

class Item {
  String title;
  String description;
  String guid;
  String link;
  String author;
  DateTime pubDate;
}

class Parser {
  static Channel parse(dynamic rssBytes) {
    var doc = parser.parse(rssBytes, encoding: "utf-8");
    var channel = doc.querySelector("channel");
    if (channel != null) {
      var channelObj = Channel();

      channelObj.title = channel.querySelector("title")?.text;
      channelObj.link = channel.querySelector("link")?.text;
      channelObj.description = channel.querySelector("description")?.text;
      channelObj.language = channel.querySelector("language")?.text;
      var pubDateString = channel.querySelector("pubDate")?.text;
      if (pubDateString != null) {
        channelObj.pubDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z", "en_US")
            .parse(pubDateString);
      }

      var items = channel.querySelectorAll("item");

      Item parseItems(Element item) {
        var itemObj = Item();
        itemObj.title = item.querySelector("title")?.text;
        itemObj.description = item.querySelector("description")?.text;
        itemObj.guid = item.querySelector("guid")?.text;
        itemObj.link = item.querySelector("link")?.text;
        itemObj.author = item.querySelector("author")?.text;
        var itemPubDateString = item.querySelector("pubDate")?.text;
        if (itemPubDateString != null) {
          itemObj.pubDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z", "en_US")
              .parse(itemPubDateString);
        }
        return itemObj;
      }

      channelObj.items = items.map(parseItems).toList();

      return channelObj;
    }

    return null;
  }
}

main(List<String> args) {
  http
      .get(
          "https://www.studentenwerk-dresden.de/feeds/speiseplan.rss?tag=morgen")
      .then((res) {
    var channel = Parser.parse(parser.parse(res.bodyBytes));
    print(channel.title);
    print(channel.description);
    print(channel.link);
    print(channel.language);
    print(channel.pubDate);
    print(channel.items);
  });
}
