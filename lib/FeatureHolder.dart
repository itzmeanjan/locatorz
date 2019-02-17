class FeatureHolder {
  String featureName;
  String featureType;
  String moreInfoOnFeature;
  List<FeatureLocation> featureLocation;

  FeatureHolder(this.featureName, this.featureType, this.moreInfoOnFeature,
      this.featureLocation);
}

class FeatureLocation {
  String longitude;
  String latitude;
  String altitude;
  String timeStamp;

  FeatureLocation(this.longitude, this.latitude, this.altitude, this.timeStamp);
}
