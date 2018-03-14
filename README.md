# mensapluskit

A small dart library to access the latest menus of all student canteens in Dresden.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

    import 'package:mensapluskit/mensapluskit.dart';

    main() async {
     
      var canteens = await MensaPlusKit.getCanteens();
      
      var canteen = canteens.first
      
      // Get today's menu
      var todayMenu = await canteen.getMenu(new DateTime.now());
      todayMenu.items.forEach((item) {
        if (item is Meal) {
          // the item could be a meal..
        } else {
          // the item could be an information..
        }
      });
      
    }
    