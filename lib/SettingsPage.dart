import 'package:flutter/material.dart';
import 'PlatformLevelLocationIssueHandler.dart';

class SettingsPage extends StatefulWidget {
  final PlatformLevelLocationIssueHandler
      platformLevelLocationIssueHandler; // used for invoking platform level methods, using MethodChannel

  SettingsPage({Key key, @required this.platformLevelLocationIssueHandler})
      : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int useLocationDataFrom; // used for holding current selection

  @override
  void initState() {
    super.initState();
    widget.platformLevelLocationIssueHandler.methodChannel
        .invokeMethod("fetchLocationDataSourcePreference")
        .then((dynamic val) {
      if (val.toString().isNotEmpty) {
        setState(() {
          useLocationDataFrom = int.parse(val.toString(), radix: 10);
        });
      }
    });
  }

  @override
  void dispose() async {
    if (useLocationDataFrom != null)
      await widget.platformLevelLocationIssueHandler.methodChannel.invokeMethod(
          "storeLocationDataSourcePreference", <String, String>{
        "locationDataSourcePreference": useLocationDataFrom.toString()
      });
    // add more code here ...
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.black87),
        ),
        elevation: 8,
        backgroundColor: Colors.cyanAccent,
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Card(
            elevation: 16.0,
            margin:
                EdgeInsets.only(left: 3.0, right: 3.0, top: 12.0, bottom: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Divider(
                  color: Colors.white,
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      ":: Settings ::",
                      style: TextStyle(
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(8.0),
                  margin:
                      EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(
                        color: Colors.tealAccent.shade400,
                        width: 0.2,
                        style: BorderStyle.solid),
                    gradient: LinearGradient(
                        colors: [Colors.cyanAccent, Colors.tealAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Divider(
                        color: Colors.white,
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "Which one would you like me to use ?",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        ],
                      ),
                      Divider(
                        color: Colors.white30,
                        height: 20.0,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Radio<int>(
                            value: 1,
                            activeColor: Colors.blueAccent,
                            groupValue: useLocationDataFrom,
                            onChanged: (int val) => setState(() {
                                  useLocationDataFrom = val;
                                }),
                          ),
                          Text("android.location.Location based Location"),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Radio<int>(
                            value: 0,
                            activeColor: Colors.blueAccent,
                            groupValue: useLocationDataFrom,
                            onChanged: (int val) => setState(() {
                                  useLocationDataFrom = val;
                                }),
                          ),
                          Text("Google Mobile Services based Location"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
