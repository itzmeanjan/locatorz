import 'package:flutter/material.dart';
import 'MyLocation.dart';
import 'PlatformLevelLocationIssueHandler.dart';
import 'RouteInfoHolder.dart';
import 'package:flutter/services.dart';

class NewRouteStarterAndSaver extends StatefulWidget {
  final MyLocation location;
  final PlatformLevelLocationIssueHandler platformLevelLocationIssueHandler;

  NewRouteStarterAndSaver(
      {Key key,
      @required this.location,
      @required this.platformLevelLocationIssueHandler})
      : super(key: key);

  @override
  _NewRouteStarterAndSaverState createState() =>
      _NewRouteStarterAndSaverState();
}

class _NewRouteStarterAndSaverState extends State<NewRouteStarterAndSaver> {
  RouteInfoHolder _routeInfoHolder;
  List<Widget> _locationTraces;

  @override
  void initState() {
    super.initState();
    _locationTraces = [];
    _routeInfoHolder = RouteInfoHolder(
        LocationDataChunk(
            widget.location.longitude,
            widget.location.latitude,
            widget.location.time,
            widget.location.altitude,
            widget.location.accuracy),
        0.0,
        [
          LocationDataChunk(
              widget.location.longitude,
              widget.location.latitude,
              widget.location.time,
              widget.location.altitude,
              widget.location.accuracy)
        ],
        0);
    requestLocationUpdate();
  }

  @override
  void dispose() {
    stopLocationUpdate();
    super.dispose();
  }

  void extractLocationData(dynamic event, MyLocation currentLocator) {
    currentLocator.longitude = event['longitude'];
    currentLocator.latitude = event['latitude'];
    currentLocator.time =
        DateTime.fromMillisecondsSinceEpoch(event['time'], isUtc: true);
    currentLocator.altitude = event['altitude'];
    currentLocator.bearing = event['bearing'];
    currentLocator.speed = event['speed'];
    currentLocator.accuracy = event['accuracy'];
    currentLocator.verticalAccuracy = event['verticalAccuracy'];
    currentLocator.bearingAccuracy = event['bearingAccuracy'];
    currentLocator.speedAccuracy = event['speedAccuracy'];
    currentLocator.provider = event['provider'];
    currentLocator.satelliteCount = event['satelliteCount'];
    return;
  }

