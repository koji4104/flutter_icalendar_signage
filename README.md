# Flutter iCalendar

「〇月△日に何かをやる」といったケースはないでしょうか。
データ形式を考えていたのですが iCal 形式というものを見つけました。
iCal 形式にいったん変換するという二度手間になりますが、結構応用が期待できそうです。

# iCalendarとは

iCalendar とはカレンダーアプリ等で使用される標準フォーマットです。
ファイルの拡張子はics。iCal形式とも言われています。
[RFC5545](https://datatracker.ietf.org/doc/html/rfc5545) で規定されています。

https://eiga.com/movie/coming.ics

```
BEGIN:VCALENDAR
VERSION:2.0
PRODID:icalendar-ruby
CALSCALE:GREGORIAN
METHOD:PUBLISH
X-WR-CALNAME:公開スケジュール - 映画.com
X-WR-CALDESC:今週末以降、公開予定の映画作品・上映スケジュールのカレンダーです。
X-WR-TIMEZONE:Asia/Tokyo
X-WR-RELCALID:6b6bf0d0-ac7c-c4c1-aaab-bde1664336ba

BEGIN:VEVENT
DTSTAMP:20240501T042128Z
UID:eiga.com_100943
DTSTART:20240510T000000
DTEND:20240511T000000
DESCRIPTION:「コードギアス　反逆のルルーシュ」から始ま
 った人気アニメ「コードギアス」シリーズの一作で、20
 19年に公開された劇場アニメ「コードギアス　復活のル
 ルーシュ」から2年後の世界を舞台に、新たな主人公の
 物語を描く。
SUMMARY:コードギアス　奪還のロゼ　第1幕
END:VEVENT

BEGIN:VEVENT
DTSTAMP:20240501T042128Z
UID:eiga.com_100676
DTSTART:20240510T000000
DTEND:20240511T000000
DESCRIPTION:名作SF映画「猿の惑星」をリブートした「猿の
 惑星：創世記（ジェネシス）」「猿の惑星：新世紀（
 ライジング）」「猿の惑星：聖戦記（グレート・ウォ
 ー）」に続くシリーズ第4弾。
SUMMARY:猿の惑星　キングダム
END:VEVENT

BEGIN:VEVENT
DTSTAMP:20240501T042128Z
UID:eiga.com_99285
DTSTART:20240510T000000
DTEND:20240511T000000
DESCRIPTION:堤幸彦監督が、2019年2月に舞台で上演されたAI
 たちによる討論劇「SINGULA」を原案・原作に、15体のAIア
 ンドロイド同士が繰り広げる究極のディベートバトル
 ロイヤルを描いたSF映画。
SUMMARY:SINGULA
END:VEVENT
～
～
～
END:VCALENDAR
```

今回使ったパラメーターは３つです。
|パラメーター|説明|
|--|--|
|DTSTART|20240405T000000|
|SUMMARY|オーメン　ザ・ファースト|
|DESCRIPTION|「悪魔の子」ダミアンに翻弄される人々の恐怖...|

*NOTE*
改行はCRLF。一行75文字以内。長くなるときは改行＋行頭にスペース。

他にもパラメーターがいっぱいあります。[Wiki/ICalendar](https://en.wikipedia.org/wiki/ICalendar)

|パラメーター|例|
|--|--|
|DTSTART||
|DTEND||
|DURATION|P15DT5H0M20S|
|DUE|終了日|
|COMPLETED|実行済|
|EXDATE|複数可|
|RDATE|19970714T123000Z|
|RRULE|FREQ=YEARLY;INTERVAL=1;BYDAY=MO;BYMONTH=10;BYSETPOS=2;WKST=SU|
|REPEAT|4|
|LOCATION|Conference Room|
|ACTION|DISPLAY AUDIO EMAIL|
|STATUS|CANCELLED DRAFT|
|SEQUENCE|修正があるたびに増加|
|CLASS|PUBLIC PRIVATE CONFIDENTIAL|
|TRIGGER|-P0DT15H0M0S（15時間前）|
|PRODID|-//ABC Corporation//NONSGML My Product//EN|

# 試作アプリ

# 公開してみる

icsファイルLambdaで取得してS3に置きます。
S3に静的Webページを置きます。

# AWS S3 の設定

1. バケットを作り index.html を含む Web をアップロードします。
1. 「プロパティ」「静的ウェブサイトホスティング」を有効にします。
1. 「アクセス許可」「バケットポリシー」に以下を記述します。

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt155136344",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::test-xxx/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "xx.xx.xx.xx"
        }
      }
    }
  ]
}
```

# AWS lambda Node.js 20

定期的にicsファイルを取得するAWS Lambda

```
import fetch from "node-fetch";
import {PutObjectCommand, S3Client} from "@aws-sdk/client-s3";
const client = new S3Client({});

export const handler = async (event, context) => {
  var url = "https://eiga.com/movie/coming.ics";
  const response = await fetch(url);
  const body = await response.text();
    
  const command = new PutObjectCommand({
    Bucket: "test-xxx",
    Key: "assets/coming.ics",
    Body: body,
  });
  
  try {
    const response = await client.send(command);
    console.log(response);
  } catch (err) {
    console.error(err);
  }
};

```

## lambda レイヤーを追加

node_modules.zip をレイヤーに追加します。
https://qiita.com/koji4104/items/a336b986ea934a3068b8