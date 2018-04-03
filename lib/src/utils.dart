import 'package:path/path.dart' as path;
import 'dart:collection';

class TimeUtils {
  static int getWeekIndexRelativeToToday(DateTime dateTime) {
    assert(dateTime != null);

    var now = new DateTime.now();
    var firstDayOfCurrentWeek =
        transformToDateOnly(now.add(new Duration(days: 1 - now.weekday)));

    var dayDifference = transformToDateOnly(dateTime).difference(firstDayOfCurrentWeek);

    return (dayDifference.inDays / 7).floor();
  }

  static DateTime transformToDateOnly(DateTime dateTime) =>
      new DateTime(dateTime.year, dateTime.month, dateTime.day);

}

class PathUtils {

  static String getAbsUrl(String base_url, String rel_url) {
    assert(base_url!=null);
    assert(rel_url!=null);
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


main() {

}