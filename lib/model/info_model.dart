class InfoModel {
  double? latitude;
  double? longitude;
  int? routeNumber;
  int? districtId;
  int? status;
  String? time;

  InfoModel(
      {this.time,
      this.latitude,
      this.longitude,
      this.routeNumber,
      this.districtId,
      this.status});

  toJson() {
    Map<String, dynamic> map = {};
    map["Lat"] = latitude;
    map["Long"] = longitude;
    map["RouteNumber"] = routeNumber;
    map["DistrictId"] = districtId;
    map["status"] = status;
    map["Date"] = time;
    return map;
  }
}
