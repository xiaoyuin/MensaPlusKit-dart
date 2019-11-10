import 'package:path/path.dart' as path;
import 'dart:collection';
import 'package:intl/intl.dart';

String urlDetail2urlPicture(String urlDetail, int mId, DateTime date) {
  var id = RegExp(r"details\-([0-9]+)\.html").firstMatch(
                              urlDetail)?.group(1);
  if (mId != null && mId != -1 && date != null && id != null) {
    var mensaPart = "m$mId";
    var datePart = DateFormat("yyyyMM").format(date);
    
    var urlPicture =
        "https://bilderspeiseplan.studentenwerk-dresden.de/$mensaPart/$datePart/$id.jpg";
    var urlThumbnail =
        "https://bilderspeiseplan.studentenwerk-dresden.de/$mensaPart/$datePart/thumbs/$id.jpg";
    return urlPicture;
  }
  return null;
}

List<String> extractFromTitle(String title) {
  var re = RegExp(r"\(([\d.,/ ]*(?:EUR)+[^()]*)\)");
  var match = re.firstMatch(title);
  if (match == null) {
    return [title.trim()];
  }
  return [title.substring(0, match.start).trim(), match.group(1).trim()];
}

class TimeUtils {
  static int getWeekIndexRelativeToToday(DateTime dateTime) {
    assert(dateTime != null);

    var now = new DateTime.now();
    var firstDayOfCurrentWeek =
        transformToDateOnly(now.add(new Duration(days: 1 - now.weekday)));

    var dayDifference =
        transformToDateOnly(dateTime).difference(firstDayOfCurrentWeek);

    return (dayDifference.inDays / 7).floor();
  }

  static DateTime transformToDateOnly(DateTime dateTime) =>
      new DateTime(dateTime.year, dateTime.month, dateTime.day);

  static bool isToday(DateTime dateTime) {
    var now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  static bool isTomorrow(DateTime dateTime) {
    var tom = DateTime.now().add(Duration(days: 1));
    return dateTime.year == tom.year &&
        dateTime.month == tom.month &&
        dateTime.day == tom.day;
  }
}

class PathUtils {
  static String getAbsUrl(String base_url, String rel_url) {
    assert(base_url != null);
    assert(rel_url != null);
    if (rel_url.startsWith("//")) {
      return "https:" + rel_url;
    }
    var stack = base_url.split("/");
    var parts = rel_url.split("/");

    stack.removeLast();

    for (var i = 0; i < parts.length; i++) {
      if (parts[i] == ".") {
        continue;
      }
      if (parts[i] == "..") {
        stack.removeLast();
      } else {
        stack.add(parts[i]);
      }
    }
    return stack.join("/");

//    if (path.isAbsolute(rel_url)) {
//      return rel_url;
//    } else {
//      return path.normalize(path.join(base_url, rel_url));
//    }
  }
}

main() {}
