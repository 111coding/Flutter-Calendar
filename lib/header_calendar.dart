import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_area/my_calendar.dart';

class HeaderCalendarPage extends StatelessWidget {
  HeaderCalendarPage({Key? key}) : super(key: key);

  final HeaderCalendarPageController controller =
      Get.put(HeaderCalendarPageController());

  final SwiperController swiperController = SwiperController();

  Widget _touchContainer() => GestureDetector(
        onVerticalDragStart: (details) {
          controller.verticleDragStartDy = details.globalPosition.dy;
        },
        onVerticalDragUpdate: (details) {
          double movingY =
              controller.verticleDragStartDy - details.globalPosition.dy;
          double nextHeight = controller.isOpend.value
              ? controller.maxHeight - movingY
              : controller.minHeight - movingY;
          if (nextHeight > controller.minHeight &&
              nextHeight <= controller.maxHeight)
            controller.topHeight.value = nextHeight;
        },
        onVerticalDragEnd: (details) {
          controller.startAnimation();
        },
        child: Container(
          width: double.infinity,
          height: controller.touchHeight,
          alignment: Alignment.center,
          color: const Color(0xFFFFFFFF),
          child: Container(
            width: 30,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFFAAAAAA),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );

  Widget _calendarHeader() {
    int index = swiperController.index ?? 0;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12, left: 16, right: 16),
      child: SizedBox(
        height: 26,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                swiperController.previous();
              },
              child: Container(
                color: Colors.red,
                width: 24,
                height: 24,
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "${controller.currentDate.value.year}년 ${controller.currentDate.value.month}월",
                  style: const TextStyle(
                    color: Color(0xD9000000),
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                swiperController.next();
              },
              child: Container(
                color: Colors.red,
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calendar(context) {
    return Obx(
      () => Container(
        width: double.infinity,
        height: controller.topHeight.value,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              spreadRadius: 1,
              blurRadius: 16,
              color: Color(0xFFEEEEEE),
            )
          ],
        ),
        child: Column(
          children: [
            _calendarHeader(), // 54 = 16+12+26 TOP, BOTTOM, BODY
            controller.isOpend.value
                ? SizedBox(
                    height: controller.topHeight.value -
                        controller.minHeight +
                        controller.horizontalCalendarHeight,
                    width: double.infinity,
                    child: Swiper(
                      controller: swiperController,
                      onIndexChanged: (i) {
                        controller.currentDate.value = DateTime(
                            controller.baseDate.value.year,
                            controller.baseDate.value.month + i);
                        controller.heightChanged();
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Opacity(
                          opacity: 1,
                          child: SizedBox(
                            height: controller.topHeight.value -
                                controller.minHeight +
                                controller.horizontalCalendarHeight,
                            child: ListView(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              children: [
                                MyCalendar(
                                  dateTime: DateTime(
                                      controller.baseDate.value.year,
                                      controller.baseDate.value.month + index),
                                  onClick: (v) {},
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: 10,
                      itemWidth: double.infinity,
                      layout: SwiperLayout.DEFAULT,
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: controller.horizontalCalendarHeight,
                    color: Colors.blue,
                  ),

            // controller.isOpend.value
            //     ? Opacity(
            //         opacity: 1,
            //         child: SizedBox(
            //           height: controller.topHeight.value -
            //               controller.minHeight +
            //               controller.horizontalCalendarHeight,
            //           child: ListView(
            //             physics: const NeverScrollableScrollPhysics(),
            //             padding: EdgeInsets.zero,
            //             children: [
            //               MyCalendar(
            //                 dateTime: controller.calendarDate.value,
            //                 onClick: (v) {},
            //               )
            //             ],
            //           ),
            //         ),
            //       )
            //     : Container(
            //         width: double.infinity,
            //         height: controller.horizontalCalendarHeight,
            //         color: Colors.blue,
            //       ),
            const Spacer(),
            _touchContainer(),
          ],
        ),
      ),
    );
  }

  Color backgroundColor = const Color(0xFFF8F8F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
      ), // 상태바 패딩때문에 놔둠
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _calendar(context),
        ],
      ),
    );
  }
}

class HeaderCalendarPageController extends GetxController
    with SingleGetTickerProviderMixin {
  late AnimationController _animationController;

  final double horizontalCalendarHeight = 44;
  final double touchHeight = 20;

  DateTime today = DateTime.now();
  double verticleDragStartDy = 0;
  double maxHeight = 350.0;
  final double minHeight =
      118; // horizontalCalendarHeight 44 + 54(라벨) + 20(터치영역)
  RxDouble topHeight = 350.0.obs;
  RxBool isOpend = true.obs;
  DateTime selectedDate = DateTime.now();
  Rx<DateTime> baseDate = Rx(DateTime.now());
  Rx<DateTime> currentDate = Rx(DateTime.now());

  @override
  void onInit() {
    super.onInit();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _animationController.addListener(() {
      topHeight.value =
          _animationController.value * (maxHeight - minHeight) + minHeight;
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isOpend.value = true;
      } else if (status == AnimationStatus.dismissed) {
        isOpend.value = false;
      }
    });

    ever(currentDate, (DateTime v) {
      maxHeight = (v.weekOfMonth * 40) +
          minHeight -
          horizontalCalendarHeight +
          touchHeight;

      heightChanged();
    });
    currentDate.value = DateTime.now();
  }

  void startAnimation() {
    double basePosition = isOpend.value ? maxHeight * 0.7 : maxHeight / 2;
    if (topHeight.value > basePosition) {
      // 펼치기
      _animationController.forward(from: 1 - minHeight / maxHeight);
    } else {
      // 접기
      _animationController.reverse(
          from: (topHeight.value - minHeight) / maxHeight);
    }
  }

  void heightChanged() {
    _animationController.forward(from: topHeight.value / maxHeight);
  }
}

extension DateTimeExtension on DateTime {
  int get weekOfMonth {
    int endOfDay = DateTime(year, month + 1, 0).day;
    int weeksCount = (endOfDay / 7).floor();
    int modDays = endOfDay % 7;

    int weekday = DateTime(year, month, 1).weekday;
    if (weekday == 7) weekday = 0;
    weeksCount += ((weekday + modDays) / 7).ceil();

    return weeksCount;
  }
}
