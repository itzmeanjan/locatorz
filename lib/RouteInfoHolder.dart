import 'dart:math';

class RouteInfoHolder {
  LocationDataChunk startLocation;
  double distanceCovered;
  List<LocationDataChunk> locationTrace;
  int duration;
  RouteInfoHolder(this.startLocation, this.distanceCovered, this.locationTrace,
      this.duration);

  void addNewLocationData(LocationDataChunk location) {
    locationTrace.add(location);
  }

  int getDuration() {
    return locationTrace[locationTrace.length - 1].time.millisecond -
        locationTrace[0].time.millisecond;
  }

  double calculateDistanceBetweenPoints(
      LocationDataChunk point1, LocationDataChunk point2) {
    try {
      double theta = point1.longitude - point2.longitude;
      double distance =
          sin(getRadian(point1.latitude)) * sin(getRadian(point2.latitude)) +
              cos(getRadian(point1.latitude)) *
                  cos(getRadian(point2.latitude)) *
                  cos(getRadian(theta));
      distance = getDegree(acos(distance)) * 60 * 1.1515;
      return distance * 1.609344;
    } catch (e) {
      return 0.0;
    }
  }

  double getDistance() {
    double tmp = 0.0;
    if (locationTrace.length == 1) return tmp;
    for (int i = 1; i < locationTrace.length; i++)
      tmp += calculateDistanceBetweenPoints(
          locationTrace[i - 1], locationTrace[i]);
    return tmp;
  }

  double getRadian(double data) {
    // degree to radian converter
    return (data * pi) / 180.0;
  }

  double getDegree(double data) {
    // radian to degree converter
    return (data * 180.0) / pi;
  }
}

class LocationDataChunk {
  double longitude;
  double latitude;
  DateTime time;
  double altitude;
  double accuracy;
  LocationDataChunk(
      this.longitude, this.latitude, this.time, this.altitude, this.accuracy);

  String getParsedTimeString() {
    if (this.time.isUtc) this.time = this.time.toLocal();
    Map<String, String> mapObj = {
      'day': '${this.time.day}',
      'month': '${this.time.month}',
      'year': '${this.time.year}',
      'hour': '${this.time.hour}',
      'minute': '${this.time.minute}',
      'second': '${this.time.second}',
    };
    if (this.time.day < 10) {
      mapObj['day'] = '0${this.time.day}';
    }
    if (this.time.month < 10) {
      mapObj['month'] = '0${this.time.month}';
    }
    if (this.time.hour < 10) {
      mapObj['hour'] = '0${this.time.hour}';
    }
    if (this.time.minute < 10) {
      mapObj['minute'] = '0${this.time.minute}';
    }
    if (this.time.second < 10) {
      mapObj['second'] = '0${this.time.second}';
    }
    return '${mapObj['day']}/${mapObj['month']}/${mapObj['year']} ${mapObj['hour']}:${mapObj['minute']}:${mapObj['second']}';
  }
}