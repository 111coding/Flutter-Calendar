import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_area/header_calendar.dart';

class Page1 extends StatelessWidget {
  const Page1({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
            onPressed: () {
              Get.to(() => HeaderCalendarPage(),
                  binding: BindingsBuilder.put(() =>
                      HeaderCalendarPageController(baseDate: DateTime.now())));
            },
            color: Colors.blue,
            icon: const Icon(Icons.golf_course)),
      ),
    );
  }
}
