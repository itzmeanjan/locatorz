import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class RouteToMap extends StatefulWidget {
  RouteToMap(this._points);
  final List<List<double>> _points;

  @override
  _RouteToMapState createState() => _RouteToMapState();
}

class _RouteToMapState extends State<RouteToMap> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  double getMax(List<double> data) {
    double max = -999;
    data.forEach((elem) => max = max < elem ? elem : max);
    return max;
  }

  double getMin(List<double> data) {
    double min = 999;
    data.forEach((elem) => min = min > elem ? elem : min);
    return min;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route To Map'),
        backgroundColor: Colors.cyanAccent,
        elevation: 16,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        color: Colors.black87,
        child: CustomPaint(
          painter: MyPainter(
              widget._points,
              getMax(widget._points.map((elem) => elem[0]).toList()) -
                  getMin(widget._points.map((elem) => elem[0]).toList()),
              getMax(widget._points.map((elem) => elem[1]).toList()) -
                  getMin(widget._points.map((elem) => elem[1]).toList())),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  MyPainter(this._points, this._width, this._height);

  List<List<double>> _points;
  double _width;
  double _height;

  @override
  void paint(Canvas canvas, Size size) {
    /*var paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .5
      ..color = Colors.cyanAccent
      ..strokeCap = StrokeCap.round;*/
    var center = size.center(Offset(0, 0));
    canvas.drawLine(
        size.centerLeft(Offset(0, 0)),
        size.centerRight(Offset(0, 0)),
        Paint()
          ..color = Colors.white
          ..strokeWidth = .2);
    canvas.drawLine(
        size.topCenter(Offset(0, 0)),
        size.bottomCenter(Offset(0, 0)),
        Paint()
          ..color = Colors.white
          ..strokeWidth = .2);
    var coordinates = _points
        .map((elem) => Offset(
              center.dx + elem[0] * (size.width / size.height),
              center.dy - elem[1] * (size.width / size.height),
            ))
        .toList();
    canvas.drawPoints(
        PointMode.points,
        coordinates,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.redAccent
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
