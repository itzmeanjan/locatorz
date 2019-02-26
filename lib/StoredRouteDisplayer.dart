import 'package:flutter/material.dart';
import 'PlatformLevelLocationIssueHandler.dart';

class DisplayStoredRoute extends StatefulWidget {
  final String routeId;
  final List<Map<String, String>> myRoute;
  final String duration;
  final double distance;
  final String startTime;
  final String endTime;
  final PlatformLevelLocationIssueHandler platformLevelLocationIssueHandler;

  DisplayStoredRoute(
      {Key key,
      @required this.routeId,
      @required this.duration,
      @required this.distance,
      @required this.startTime,
      @required this.endTime,
      @required this.myRoute,
      @required this.platformLevelLocationIssueHandler})
      : super(key: key);

  @override
  _DisplayStoredRouteState createState() => _DisplayStoredRouteState();
}

class _DisplayStoredRouteState extends State<DisplayStoredRoute> {
  List<Widget> getStaticPortion() {
    return <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            'RouteId :: ',
            style: TextStyle(
              color: Colors.tealAccent,
              letterSpacing: 3.0,
            ),
          ),
          Text(
            '${widget.routeId}',
            style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
          ),
        ],
      ),
      Container(
        margin: EdgeInsets.all(7.0),
        padding:
            EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: Colors.tealAccent, style: BorderStyle.solid, width: 0.15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Started at',
                ),
                Text(
                  '${widget.startTime}',
                ),
              ],
            ),
            Divider(
              height: 6,
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Finished at',
                ),
                Text(
                  '${widget.endTime}',
                ),
              ],
            ),
            Divider(
              height: 6,
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Time Spent on Route',
                ),
                Text(
                  '${widget.duration}',
                ),
              ],
            ),
            Divider(
              height: 6,
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Length of Route',
                ),
                Text(
                  widget.distance > 1
                      ? '${widget.distance} km'
                      : '${widget.distance * 1000} m',
                ),
              ],
            ),
            Divider(
              height: 6,
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '# of Data Points over Route',
                ),
                Text(
                  '${widget.myRoute.length}',
                ),
              ],
            ),
          ],
        ),
      ),
      Divider(
        height: 6,
        color: Colors.black,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            ": GPS Traces :",
            style: TextStyle(
                color: Colors.tealAccent,
                letterSpacing: 4.0,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
      Divider(
        color: Colors.white30,
        height: 15,
      ),
    ];
  }

  List<Widget> getDynamicPortion(List<Map<String, String>> data) {
    return data.map((Map<String, String> elem) {
      return Container(
        margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 6.0, bottom: 6.0),
        padding:
            EdgeInsets.only(left: 18.0, right: 18.0, top: 10.0, bottom: 10.0),
        decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white,
              width: 0.15,
              style: BorderStyle.solid,
            )),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Longitude'),
                Text('${elem["longitude"]}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Latitude'),
                Text('${elem["latitude"]}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Altitude'),
                Text('${elem["altitude"]}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('TimeStamp'),
                Text('${elem["timeStamp"]}'),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> layoutInflater(List<Map<String, String>> data) {
    List<Widget> staticPortion = getStaticPortion();
    getDynamicPortion(data).forEach((Widget w) {
      staticPortion.add(w);
    });
    return staticPortion;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Route Info',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.cyanAccent,
        actions: <Widget>[
          StatefulBuilder(builder: (BuildContext ctx, setState) {
            return PopupMenuButton(
              itemBuilder: (ctx) {
                return [
                  PopupMenuItem(
                    child: Text("Export to GeoJSON"),
                    value: 0,
                  ),
                ];
              },
              tooltip: "Available Options",
              icon: Icon(Icons.more_vert),
              elevation: 12.0,
              padding: EdgeInsets.all(8.0),
              offset: Offset(20, 40),
              onSelected: (int selection) {
                if (selection == 0) {
                  widget.platformLevelLocationIssueHandler.methodChannel
                      .invokeMethod("requestStorageAccessPermission")
                      .then((dynamic val) {
                    if (val == 0)
                      Scaffold.of(ctx).showSnackBar(SnackBar(
                        content: Text(
                          "External Storage Access required for exporting Data to GeoJSON",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ));
                  });
                }
              },
            );
          }),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(10.0),
        children: <Widget>[
          Container(
            padding:
                EdgeInsets.only(top: 10.0, bottom: 10.0, left: 8.0, right: 8.0),
            margin: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                color: Colors.white30,
                width: 0.4,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: layoutInflater(widget.myRoute),
            ),
          ),
        ],
      ),
    );
  }
}
