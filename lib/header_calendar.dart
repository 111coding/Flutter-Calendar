import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class HeaderCalendarPage extends GetView<HeaderCalendarPageController> {
  HeaderCalendarPage({Key? key}) : super(key: key);

  // final HeaderCalendarPageController controller =
  //     Get.put(HeaderCalendarPageController(baseDate: DateTime.now()));

  Widget _calendar(BuildContext context, DateTime yearMonth) {
    int year = yearMonth.year;
    int month = yearMonth.month;

    double defaultWidth = MediaQuery.of(context).size.width - 32;
    double dayWidth = defaultWidth / 7 - 1;

    ;
    int firstdayWeek = yearMonth.copyWith(day: 1).weekday;
    if (firstdayWeek == 7) {
      firstdayWeek = 0;
    }
    firstdayWeek %= 7;
    int lastday = yearMonth.copyWith(month: month + 1, day: 0).day;

    List<Widget> days = [];

    int totalI = 0;

    for (int i = 0; i < firstdayWeek; i++) {
      days.add(SizedBox(
        width: dayWidth,
        height: 40,
      ));
      totalI++;
    }

    for (int i = 0; i < lastday; i++) {
      Color c = totalI % 7 == 0
          ? const Color(0xFFF60000)
          : totalI % 7 == 6
              ? Colors.blue
              : const Color(0xFF2B2B2B);

      Color bgColor = const Color(0xFFFFFFFF);
      if (i + 1 == controller.selectedDate.day &&
          year == controller.selectedDate.year &&
          month == controller.selectedDate.month) {
        c = const Color(0xFFFFFFFF);
        bgColor = const Color(0xFF2971FC);
      }

      days.add(GestureDetector(
        onTap: () {
          if (year == yearMonth.year && month == yearMonth.month) {
            controller.selectedDate = yearMonth.copyWith(day: i + 1);
          }
        },
        child: Container(
          alignment: Alignment.center,
          width: dayWidth,
          height: 44,
          child: Container(
            width: 29,
            height: 29,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
            ),
            child: Text("${i + 1}",
                style: TextStyle(
                  fontSize: 13,
                  color: c,
                )),
          ),
        ),
      ));
      totalI++;
    }
    return SizedBox(
      width: defaultWidth,
      child: Column(
        children: [
          Wrap(
            children: days,
          ),
        ],
      ),
    );
  }

  Widget _touchContainer() => GestureDetector(
        onVerticalDragStart: (details) {
          controller.verticleDragStartDy = details.globalPosition.dy;
          if (controller.isOpend) {
            // ??????????????? ???????????? ????????????
            for (var ip
                in controller.itemPositionsListener.itemPositions.value) {
              if (ip.itemLeadingEdge <= 0.5 && ip.itemTrailingEdge >= 0.5) {
                DateTime d = controller.baseDate.copyWith(
                    day: controller.baseDate.day +
                        ip.index -
                        (controller.totalDay() / 2).ceil());
                if (d.monthGap(controller.currentMonth) != 0) {
                  // TODO HERE ?????? ?????? ????????? ????????? ????????? ??? ?????? ?????????!
                  int dayGap = controller.currentMonth
                      .copyWith(day: 1)
                      .dayGap(controller.baseDate);
                  int center = (controller.totalDay() / 2).ceil();
                  controller.itemScrollController
                      .jumpTo(index: center + dayGap, alignment: 0.3);
                } else {
                  // ?????????????????? ????????? ????????? ????????? ????????? ?????? ?????? ?????????!

                }
                return;
              }
            }
          } else {
            // ??????????????? ????????? ????????????
            int monthGap = controller.baseDate
                .copyWith(
                    month: controller.baseDate.month +
                        (controller.swiperIndex - 13))
                .monthGap(controller.currentMonth);
            if (monthGap != 0) {
              controller.swiperController
                  .move(controller.swiperIndex - monthGap, animation: false);
            }
          }
        },
        onVerticalDragUpdate: (details) {
          double movingY =
              controller.verticleDragStartDy - details.globalPosition.dy;
          double nextHeight = controller.isOpend
              ? controller.maxHeight - movingY
              : controller.minHeight - movingY;
          if (nextHeight > controller.minHeight &&
              nextHeight <= controller.maxHeight)
            controller.topHeight = nextHeight;
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
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12, left: 16, right: 16),
      child: SizedBox(
        height: 26,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                if (controller.swiperIndex > 0) {
                  controller.swiperController.previous();
                }
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
                  "${controller.currentMonth.year}??? ${controller.currentMonth.month}???",
                  style: const TextStyle(
                    color: Color(0xD9000000),
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (controller.swiperIndex < 24) {
                  controller.swiperController.next();
                }
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

  Widget _body(context) {
    return GetBuilder<HeaderCalendarPageController>(
      builder: (c) => Container(
        width: double.infinity,
        height: controller.topHeight,
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
            SizedBox(
              height: controller.topHeight -
                  controller.minHeight +
                  controller.horizontalCalendarHeight,
              child: Stack(
                children: [
                  Opacity(
                    opacity: (controller.topHeight - controller.minHeight) /
                        (controller.maxHeight - controller.minHeight),
                    child: SizedBox(
                      height: controller.topHeight -
                          controller.minHeight +
                          controller.horizontalCalendarHeight,
                      width: double.infinity,
                      child: Swiper(
                        controller: controller.swiperController,
                        loop: false,
                        onIndexChanged: (i) {
                          controller.swiperIndexChanged(i);
                        },
                        index: controller.swiperIndex,
                        itemCount: 25,
                        itemWidth: double.infinity,
                        layout: SwiperLayout.DEFAULT,
                        itemBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            height: controller.topHeight -
                                controller.minHeight +
                                controller.horizontalCalendarHeight,
                            child: ListView(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              children: [
                                _calendar(
                                  context,
                                  controller.baseDate.copyWith(
                                    month: controller.baseDate.month +
                                        (index - 13),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  IgnorePointer(
                    ignoring: controller.isOpend,
                    child: Opacity(
                      opacity: 1 -
                          (controller.topHeight - controller.minHeight) /
                              (controller.maxHeight - controller.minHeight),
                      child: SizedBox(
                        width: double.infinity,
                        height: controller.horizontalCalendarHeight,
                        child: NotificationListener(
                          onNotification: (Notification n) {
                            if (n is ScrollUpdateNotification) {
                              for (var ip in controller
                                  .itemPositionsListener.itemPositions.value) {
                                if (ip.itemLeadingEdge <= 0.5 &&
                                    ip.itemTrailingEdge >= 0.5) {
                                  DateTime d = controller.baseDate.copyWith(
                                      day: controller.baseDate.day +
                                          ip.index -
                                          (controller.totalDay() / 2).ceil());

                                  if (d.month !=
                                      controller.currentMonth.month) {
                                    controller.currentMonth = d;
                                  }
                                  return false;
                                }
                              }
                            }
                            return false;
                          },
                          child: ScrollablePositionedList.builder(
                            scrollDirection: Axis.horizontal,
                            initialScrollIndex:
                                (controller.totalDay() / 2).ceil(),
                            initialAlignment:
                                0.5 - (controller.hWidth / 2) / Get.width, //??????
                            itemScrollController:
                                controller.itemScrollController,
                            itemPositionsListener:
                                controller.itemPositionsListener,
                            itemCount: controller.totalDay(),
                            itemBuilder: (context, index) {
                              int center = (controller.totalDay() / 2).ceil();
                              DateTime baseDate = controller.baseDate;
                              DateTime date = baseDate.copyWith(
                                  day: baseDate.day - (center - index));

                              Color c = date.weekday == 7
                                  ? const Color(0xFFF60000)
                                  : date.weekday == 6
                                      ? Colors.blue
                                      : const Color(0xFF2B2B2B);
                              Color bgColor = const Color(0xFFFFFFFF);
                              if (date.equal(controller.selectedDate)) {
                                c = const Color(0xFFFFFFFF);
                                bgColor = const Color(0xFF2971FC);
                              }
                              return Container(
                                alignment: Alignment.center,
                                width: controller.hWidth,
                                color: Colors.transparent,
                                height: controller.horizontalCalendarHeight,
                                child: GestureDetector(
                                  onTap: () {
                                    controller.selectedDate = date;
                                  },
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 18,
                                        child: Text(
                                          "${date.dayName()}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0x61000000),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        width: 29,
                                        height: 29,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: bgColor,
                                        ),
                                        child: Text(
                                          "${date.day}",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: c,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
      ), // ????????? ??????????????? ??????
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _body(context),
        ],
      ),
    );
  }
}

class HeaderCalendarPageController extends GetxController
    with SingleGetTickerProviderMixin {
  HeaderCalendarPageController({required this.baseDate});

  // Cal Index +-??? ?????? ??????
  final DateTime baseDate;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  double hWidth = 44;

  int swiperIndex = 13; // ?????? 1?????? 12 m 12 => Total 25, center 13

  late AnimationController _animationController;
  final SwiperController swiperController = SwiperController();

  double verticleDragStartDy = 0;
  double maxHeight = 350.0;
  final double minHeight =
      126; // horizontalCalendarHeight 52 + 54(??????) + 20(????????????)
  double _topHeight = 350.0;
  set topHeight(double v) {
    _topHeight = v;
    update();
  }

  double get topHeight => _topHeight;

  final double horizontalCalendarHeight = 52;
  final double touchHeight = 20;

  bool isOpend = true;

  // ?????? ????????? ??????
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  set selectedDate(DateTime v) {
    DateTime originMonth = _selectedDate;
    _selectedDate = v;
    update();
  }

  // ?????? ????????? ???????????? ?????? ??????
  DateTime _currentMonth = DateTime.now();
  DateTime get currentMonth => _currentMonth;
  set currentMonth(DateTime v) {
    _currentMonth = v;
    maxHeight = (v.weekOfMonth * 40) +
        minHeight -
        horizontalCalendarHeight +
        touchHeight;

    if (isOpend) {
      // ??????????????? ????????? ??? update???
      heightChanged();
    } else {
      update();
    }
  }

  void swiperIndexChanged(int i) {
    if (swiperIndex == i) {
      return;
    }
    swiperIndex = i;

    if (isOpend) {
      DateTime targetMonth =
          baseDate.copyWith(month: baseDate.month + (i - 13));
      currentMonth = targetMonth;
    }
  }

  @override
  void onInit() {
    super.onInit();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _animationController.addListener(() {
      topHeight =
          _animationController.value * (maxHeight - minHeight) + minHeight;
      update();
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isOpend = true;
      } else if (status == AnimationStatus.dismissed) {
        isOpend = false;
      }
    });

    // ?????? ?????? ????????????
    currentMonth = currentMonth;
  }

  int totalDay() => 365 * 2 + baseDate.endOfMonth();

  void startAnimation() {
    double basePosition = isOpend ? maxHeight * 0.7 : maxHeight / 2;
    if (topHeight > basePosition) {
      // ?????????
      _animationController.forward(from: 1 - minHeight / maxHeight);
    } else {
      // ??????
      _animationController.reverse(from: (topHeight - minHeight) / maxHeight);
    }
  }

  void heightChanged() {
    _animationController.forward(from: topHeight / maxHeight);
  }
}

extension DateTimeExtension on DateTime {
  static const _dayName = ["???", "???", "???", "???", "???", "???", "???"];

  String dayName() => _dayName[weekday - 1];

  /// ?????? ??? ??? ???
  int get weekOfMonth {
    int endOfDay = DateTime(year, month + 1, 0).day;
    int weeksCount = (endOfDay / 7).floor();
    int modDays = endOfDay % 7;

    int weekday = DateTime(year, month, 1).weekday;
    if (weekday == 7) weekday = 0;
    weeksCount += ((weekday + modDays) / 7).ceil();

    return weeksCount;
  }

  /// ?????? ?????? ????????????
  int endOfMonth() => copyWith(month: month + 1, day: 0).day;

  bool equal(DateTime target) =>
      target.year == year && target.month == month && target.day == day
          ? true
          : false;

  int monthGap(DateTime t) => Jiffy([year, month, 1])
      .diff(Jiffy([t.year, t.month, 1]), Units.MONTH)
      .toInt(); // -20

  int dayGap(DateTime t) => Jiffy([year, month, day])
      .diff(Jiffy([t.year, t.month, day]), Units.DAY)
      .toInt(); // -20

  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}
