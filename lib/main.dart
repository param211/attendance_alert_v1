import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert' show Encoding, json;
import 'package:http/http.dart' as http;

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}

final Map<String, Item> _items = <String, Item>{};
Item _itemForMessage(Map<String, dynamic> message) {
  final dynamic data = message['data'] ?? message;
  final String itemId = data['id'];
  final Item item = _items.putIfAbsent(itemId, () => Item(itemId: itemId))
    .._matchteam = data['matchteam']
    .._score = data['score'];
  return item;
}

class Item {
  Item({this.itemId});
  final String itemId;

  StreamController<Item> _controller = StreamController<Item>.broadcast();
  Stream<Item> get onChanged => _controller.stream;

  String _matchteam;
  String get matchteam => _matchteam;
  set matchteam(String value) {
    _matchteam = value;
    _controller.add(this);
  }

  String _score;
  String get score => _score;
  set score(String value) {
    _score = value;
    _controller.add(this);
  }

  static final Map<String, Route<void>> routes = <String, Route<void>>{};
  Route<void> get route {
    final String routeName = '/detail/$itemId';
    return routes.putIfAbsent(
      routeName,
      () => MaterialPageRoute<void>(
        settings: RouteSettings(name: routeName),
        builder: (BuildContext context) => DetailPage(itemId),
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  DetailPage(this.itemId);
  final String itemId;
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Item _item;
  StreamSubscription<Item> _subscription;

  @override
  void initState() {
    super.initState();
    _item = _items[widget.itemId];
    _subscription = _item.onChanged.listen((Item item) {
      if (!mounted) {
        _subscription.cancel();
      } else {
        setState(() {
          _item = item;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Match ID ${_item.itemId}"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Card(
            child: Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Column(
                        children: <Widget>[
                          Text('Today match:',
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.8))),
                          Text(_item.matchteam,
                              style: Theme.of(context).textTheme.title)
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Column(
                        children: <Widget>[
                          Text('Score:',
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.8))),
                          Text(_item.score,
                              style: Theme.of(context).textTheme.title)
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Alert',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'IT-1 Attendance Alert (beta v2.0)'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
        // GRADIENT
        // flexibleSpace: Container(
        //   decoration: new BoxDecoration(
        //     gradient: new LinearGradient(
        //         colors: [
        //           const Color(0xFFf54e42),
        //           const Color(0xFFf78c57),
        //         ],
        //         begin: const FractionalOffset(0.0, 0.0),
        //         end: const FractionalOffset(1.0, 0.0),
        //         stops: [0.0, 1.0],
        //         tileMode: TileMode.clamp),
        //   ),
        // ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 0.0),
              child: Text("Select a subject",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              //Radio Buttons
              child: RadioButtonWidget(),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// DROPDOWN CODE---------------------------------------------------------------

enum SingingCharacter { itc15, itc16, itc17, itc18, itd03, itd09, itd10 }

/// This is the stateful widget that the main application instantiates.
class RadioButtonWidget extends StatefulWidget {
  RadioButtonWidget({Key key}) : super(key: key);

  @override
  _RadioButtonWidgetState createState() => _RadioButtonWidgetState();
}

/// This is the private State class that goes with RadioButtonWidget.
class _RadioButtonWidgetState extends State<RadioButtonWidget> {
  SingingCharacter _character = SingingCharacter.itc15;
  String actualValue = 'ITC15';

  bool shouldButtonEnabled = true;

  _disabledButton() {
    shouldButtonEnabled = false;
    Timer(Duration(seconds: 60), () => shouldButtonEnabled = true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile<SingingCharacter>(
          title: const Text('ITC15 | Multimedia & Appications'),
          value: SingingCharacter.itc15,
          groupValue: _character,
          onChanged: (SingingCharacter value) {
            setState(() {
              _character = value;
              actualValue = 'ITC15 | Multimedia & Appications';
            });
          },
        ),
        RadioListTile<SingingCharacter>(
          title: const Text('ITC16 | Theory of Computation'),
          value: SingingCharacter.itc16,
          groupValue: _character,
          onChanged: (SingingCharacter value) {
            setState(() {
              _character = value;
              actualValue = 'ITC16 | Theory of Computation';
            });
          },
        ),
        RadioListTile<SingingCharacter>(
          title: const Text('ITC17 | Design & Analysis of Algorithms'),
          value: SingingCharacter.itc17,
          groupValue: _character,
          onChanged: (SingingCharacter value) {
            setState(() {
              _character = value;
              actualValue = 'ITC17 | Design & Analysis of Algorithms';
            });
          },
        ),
        RadioListTile<SingingCharacter>(
          title: const Text('ITC18 | Linux Lab'),
          value: SingingCharacter.itc18,
          groupValue: _character,
          onChanged: (SingingCharacter value) {
            setState(() {
              _character = value;
              actualValue = 'ITC18 | Linux Lab';
            });
          },
        ),
        RadioListTile<SingingCharacter>(
          title: const Text('ITD03 | Information Security'),
          value: SingingCharacter.itd03,
          groupValue: _character,
          onChanged: (SingingCharacter value) {
            setState(() {
              _character = value;
              actualValue = 'ITD03 | Information Security';
            });
          },
        ),
        RadioListTile<SingingCharacter>(
          title: const Text('ITD09 | Advanced DBMS'),
          value: SingingCharacter.itd09,
          groupValue: _character,
          onChanged: (SingingCharacter value) {
            setState(() {
              _character = value;
              actualValue = 'ITD09 | Advanced DBMS';
            });
          },
        ),
        RadioListTile<SingingCharacter>(
          title: const Text('ITD10 | Advanced Computer Networks'),
          value: SingingCharacter.itd10,
          groupValue: _character,
          onChanged: (SingingCharacter value) {
            setState(() {
              _character = value;
              actualValue = 'ITD10 | Advanced Computer Networks';
            });
          },
        ),
        Padding(
            padding: EdgeInsets.all(14.0),
            child: Text(
                'Alert will be sent for ' +
                    '${_character.toString().split('.').last.toUpperCase()}' +
                    ' attendance.',
                style: TextStyle(fontSize: 14))),
        Padding(
          padding: const EdgeInsets.all(8.0),
          // Send Button
          child: FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: Colors.red)),
            onPressed: () {
              if (shouldButtonEnabled) {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          title: Center(child: Text('Success')),
                          content: Text(
                              'Attendance alert for $actualValue has been sent!'),
                        ));
                sendNotification(
                    "${_character.toString().split('.').last.toUpperCase()}",
                    "$actualValue".toUpperCase());
                _disabledButton();
              } else {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          title: Center(child: Text('Denied')),
                          content: Text(
                              'You sent an alert recently. Wait for 1 minute before sending again'),
                        ));
              }
            },
            color: Colors.red,
            textColor: Colors.white,
            child: Text("Send Alert".toUpperCase(),
                style: TextStyle(fontSize: 24)),
          ),
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: <TextSpan>[
            // TextSpan(
            //     text: "NOTE: ",
            //     style:
            //         TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            // TextSpan(
            //     text: "If you are on this screen then you won't receive any notifications.",
            //     style: TextStyle(color: Colors.black87)),
            TextSpan(
                text: "\n CLOSE THE APP or PUT IT IN BACKGROUND TO RECEIVE NOTIFICATIONS.",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ]),
        )
      ],
    );
  }
}
// END DROPDOWN CODE-----------------------------------------------------------

// DISABLE SEND ALERT BUTTON---------------------------------------------------

// END DISABLE-----------------------------------------------------------------

//SEND NOTIFICATION------------------------------------------------------------

Future<void> sendNotification(subject, message) async {
  final postUrl = 'https://salty-ravine-40549.herokuapp.com/api/v2/1/send-notif';


  final data = {
    "sub": subject,
    "message":message
  };

  final headers = {
    'content-type': 'application/json',
    };

  final response = await http.post(postUrl,
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers);

  if (response.statusCode == 200) {
// on success do
    print("true");
  } else {
// on failure do
    print("false");
  }
}

//END SEND NOTIFICATION--------------------------------------------------------

void main() {
  runApp(MyApp());
}
