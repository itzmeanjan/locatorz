import 'package:flutter/material.dart';
import 'MyLocation.dart';
import 'PlatformLevelLocationIssueHandler.dart';
import 'NewFeatureEntryMaker.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feature Collector',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.cyanAccent,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.sentiment_dissatisfied,
                color: Colors.cyanAccent,
                size: 180,
              ),
              Text("No feature found :/"),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => NewFeatureEntryMaker(
                location: widget.location,
                platformLevelLocationIssueHandler:
                    widget.platformLevelLocationIssueHandler),
          ));
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
