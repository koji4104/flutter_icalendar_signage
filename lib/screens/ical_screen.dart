import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '/models/ical.dart';
import '/controllers/ical_controller.dart';

class IcalScreen extends ConsumerWidget {
  late WidgetRef ref;
  double listWidth = 400;
  Timer? _timer;
  int index = 0;
  late List<IcalParam> list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    this.ref = ref;
    ref.watch(icalProvider);
    if (_timer == null) _timer = Timer.periodic(Duration(seconds: 3), onTimer);
    double pad = 20;
    this.listWidth = (MediaQuery.of(context).size.width - pad * 2) / 2;
    this.list = ref.read(icalProvider).weekList;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            createList(),
            createDesc(),
          ],
        ),
      ),
    );
  }

  Widget createList() {
    if (list.length < 1) {
      return Container();
    }
    try {
      List<Widget> rows = [];
      list.asMap().forEach((int i, IcalParam p) {
        String s = '${DateFormat('MM/dd').format(p.dtstart)} ${p.summary}';
        rows.add(myTitle(s, i == index));
      });
      return myContainer(rows);
    } on Exception catch (e) {
      print('-- ${e.toString()}');
    }
    return Container();
  }

  Widget createDesc() {
    if (list.length < 1) {
      return Container();
    }
    try {
      List<Widget> rows = [];
      rows.add(myTitle(list[index].summary, true));
      rows.add(myDesc(list[index].description));
      return myContainer(rows);
    } on Exception catch (e) {
      print('-- ${e.toString()}');
    }
    return Container();
  }

  /// onTimer
  void onTimer(Timer timer) async {
    try {
      index++;
      if (list.length <= index) {
        index = 0;
      }
      ref.read(icalProvider).notifyListeners();
    } catch (e) {
      print('-- onTimer err=${e.toString()}');
    }
  }

  Widget myDesc(String text) {
    return _baseText(text, 100, null);
  }

  Widget myTitle(String text, bool selected) {
    Color? col = selected ? Colors.lightBlue : null;
    return _baseText(text, 1, col);
  }

  Widget _baseText(String text, int lines, Color? col) {
    return Text(
      text,
      maxLines: lines,
      textAlign: TextAlign.left,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 14.0, color: col),
    );
  }

  Widget myContainer(List<Widget> rows) {
    double marg = 6;
    return Container(
      width: listWidth - (marg * 2),
      margin: EdgeInsets.all(marg),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Color(0xFF707070), width: 1),
      ),
      child:
          Column(children: rows, crossAxisAlignment: CrossAxisAlignment.start),
    );
  }
}
