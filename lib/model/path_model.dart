class DirectionsModel {
  DirectionsModel({
    this.routeNumber,
    this.districtId,
    this.districtName,
    this.status,
    this.objectId,
    this.periorty,
    this.distance,
    this.districtLocations,
    this.closestLocation,
    this.actualDistance,
  });

  DirectionsModel.fromJson(dynamic json) {
    actualDistance = json['actualDistance'];
    routeNumber = json['routeNumber'];
    districtId = json['districtId'];
    districtName = json['districtName'];
    status = json['status'];
    objectId = json['objectId'];
    periorty = json['periorty'];
    distance = json['distance'];
    if (json['districtLocations'] != null) {
      districtLocations = [];
      json['districtLocations'].forEach((v) {
        districtLocations?.add(DistrictLocations.fromJson(v));
      });
    }
    if (json['closestLocation'] != null) {
      closestLocation = [];
      json['closestLocation'].forEach((v) {
        closestLocation?.add(ClosestLocation.fromJson(v));
      });
    }
  }

  int? routeNumber;
  int? districtId;
  String? districtName;
  int? status;
  int? objectId;
  int? periorty;
  double? distance;
  double? actualDistance;
  List<DistrictLocations>? districtLocations;
  List<ClosestLocation>? closestLocation;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['routeNumber'] = routeNumber;
    map['districtId'] = districtId;
    map['districtName'] = districtName;
    map['status'] = status;
    map['objectId'] = objectId;
    map['periorty'] = periorty;
    map['distance'] = distance;
    if (districtLocations != null) {
      map['districtLocations'] =
          districtLocations?.map((v) => v.toJson()).toList();
    }
    if (closestLocation != null) {
      map['closestLocation'] = closestLocation?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ClosestLocation {
  ClosestLocation({
    this.latitude,
    this.longitude,
    this.districtId,
    this.type,
    this.locationId,
  });

  ClosestLocation.fromJson(dynamic json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    districtId = json['districtId'];
    locationId = json['locationId'];
    type = json['type'];
  }

  double? latitude;
  double? longitude;
  int? districtId;
  int? locationId;
  int? type;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['districtId'] = districtId;
    map['locationId'] = locationId;
    map['type'] = type;
    return map;
  }
}

class DistrictLocations {
  DistrictLocations({
    this.id,
    this.lat,
    this.long,
    this.description,
    this.routeNumber,
    this.districtId,
    this.objectId,
  });

  DistrictLocations.fromJson(dynamic json) {
    id = json['id'];
    lat = json['lat'];
    long = json['long'];
    description = json['description'];
    routeNumber = json['routeNumber'];
    districtId = json['districtId'];
    objectId = json['objectId'];
  }

  int? id;
  double? lat;
  double? long;
  String? description;
  int? routeNumber;
  int? districtId;
  int? objectId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['lat'] = lat;
    map['long'] = long;
    map['description'] = description;
    map['routeNumber'] = routeNumber;
    map['districtId'] = districtId;
    map['objectId'] = objectId;
    return map;
  }
}
