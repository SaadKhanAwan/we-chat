import 'package:flutter/material.dart';

class Mydate {
  static String getFormatedtime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  // for getting formateded message time (sent/read)with date
  static String getformatedmessagetime(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    final formatedtime = TimeOfDay.fromDateTime(sent).format(context);
    // this is condition for messaage sent time
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return formatedtime;
    }
    return now.year == sent.year
        ? '$formatedtime - ${sent.day} ${_getmonth(sent)}'
        : '$formatedtime - ${sent.day} ${_getmonth(sent)} ${sent.year}';
  }

  // get last message time(used in chat user card)
  static String getlastmessagetime(
      {required BuildContext context,
      required String time,
      bool showyear = false}) {
    final DateTime senttime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    // this is condition for messaage sent time
    if (now.day == senttime.day &&
        now.month == senttime.month &&
        now.year == senttime.year) {
      return TimeOfDay.fromDateTime(senttime).format(context);
    }
    return showyear
        ? '${senttime.day} ${_getmonth(senttime)} ${senttime.year}'
        : '${senttime.day} ${_getmonth(senttime)}';
  }

  // get formatated last active time of user in chat screen
  static String getLastActive(
      {required BuildContext context, required String lastActive}) {
    final int i = int.parse(lastActive);

    // // if time is not avalible then return below sattemant
    // if (i == -1) return 'Last sense not Avalialbe';

    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formatedTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return "Last Sense Today at $formatedTime";
    }
    if ((now.difference(time).inHours / 24).round() == 1) {
      return "Last Sense yesterday at $formatedTime";
    }
    String month = _getmonth(time);
    return "Last Sense on ${time.day} $month on $formatedTime ";
  }

  // this is for get month name
  static String _getmonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'NA';
  }
}
