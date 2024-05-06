import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import 'dart:convert';
import '/models/ical.dart';

final URI_COMING = 'assets/coming.ics';

final icalProvider = ChangeNotifierProvider((ref) => IcalNotifier(ref));

class IcalNotifier extends ChangeNotifier {
  IcalNotifier(ref) {
    readWeek();
  }

  ICalendar? ical;
  List<IcalParam> icalList = [];
  List<IcalParam> weekList = []; // this week

  void readWeek() async {
    try {
      if (ical != null) return;

      await readIcalList(URI_COMING);
      DateTime now = DateTime.now();
      DateTime monday = now.subtract(Duration(days: now.weekday - 1));

      for (IcalParam p in icalList) {
        int days = p.dtstart.difference(monday).inDays;
        if (0 <= days && days < 7) {
          weekList.add(p);
        }
      }
      notifyListeners();
    } on Exception catch (e) {
      print('-- ${e.toString()}');
    }
  }

  Future<void> readIcalList(String uri) async {
    try {
      if (ical != null) return;

      final res = await http.get(Uri.parse(uri));
      String body = utf8.decode(res.bodyBytes);
      this.ical = ICalendar.fromString(body);

      for (Map<String, dynamic> event in ical!.data) {
        if (event['summary'] == null || event['dtstart'] == null) continue;
        icalList.add(IcalParam(event));
      }
    } on Exception catch (e) {
      print('-- ${e.toString()}');
    }
  }
}
