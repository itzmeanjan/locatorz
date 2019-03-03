import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'MyLocation.dart';
import 'PlatformLevelLocationIssueHandler.dart';
import 'FeatureCollector.dart';
import 'RouteTracker.dart';
import 'SettingsPage.dart';

class MyAppHome extends StatefulWidget {
  @override
  _MyAppHomeState createState() => _MyAppHomeState();
}

class _MyAppHomeState extends State<MyAppHome> {
  MyLocation currentLocator = MyLocation(
      null, null, null, null, null, null, null, null, null, null, null, null);
  final String eventChannelName =
      'com.example.itzmeanjan.traceme.locationUpdateEventChannel';
  final String methodChannelName =
      'com.example.itzmeanjan.traceme.locationUpdateMethodChannel';
  bool _areWeGettingLocationUpdates = false;
  PlatformLevelLocationIssueHandler platformLevelLocationIssueHandler;

  @override
  void initState() {
    super.initState();
    platformLevelLocationIssueHandler = PlatformLevelLocationIssueHandler(
        MethodChannel(methodChannelName),
        methodChannelName,
        null,
        eventChannelName);
  }

  @override
  void dispose() {
    // ends location listening service, while disposing app
    if (_areWeGettingLocationUpdates) {
      platformLevelLocationIssueHandler.methodChannel.invokeMethod(
          "stopLocationUpdate"); // calling platform level method, which is defined in MainActivity.kt
    }
    _areWeGettingLocationUpdates = false;
    platformLevelLocationIssueHandler = null;
    super.dispose();
  }

  void _onData(dynamic event) {
    setState(() {
      extractLocationData(event);
    });
  }

  void _onError(dynamic error) {
    setState(() {
      _areWeGettingLocationUpdates = false;
    });
  }

  void extractLocationData(dynamic event) {
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
  }

  void requestLocationUpdate() {
    platformLevelLocationIssueHandler
        .requestLocationPermission()
        .then((bool result) {
      if (result) {
        platformLevelLocationIssueHandler
            .requestToEnableLocation()
            .then((bool resp) async {
          if (resp) {
            platformLevelLocationIssueHandler.eventChannel =
                EventChannel(eventChannelName);
            await platformLevelLocationIssueHandler.methodChannel
                .invokeMethod("fetchLocationDataSourcePreference")
                .then((dynamic id) async {
              // trying to fetch user preferred way for retrieving Device Location. This preference is stored in SharedPreference .
              await platformLevelLocationIssueHandler.methodChannel
                  .invokeMethod("startLocationUpdate", <String, String>{
                "id": id.toString().isNotEmpty ? id.toString() : "1"
              }) // 0 -> google play service based location update request
                  // 1 -> android platform based location update, from android.hardware.gps
                  .then((dynamic value) {
                if (value == 1) {
                  platformLevelLocationIssueHandler.eventChannel
                      .receiveBroadcastStream()
                      .listen(_onData, onError: _onError);
                  setState(() {
                    _areWeGettingLocationUpdates = true;
                  });
                }
              });
            });
          }
        });
      }
    });
  }

