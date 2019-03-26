import 'package:flutter/material.dart';
import 'MyLocation.dart';
import 'PlatformLevelLocationIssueHandler.dart';
import 'NewFeatureEntryMaker.dart';
import 'dart:async';

class FeatureCollectorHome extends StatefulWidget {
  final MyLocation location;
  final PlatformLevelLocationIssueHandler platformLevelLocationIssueHandler;

  FeatureCollectorHome(
      {Key key,
      @required this.location,
      @required this.platformLevelLocationIssueHandler})
      : super(key: key);

  @override
  _FeatureCollectorState createState() => _FeatureCollectorState();
}

class _FeatureCollectorState extends State<FeatureCollectorHome> {
  Future<Map<String, List<Map<String, String>>>> myFeatures;
  int featureCount = 0;

  @override
  void initState() {
    super.initState();
    myFeatures = getFeatures();
    myFeatures.then((Map<String, List<Map<String, String>>> val) {
      setState(() {
        featureCount = val.keys.toList().length;
      });
    });
  }

  Future<Map<String, List<Map<String, String>>>> getFeatures() async {
    return await widget.platformLevelLocationIssueHandler.methodChannel
        .invokeMethod("getFeatures")
        .then((dynamic val) {
      Map<String, List<Map<String, String>>> features = {};
      Map<String, dynamic>.from(val).forEach((String key, dynamic value) {
        List<Map<String, String>> tmpList = [];
        List<dynamic>.from(value).forEach((dynamic elem) {
          tmpList.add(Map<String, String>.from(elem));
        });
        features[key] = tmpList;
      });
      return features;
    });
  }

