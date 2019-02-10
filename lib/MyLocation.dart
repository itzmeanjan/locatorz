class MyLocation {
  MyLocation(
      this.longitude,
      this.latitude,
      this.time,
      this.altitude,
      this.bearing,
      this.speed,
      this.accuracy,
      this.verticalAccuracy,
      this.bearingAccuracy,
      this.speedAccuracy,
      this.provider,
      this.satelliteCount);
  double longitude;
  double latitude;
  DateTime time;
  double altitude;
  double bearing;
  double speed;
  double accuracy;
  double verticalAccuracy;
  double bearingAccuracy;
  double speedAccuracy;
  String provider;
  int satelliteCount;

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

  double getSpeedInKiloMetersPerHour() {
    return (this.speed * 3600) / 1000;
  }

  double getSpeedAccuracyInKiloMetersPerHour() {
    return (this.speedAccuracy * 3600) / 1000;
  }

  String bearingToDirectionName() {
    Map<int, String> tmpMap = {
      0: 'North',
      1: 'North North East',
      2: 'North East',
      3: 'East North East',
      4: 'East',
      5: 'East South East',
      6: 'South East',
      7: 'South South East',
      8: 'South',
      9: 'South South West',
      10: 'South West',
      11: 'West South West',
      12: 'West',
      13: 'West North West',
      14: 'North West',
      15: 'North North West'
    };
    if (this.bearing != null)
      return tmpMap[
          (((this.bearing + (360 / 16) / 2) % 360) / (360 / 16)).floor()];
    return "NA";
  }

  bool isBetterLocation(MyLocation location) {
    if ((this.longitude == null && this.latitude == null) &&
        (location.longitude != null && location.latitude != null)) {
      return true;
    }
    try {
      if (location.accuracy < this.accuracy) if (location.time
          .isAfter(this.time)) return true;
      return false;
    } on Exception {
      return false;
    }
  }
}
