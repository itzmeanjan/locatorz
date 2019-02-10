import 'package:flutter/material.dart';
import 'MyLocation.dart';
import 'PlatformLevelLocationIssueHandler.dart';
import 'NewRouteStarterAndSaver.dart';

class RouteTrackerHome extends StatefulWidget {
  final MyLocation location;
  final PlatformLevelLocationIssueHandler platformLevelLocationIssueHandler;

  RouteTrackerHome(
      {Key key,
      @required this.location,
      @required this.platformLevelLocationIssueHandler})
      : super(key: key);

  @override
  _RouteTrackerHome createState() => _RouteTrackerHome();
}

class _RouteTrackerHome extends State<RouteTrackerHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Route Tracker',
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
              Text("No route found :/"),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => NewRouteStarterAndSaver(
                location: widget.location,
                platformLevelLocationIssueHandler:
                    widget.platformLevelLocationIssueHandler),
          ));
        },
        backgroundColor: Colors.cyanAccent,
        highlightElevation: 4.0,
        tooltip: 'Start a new Route',
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
