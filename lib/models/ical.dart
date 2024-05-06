import 'package:icalendar_parser/icalendar_parser.dart';

class IcalParam {
  IcalParam(this.p);
  late Map<String, dynamic> p;

  String get uid => p['uid'] ?? '';
  String get summary => p['summary'] ?? '';
  String get description => p['description'] ?? '';
  String get location => p['location'] ?? '';
  String get action => p['action'] ?? ''; // DISPLAY AUDIO EMAIL
  String get status => p['status'] ?? ''; // CANCELLED DRAFT
  String get sequence => p['sequence'] ?? ''; // 修正があるたびに増加
  String get repeat => p['repeat'] ?? '';
  String get class1 => p['class'] ?? ''; // PUBLIC PRIVATE CONFIDENTIAL
  String get trigger => p['trigger'] ?? ''; // -P0DT15H0M0S
  String get calscale => p['calscale'] ?? ''; // GREGORIAN

  // -//ABC Corporation//NONSGML My Product//EN
  String get prodid => p['prodid'] ?? '';

  // FREQ=YEARLY;INTERVAL=1;BYDAY=MO;BYMONTH=10;BYSETPOS=2;WKST=SU
  String get rrule => p['rrule'] ?? '';

  String get categories => p['categories'] ?? ''; // ,
  String get geo => p['geo'] ?? ''; // latitude longitude
  String get exdate => p['exdate'] ?? ''; // ,
  String get attendee => p['attendee'] ?? ''; // MAILTO CN

  DateTime get dtstart => toDateTime(p['dtstart']);
  DateTime get dtend => toDateTime(p['dtend']);
  DateTime get due => toDateTime(p['due']);
  DateTime get created => toDateTime(p['created']);
  DateTime get completed => toDateTime(p['completed']);

  /// IN 20240423T001623Z
  /// OUT 2024-04-23 00:16:23
  DateTime toDateTime(IcsDateTime d) {
    String str = d.dt.substring(0, 4) +
        '-' +
        d.dt.substring(4, 6) +
        '-' +
        d.dt.substring(6, 8);
    if (d.dt.length >= 15) {
      str += ' ' +
          d.dt.substring(9, 11) +
          ':' +
          d.dt.substring(11, 13) +
          ':' +
          d.dt.substring(13, 15);
    }
    DateTime dt = DateTime.parse(str);
    return dt;
  }
}