  void _onData(dynamic event) {
    if (event['provider'] == 'network') return;
    if (event['longitude'] ==
            _routeInfoHolder
                .locationTrace[_routeInfoHolder.locationTrace.length - 1]
                .longitude &&
        event['latitude'] ==
            _routeInfoHolder
                .locationTrace[_routeInfoHolder.locationTrace.length - 1]
                .latitude) return;
    setState(() {
      extractLocationData(event, widget.location);
      if (_routeInfoHolder.startLocation.longitude == null ||
          _routeInfoHolder.startLocation.latitude == null) {
        _routeInfoHolder.startLocation = LocationDataChunk(
            widget.location.longitude,
            widget.location.latitude,
            widget.location.time,
            widget.location.altitude,
            widget.location.accuracy);
        _routeInfoHolder.locationTrace = [_routeInfoHolder.startLocation];
        _routeInfoHolder.duration = 0; // as start location got changed
      } else {
        _routeInfoHolder.addNewLocationData(LocationDataChunk(
            widget.location.longitude,
            widget.location.latitude,
            widget.location.time,
            widget.location.altitude,
            widget.location.accuracy));
        _routeInfoHolder.duration = (_routeInfoHolder
                    .locationTrace[_routeInfoHolder.locationTrace.length - 1]
                    .time
                    .millisecondsSinceEpoch -
                _routeInfoHolder.startLocation.time.millisecondsSinceEpoch) ~/
            1000; // converting duration into seconds
      }
      _routeInfoHolder.distanceCovered = _routeInfoHolder.getDistance();
      _locationTraces = [];
      _routeInfoHolder.locationTrace.forEach((LocationDataChunk data) {
        _locationTraces.add(Container(
          margin:
              EdgeInsets.only(left: 10.0, right: 10.0, top: 6.0, bottom: 6.0),
          padding:
              EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
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
                  Text('${data.longitude}'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Latitude'),
                  Text('${data.latitude}'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('TimeStamp'),
                  Text('${data.getParsedTimeString()}'),
                ],
              ),
            ],
          ),
        ));
      });
    });
  }

  void _onError(dynamic error) {}

  void requestLocationUpdate() {
    widget.platformLevelLocationIssueHandler
        .requestLocationPermission()
        .then((bool result) {
      if (result) {
        widget.platformLevelLocationIssueHandler
            .requestToEnableLocation()
            .then((bool resp) async {
          if (resp) {
            widget.platformLevelLocationIssueHandler.eventChannel =
                EventChannel(
                    widget.platformLevelLocationIssueHandler.eventChannelName);
            await widget.platformLevelLocationIssueHandler.methodChannel
                .invokeMethod("startLocationUpdate", <String, String>{
              "id": "1"
            }) // 0 -> google play service based location update request
                // 1 -> android platform based location update, from android.hardware.gps
                .then((dynamic value) {
              if (value == 1) {
                widget.platformLevelLocationIssueHandler.eventChannel
                    .receiveBroadcastStream()
                    .listen(_onData, onError: _onError);
              } else {
                stopLocationUpdate();
                Navigator.of(context)
                    .pop(); // location access request denied, takes ba+ck to previous screen
              }
            });
          } else
            Navigator.pop(
                context); // takes back to previous screen, as location not enabled by user
        });
      } else
        Navigator.pop(
            context); // takes back to previous screen, as location access permission not granted
    });
  }

  void stopLocationUpdate() {
    widget.platformLevelLocationIssueHandler.methodChannel
        .invokeMethod("stopLocationUpdate")
        .then((dynamic value) {
      if (value == 1) {
        widget.platformLevelLocationIssueHandler.eventChannel = null;
      }
    });
  }

  Future<bool> _onWillPop() {
    return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Route Saver"),
                content: Text("Do you want to save this Route ?"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text("Yes")),
                  FlatButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text("No")),
                ],
              );
            }) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyanAccent,
          title: Text(
            'Route Tracker',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Colors.white,
                    width: 0.1,
                    style: BorderStyle.solid,
                  )),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Card(
                    color: Colors.black12,
                    margin: EdgeInsets.only(
                        top: 8.0, left: 6.0, right: 6.0, bottom: 12),
                    elevation: 12.0,
                    child: Container(
                      margin: EdgeInsets.all(4.0),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Colors.white70,
                            width: 0.5,
                            style: BorderStyle.solid,
                          )),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Start Point ::",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  letterSpacing: 3.0,
                                ),
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _routeInfoHolder.startLocation.longitude =
                                          widget.location.longitude;
                                      _routeInfoHolder.startLocation.latitude =
                                          widget.location.latitude;
                                      _routeInfoHolder.startLocation.time =
                                          widget.location.time;
                                      _routeInfoHolder.startLocation.altitude =
                                          widget.location.altitude;
                                      _routeInfoHolder.startLocation.accuracy =
                                          widget.location.accuracy;
                                      _routeInfoHolder.locationTrace = [
                                        _routeInfoHolder.startLocation
                                      ];
                                      _routeInfoHolder.distanceCovered = 0.0;
                                      _routeInfoHolder.duration =
                                          0; // as start location got changed
                                      _locationTraces = [];
                                      _routeInfoHolder.locationTrace
                                          .forEach((LocationDataChunk data) {
                                        _locationTraces.add(Container(
                                          margin: EdgeInsets.only(
                                              left: 10.0,
                                              right: 10.0,
                                              top: 6.0,
                                              bottom: 6.0),
                                          padding: EdgeInsets.only(
                                              left: 12.0,
                                              right: 12.0,
                                              top: 8.0,
                                              bottom: 8.0),
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 0.15,
                                                style: BorderStyle.solid,
                                              )),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text('Longitude'),
                                                  Text('${data.longitude}'),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text('Latitude'),
                                                  Text('${data.latitude}'),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text('TimeStamp'),
                                                  Text(
                                                      '${data.getParsedTimeString()}'),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ));
                                      });
                                    });
                                  }),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 0.5,
                                  style: BorderStyle.solid,
                                )),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Longitude",
                                    ),
                                    Text(
                                      _routeInfoHolder
                                                  .startLocation.longitude !=
                                              null
                                          ? _routeInfoHolder
                                              .startLocation.longitude
                                              .toString()
                                          : 'NA',
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Latitude",
                                    ),
                                    Text(
                                      _routeInfoHolder.startLocation.latitude !=
                                              null
                                          ? _routeInfoHolder
                                              .startLocation.latitude
                                              .toString()
                                          : 'NA',
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Altitude",
                                    ),
                                    Text(
                                      '${_routeInfoHolder.startLocation.altitude != null ? _routeInfoHolder.startLocation.altitude.toString() : 'NA'} m',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Start Time ::",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 0.5,
                                  style: BorderStyle.solid,
                                )),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      _routeInfoHolder.startLocation.time !=
                                              null
                                          ? _routeInfoHolder.startLocation
                                              .getParsedTimeString()
                                          : 'NA',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Current Point ::",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 0.5,
                                  style: BorderStyle.solid,
                                )),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Longitude",
                                    ),
                                    Text(
                                      widget.location.longitude != null
                                          ? widget.location.longitude.toString()
                                          : 'NA',
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Latitude",
                                    ),
                                    Text(
                                      widget.location.latitude != null
                                          ? widget.location.latitude.toString()
                                          : 'NA',
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Altitude",
                                    ),
                                    Text(
                                      '${widget.location.altitude != null ? widget.location.altitude.toString() : 'NA'} m',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Current Time ::",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 0.5,
                                  style: BorderStyle.solid,
                                )),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      widget.location.time != null
                                          ? widget.location
                                              .getParsedTimeString()
                                          : 'NA',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Distance Covered ::",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 0.5,
                                  style: BorderStyle.solid,
                                )),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      _routeInfoHolder.distanceCovered > 1
                                          ? '${_routeInfoHolder.distanceCovered} km'
                                          : '${_routeInfoHolder.distanceCovered * 1000} m',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Time Spent on Route ::",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 0.5,
                                  style: BorderStyle.solid,
                                )),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      _routeInfoHolder.getTimeSpentOnRoute(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "GPS Traces",
                        style: TextStyle(
                          color: Colors.tealAccent,
                          letterSpacing: 4.0,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.white12,
                    height: 20,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _locationTraces,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onWillPop: _onWillPop,
    );
  }
}
