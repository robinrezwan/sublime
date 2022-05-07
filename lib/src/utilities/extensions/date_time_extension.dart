import 'dart:core';

import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  DateTime today() {
    return DateTime(year, month, day, 0, 0, 0, 0, 0);
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameWeek(DateTime other) {
    return subtract(Duration(days: weekday))
        .isSameDate(other.subtract(Duration(days: other.weekday)));
  }

  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  String format(String prefix) {
    String dateTimeString = prefix;

    if (isSameDate(DateTime.now())) {
      dateTimeString += " today";
    } else if (isSameDate(DateTime.now().subtract(const Duration(days: 1)))) {
      dateTimeString += " yesterday";
    } else if (isSameWeek(DateTime.now())) {
      dateTimeString += " on " + DateFormat('EEEE').format(this);
    } else if (isSameYear(DateTime.now())) {
      dateTimeString += " on " + DateFormat('d MMMM').format(this);
    } else {
      dateTimeString += " on " + DateFormat('d MMMM y').format(this);
    }

    dateTimeString += " at " + DateFormat('h:mm a').format(this);

    return dateTimeString;
  }
}