  List<Widget> layoutInflater(
      String featureId, List<Map<String, String>> element) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            'FeatureId :: ',
            style: TextStyle(
              letterSpacing: 3.0,
            ),
          ),
          Text(
            '$featureId',
            style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
          ),
        ],
      ),
      Container(
        margin: EdgeInsets.all(8.0),
        padding:
            EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.cyan, Colors.teal],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${element[0]["featureName"]}',
                    textAlign: TextAlign.left,
                  ),
                ),
                VerticalDivider(
                  width: 6,
                ),
                Expanded(
                  child: Text(
                    '${<String, String>{
                          "0": "Point",
                          "1": "Line",
                          "2": "Polygon"
                        }[element[0]["featureType"]] ?? "NA"}',
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.all(8.0),
        padding:
            EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.teal, Colors.greenAccent],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExpansionTile(
              trailing: Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
              title: Text(
                "Feature Description",
                style:
                    TextStyle(letterSpacing: 2.0, fontStyle: FontStyle.italic),
              ),
              initiallyExpanded: false,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.lightBlueAccent.shade100,
                    border: Border.all(
                        color: Colors.white,
                        style: BorderStyle.solid,
                        width: 0.15),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: '${element[0]["featureDescription"]}',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.all(8.0),
        padding:
            EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.teal, Colors.greenAccent],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExpansionTile(
              trailing: Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
              title: Text(
                "Coordinate(s)",
                style:
                    TextStyle(letterSpacing: 2.0, fontStyle: FontStyle.italic),
              ),
              initiallyExpanded: false,
              children: element.map((Map<String, String> elem) {
                return Container(
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.white12, Colors.blueGrey],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Longitude',
                          ),
                          Text(
                            '${elem["longitude"]}',
                          ),
                        ],
                      ),
                      Divider(
                        height: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Latitude',
                          ),
                          Text(
                            '${elem["latitude"]}',
                          ),
                        ],
                      ),
                      Divider(
                        height: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Altitude',
                          ),
                          Text(
                            '${elem["altitude"]} m',
                          ),
                        ],
                      ),
                      Divider(
                        height: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Time of Data Collection',
                          ),
                          Text(
                            '${elem["timeStamp"]}',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feature Collector',
          style: TextStyle(color: Colors.black87),
        ),
        elevation: 12,
        backgroundColor: Colors.cyanAccent,
        actions: <Widget>[
          Builder(
            builder: (BuildContext ctx) {
              return IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onPressed: featureCount != 0
                    ? () {
                        showDialog(
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Clear Records"),
                              elevation: 14.0,
                              content: Text(
                                "Do you want me to clear all Saved Features ?",
                              ),
                              actions: <Widget>[
                                RaisedButton(
                                  child: Text(
                                    "Yes",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  color: Colors.tealAccent,
                                ),
                                RaisedButton(
                                  child: Text(
                                    "No",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  color: Colors.tealAccent,
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                ),
                              ],
                            );
                          },
                          context: context,
                        ).then((dynamic value) async {
                          if (value == true) {
                            await widget
                                .platformLevelLocationIssueHandler.methodChannel
                                .invokeMethod("clearFeatures")
                                .then((dynamic val) {
                              if (val == 1) {
                                Scaffold.of(ctx).showSnackBar(SnackBar(
                                  content: Text(
                                    "Cleared all Features",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  duration: Duration(seconds: 1),
                                  backgroundColor: Colors.cyanAccent,
                                ));
                                setState(() {
                                  myFeatures = getFeatures();
                                  myFeatures.then(
                                      (Map<String, List<Map<String, String>>>
                                          val) {
                                    featureCount = val.keys.toList().length;
                                  });
                                });
                              }
                            });
                          }
                        });
                      }
                    : () {
                        Scaffold.of(ctx).showSnackBar(SnackBar(
                          content: Text(
                            "Nothing to Clear",
                            style: TextStyle(color: Colors.white),
                          ),
                          duration: Duration(seconds: 1),
                          backgroundColor: Colors.redAccent,
                        ));
                      },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, List<Map<String, String>>>>(
          future: myFeatures,
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, List<Map<String, String>>>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Center(
                  child: Container(
                    padding: EdgeInsets.all(6.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.sentiment_dissatisfied,
                          color: Colors.cyanAccent,
                          size: 150,
                        ),
                        Text("Nothing saved yet :/"),
                      ],
                    ),
                  ),
                );
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(
                    value: null,
                    backgroundColor: Colors.cyanAccent,
                  ),
                );
              case ConnectionState.done:
                if (snapshot.data == null || snapshot.data.isEmpty) {
                  return Center(
                      child: Container(
                    padding: EdgeInsets.all(6.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.sentiment_dissatisfied,
                          color: Colors.cyanAccent,
                          size: 150,
                        ),
                        Text("Nothing saved yet :/"),
                      ],
                    ),
                  ));
                } else {
                  List<String> featureIds = snapshot.data.keys.toList();
                  featureCount = featureIds.length;
                  return ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {},
                        child: Container(
                          margin: EdgeInsets.only(
                              left: 4.0, right: 4.0, top: 6.0, bottom: 6.0),
                          padding: EdgeInsets.only(
                              left: 14.0, right: 14.0, top: 10.0, bottom: 10.0),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.cyanAccent,
                                    Colors.tealAccent
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomLeft),
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: Colors.white,
                                width: 0.15,
                                style: BorderStyle.solid,
                              )),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: layoutInflater(featureIds[index],
                                snapshot.data[featureIds[index]]),
                          ),
                        ),
                      );
                    },
                    itemCount: featureIds.length,
                    padding: EdgeInsets.all(8.0),
                  );
                }
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (BuildContext context) => NewFeatureEntryMaker(
                location: widget.location,
                platformLevelLocationIssueHandler:
                    widget.platformLevelLocationIssueHandler),
          ))
              .then((dynamic value) {
            setState(() {
              myFeatures = getFeatures();
              myFeatures.then((Map<String, List<Map<String, String>>> val) {
                featureCount = val.keys.toList().length;
              });
            });
          });
        },
        backgroundColor: Colors.cyanAccent,
        highlightElevation: 4.0,
        tooltip: 'Add new Feature',
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