  void stopLocationUpdate() {
    platformLevelLocationIssueHandler.methodChannel
        .invokeMethod("stopLocationUpdate")
        .then((dynamic value) {
      if (value == 1) {
        platformLevelLocationIssueHandler.eventChannel = null;
        setState(() {
          _areWeGettingLocationUpdates = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.cyanAccent,
              ),
              child: Container(
                  child: Align(
                alignment: AlignmentDirectional.center,
                child: Text(
                  "Locatorz",
                  textScaleFactor: 1.5,
                  style: TextStyle(
                    letterSpacing: 4.0,
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
              )),
            ),
            ListTile(
              title: Text(
                'Feature Collector',
                style: TextStyle(color: Colors.tealAccent),
              ),
              leading: Icon(Icons.add),
              onTap: () {
                if (_areWeGettingLocationUpdates) stopLocationUpdate();
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FeatureCollectorHome(
                    location: this.currentLocator,
                    platformLevelLocationIssueHandler:
                        platformLevelLocationIssueHandler,
                  );
                }));
              },
            ),
            ListTile(
              title: Text(
                'Route Tracker',
                style: TextStyle(color: Colors.tealAccent),
              ),
              leading: Icon(Icons.directions),
              onTap: () {
                if (_areWeGettingLocationUpdates) stopLocationUpdate();
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return RouteTrackerHome(
                    location: this.currentLocator,
                    platformLevelLocationIssueHandler:
                        platformLevelLocationIssueHandler,
                  );
                }));
              },
            ),
            ListTile(
              title: Text(
                'Settings',
                style: TextStyle(color: Colors.tealAccent),
              ),
              leading: Icon(Icons.settings),
              onTap: () {
                if (_areWeGettingLocationUpdates) stopLocationUpdate();
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SettingsPage(
                    platformLevelLocationIssueHandler:
                        platformLevelLocationIssueHandler,
                  );
                }));
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Locatorz',
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.cyanAccent,
      ),
      body: Center(
          child: Card(
        color: Colors.black,
        elevation: 8.0,
        margin: EdgeInsets.all(6.0),
        child: Container(
          margin: EdgeInsets.all(4.0),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
                width: 0.35, style: BorderStyle.solid, color: Colors.white70),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Location Info',
                    textScaleFactor: 1.0,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      letterSpacing: 4.0,
                      fontSize: 22,
                      color: Colors.cyanAccent,
                    ),
                  ),
                ],
              ),
              Divider(
                height: 20.0,
                color: Colors.white54,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Longitude',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  VerticalDivider(),
                  Text(currentLocator.longitude != null
                      ? '${currentLocator.longitude}'
                      : 'NA'),
                ],
              ),
              Divider(
                height: 10.0,
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Latitude',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  VerticalDivider(),
                  Text(currentLocator.latitude != null
                      ? '${currentLocator.latitude}'
                      : 'NA'),
                ],
              ),
              Divider(
                height: 10.0,
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Altitude',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  VerticalDivider(),
                  Text(currentLocator.altitude != null
                      ? '${currentLocator.altitude} m'
                      : 'NA'),
                ],
              ),
              Divider(
                height: 10.0,
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Bearing',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  VerticalDivider(),
                  Text(currentLocator.bearing != null
                      ? 'along ${currentLocator.bearingToDirectionName()}'
                      : 'NA')
                ],
              ),
              Divider(
                height: 10.0,
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Speed', style: TextStyle(fontStyle: FontStyle.italic)),
                  VerticalDivider(),
                  Text(currentLocator.speed != null
                      ? '${currentLocator.getSpeedInKiloMetersPerHour()} kmph'
                      : 'NA'),
                ],
              ),
              Divider(
                height: 10.0,
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Accuracy',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  VerticalDivider(),
                  Text(currentLocator.accuracy != null
                      ? '${currentLocator.accuracy} m'
                      : 'NA'),
                ],
              ),
              Divider(
                height: 10.0,
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Vertical Accuracy',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  VerticalDivider(),
                  Text(currentLocator.verticalAccuracy != null
                      ? '${currentLocator.verticalAccuracy} m'
                      : 'NA'),
                ],
              ),
              Divider(
                height: 10.0,
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Bearing Accuracy',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  VerticalDivider(),
                  Text(currentLocator.bearingAccuracy != null
                      ? '${currentLocator.bearingAccuracy}'
                      : 'NA'),
                ],
              ),
              Divider(
                height: 10.0,
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Speed Accuracy',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  VerticalDivider(),
                  Text(currentLocator.speedAccuracy != null
                      ? '${currentLocator.getSpeedAccuracyInKiloMetersPerHour()} kmph'
                      : 'NA'),
                ],
              ),
              Divider(
                height: 10.0,
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Provider',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  VerticalDivider(),
                  Text(currentLocator.provider != null
                      ? '${currentLocator.provider.toUpperCase()}'
                      : 'NA'),
                ],
              ),
              Divider(
                height: 10.0,
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Satellite Count',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  VerticalDivider(),
                  Text(currentLocator.satelliteCount != null
                      ? '${currentLocator.satelliteCount}'
                      : 'NA'),
                ],
              ),
              Divider(
                height: 10.0,
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('TimeStamp',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  VerticalDivider(),
                  Text(currentLocator.time != null
                      ? currentLocator.getParsedTimeString()
                      : 'NA'),
                ],
              ),
              Divider(
                height: 6.0,
                color: Colors.black,
              ),
            ],
          ),
        ),
      )),
      floatingActionButton: FloatingActionButton(
        highlightElevation: 4.0,
        onPressed: !_areWeGettingLocationUpdates
            ? requestLocationUpdate
            : stopLocationUpdate,
        tooltip: !_areWeGettingLocationUpdates
            ? 'Request Location Update'
            : 'Stop Location Update',
        child: !_areWeGettingLocationUpdates
            ? Icon(
                Icons.my_location,
                color: Colors.white,
              )
            : Icon(
                Icons.stop,
                color: Colors.white,
              ),
        backgroundColor:
            !_areWeGettingLocationUpdates ? Colors.cyanAccent : Colors.red,
      ),
    );
  }
}
