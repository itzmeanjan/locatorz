import 'package:flutter/material.dart';
import 'PlatformLevelLocationIssueHandler.dart';
import 'CSVExporter.dart';

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
            TextEditingController myFileName = TextEditingController(text: '');
            FocusNode fileNameFocusNode = FocusNode();
            return PopupMenuButton(
              itemBuilder: (ctx) {
                return [
                  PopupMenuItem(
                    child: Text("Export to CSV"),
                    value: 0,
                  ),
                ];
              },
              tooltip: "Available Options",
              icon: Icon(Icons.more_vert),
              elevation: 12.0,
              padding: EdgeInsets.all(6.0),
              offset: Offset(10, 40),
              onSelected: (int selection) async {
                if (selection == 0) {
                  CSVExporter csvExporter = CSVExporter("/Locatorz", null, widget.myRoute, widget.platformLevelLocationIssueHandler);
                  await csvExporter.requestStorageAccessPermission().then((bool val) async {
                    if(!val){
                      Scaffold.of(ctx).showSnackBar(SnackBar(
                        content: Text(
                          "External Storage Access required for exporting Data to CSV",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ));
                    }
                    else{
                      await showDialog(
                          context: ctx,
                          barrierDismissible: false,
                          builder: (BuildContext myCtx) {
                            return Dialog(
                                elevation: 16.0,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: 20.0,
                                      bottom: 20.0,
                                      left: 10.0,
                                      right: 10.0),
                                  margin: EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(20.0),
                                      border: Border.all(
                                          color: Colors.white30,
                                          style: BorderStyle.solid,
                                          width: 0.25)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            'Enter File Name',
                                            style: TextStyle(
                                                color: Colors.tealAccent,
                                                fontStyle: FontStyle.italic,
                                                letterSpacing: 2.0),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.black,
                                        height: 10.0,
                                      ),
                                      TextField(
                                        textInputAction: TextInputAction.done,
                                        focusNode: fileNameFocusNode,
                                        controller: myFileName,
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(6.0),
                                            borderSide: BorderSide(
                                                color: Colors.tealAccent,
                                                width: 0.25,
                                                style: BorderStyle.solid),
                                          ),
                                          contentPadding: EdgeInsets.only(
                                              left: 8.0, right: 8.0),
                                          labelText: "File Name",
                                        ),
                                        onSubmitted: (String finalVal) {
                                          if (myFileName.text.isEmpty) {
                                            FocusScope.of(myCtx).requestFocus(
                                                fileNameFocusNode);
                                          } else
                                            fileNameFocusNode.unfocus();
                                        },
                                      ),
                                      Divider(
                                        color: Colors.black,
                                        height: 10.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          RaisedButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(''),
                                            color: Colors.grey,
                                            child: Text('Cancel'),
                                            elevation: 12.0,
                                            padding: EdgeInsets.all(6.0),
                                            textColor: Colors.white,
                                          ),
                                          RaisedButton(
                                            onPressed: () {
                                              if (myFileName.text.isEmpty) {
                                                FocusScope.of(myCtx)
                                                    .requestFocus(
                                                    fileNameFocusNode);
                                              } else {
                                                fileNameFocusNode.unfocus();
                                                myFileName.text.endsWith(".csv")
                                                    ? Navigator.of(ctx)
                                                    .pop(myFileName.text)
                                                    : Navigator.of(ctx).pop(
                                                    '${myFileName.text}.csv');
                                              }
                                            },
                                            color: Colors.tealAccent,
                                            child: Text('Okay'),
                                            elevation: 12.0,
                                            padding: EdgeInsets.all(6.0),
                                            textColor: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ));
                          }).then((dynamic myVal) async {
                        if (myVal != null && myVal.toString().isNotEmpty) {
                          csvExporter.fileName = "/${myVal.toString()}";
                          await csvExporter.exportToCSV().then((bool value){
                            value ? Scaffold.of(ctx).showSnackBar(SnackBar(
                              content: Text(
                                "Exported to CSV",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            )) : Scaffold.of(ctx).showSnackBar(SnackBar(
                              content: Text(
                                "Unsuccessful export :/",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ));
                          });
                        }
                      });
                    }
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
