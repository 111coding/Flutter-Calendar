// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class MyCalendar extends StatefulWidget {
//   final DateTime dateTime;

//   Function(String) onClick;
//   MyCalendar({
//     Key? key,
//     required this.dateTime,
//     required this.onClick,
//   }) : super(key: key);

//   @override
//   State createState() => _MyCalendarState();
// }

// class _MyCalendarState extends State<MyCalendar> {
//   @override
//   Widget build(BuildContext context) {
//     int year = widget.dateTime.year;
//     int month = widget.dateTime.month;

//     double defaultWidth = MediaQuery.of(context).size.width - 32;
//     double dayWidth = defaultWidth / 7 - 1;

//     int firstdayWeek = DateTime(year, month, 0).weekday + 1;
//     if (firstdayWeek == 7) {
//       firstdayWeek = 0;
//     }
//     firstdayWeek %= 7;
//     int lastday = DateTime(year, month + 1, 0).day;

//     List<Widget> days = [];

//     int totalI = 0;

//     for (int i = 0; i < firstdayWeek; i++) {
//       days.add(SizedBox(
//         width: dayWidth,
//         height: 40,
//       ));
//       totalI++;
//     }

//     for (int i = 0; i < lastday; i++) {
//       Color c = totalI % 7 == 0
//           ? const Color(0xFFF60000)
//           : totalI % 7 == 6
//               ? Colors.blue
//               : const Color(0xFF2B2B2B);

//       Color bgColor = const Color(0xFFFFFFFF);
//       if (i + 1 == selectDay) {
//         c = const Color(0xFFFFFFFF);
//         bgColor = const Color(0xFF2971FC);
//       }

//       days.add(GestureDetector(
//         onTap: () {
//           widget.selectDay = i + 1;
//           setState(() {});
//         },
//         child: Container(
//           alignment: Alignment.center,
//           width: dayWidth,
//           height: 44,
//           child: Container(
//             width: 29,
//             height: 29,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: bgColor,
//             ),
//             child: Text("${i + 1}",
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: c,
//                   // color: i + 1 > DateTime.now().day &&
//                   //         month == DateTime.now().month
//                   //     ? c.withOpacity(0.2)
//                   //     : c,
//                 )),
//           ),
//         ),
//       ));
//       totalI++;
//     }
//     return SizedBox(
//       width: defaultWidth,
//       child: Column(
//         children: [
//           Wrap(
//             children: days,
//           ),
//         ],
//       ),
//     );
//   }
// }
