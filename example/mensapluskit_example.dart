import 'package:mensapluskit/mensapluskit.dart';

main() async {

  var canteens = await MensaPlusKit.getCanteens();
  var todayMenu = await canteens.first.getMenu(new DateTime.now());
  todayMenu.items.forEach((item) {
    if (item is Meal) {
      print(item);
    } else {
      print(item);
    }
  });
}
