import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HeaderCalendarPage extends StatelessWidget {
  HeaderCalendarPage({Key? key}) : super(key: key);

  final HeaderCalendarPageController controller =
      Get.put(HeaderCalendarPageController());

  final SwiperController swiperController = SwiperController();

  Widget _calendar(BuildContext context, DateTime yearMonth) {
    int year = yearMonth.year;
    int month = yearMonth.month;

    double defaultWidth = MediaQuery.of(context).size.width - 32;
    double dayWidth = defaultWidth / 7 - 1;

    int firstdayWeek = DateTime(year, month, 0).weekday + 1;
    if (firstdayWeek == 7) {
      firstdayWeek = 0;
    }
    firstdayWeek %= 7;
    int lastday = DateTime(year, month + 1, 0).day;

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
          if (year == yearMonth.year && month == yearMonth.month)
            controller.selectedDate = yearMonth.copyWith(day: i + 1);
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
                  swiperController.previous();
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
                  "${controller.currentMonth.year}년 ${controller.currentMonth.month}월",
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
                  swiperController.next();
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
            controller.isOpend
                ? SizedBox(
                    height: controller.topHeight -
                        controller.minHeight +
                        controller.horizontalCalendarHeight,
                    width: double.infinity,
                    child: Swiper(
                      controller: swiperController,
                      loop: false,
                      onIndexChanged: (i) {
                        controller.swiperIndex = i;
                        controller.currentMonth = DateTime(
                            controller.baseDate.year,
                            controller.baseDate.month + (i - 13));
                        controller.heightChanged();
                      },
                      index: controller.swiperIndex,
                      itemCount: 25,
                      itemWidth: double.infinity,
                      layout: SwiperLayout.DEFAULT,
                      itemBuilder: (BuildContext context, int index) {
                        return Opacity(
                          opacity: 1,
                          child: SizedBox(
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
                                            (index - 13)))
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: controller.horizontalCalendarHeight,
                    color: Colors.blue,
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
      ), // 상태바 패딩때문에 놔둠
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
  int swiperIndex = 13; // 전후 1년씩 12 m 12 => Total 25, center 13

  late AnimationController _animationController;

  double verticleDragStartDy = 0;
  double maxHeight = 350.0;
  final double minHeight =
      118; // horizontalCalendarHeight 44 + 54(라벨) + 20(터치영역)
  double _topHeight = 350.0;
  set topHeight(double v) {
    _topHeight = v;
    update();
  }

  double get topHeight => _topHeight;

  final double horizontalCalendarHeight = 44;
  final double touchHeight = 20;

  bool isOpend = true;

  // 현재 선택된 날짜
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  set selectedDate(DateTime v) {
    _selectedDate = v;
    update();
  }

  // Swiper Index +-될 기준 날짜
  DateTime baseDate = DateTime.now();

  // 현재 달력에 표시되고 있는 날짜
  DateTime _currentMonth = DateTime.now();
  DateTime get currentMonth => _currentMonth;
  set currentMonth(DateTime v) {
    _currentMonth = v;
    maxHeight = (v.weekOfMonth * 40) +
        minHeight -
        horizontalCalendarHeight +
        touchHeight;
    heightChanged();
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
    // 최초 높이 알기위해
    currentMonth = currentMonth;
  }

  void startAnimation() {
    double basePosition = isOpend ? maxHeight * 0.7 : maxHeight / 2;
    if (topHeight > basePosition) {
      // 펼치기
      _animationController.forward(from: 1 - minHeight / maxHeight);
    } else {
      // 접기
      _animationController.reverse(from: (topHeight - minHeight) / maxHeight);
    }
  }

  void heightChanged() {
    _animationController.forward(from: topHeight / maxHeight);
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
