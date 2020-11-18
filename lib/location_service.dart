import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart' as GeoLocator;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoder/geocoder.dart';

class LocationService {
  UserLocation _currentLocation;

  var location = Location();
  StreamController<UserLocation> _locationController =
      StreamController<UserLocation>();

  Stream<UserLocation> get locationStream => _locationController.stream;

  LocationService() {
    //Check Permission
    location.requestPermission().then((permissionStatus) {
      if (permissionStatus == PermissionStatus.granted) {
        //check gps on/off
        location.serviceEnabled().then((status) {
          if (!status) {
            // reqeust to on
            location.requestService().then((status) {
              if (status) {
                //listen location
                location.changeSettings(accuracy: LocationAccuracy.high);
                location.onLocationChanged.listen((locationData) async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  var lat = 0.0;
                  var long = 0.0;
                  lat = prefs.getDouble("lat") ?? -6.1476692;
                  long = prefs.getDouble("long") ?? 106.7746505;

                  if (locationData != null && lat != null && long != null) {
                    final coordinates = new Coordinates(
                        locationData.latitude, locationData.longitude);
                    var addresses = await Geocoder.local
                        .findAddressesFromCoordinates(coordinates);
                    var first = addresses.first;
                    var dis = calculateDistance(locationData.latitude,
                        locationData.longitude, lat, long);
                    double distanceInMeters =
                        GeoLocator.Geolocator.distanceBetween(
                            locationData.latitude,
                            locationData.longitude,
                            lat,
                            long);

                    _locationController.add(UserLocation(
                        latitude: locationData.latitude,
                        longitude: locationData.longitude,
                        latitudeOffice: lat ?? 0.0,
                        longitudeOffice: long ?? 0.0,
                        accuracy: locationData.accuracy,
                        distance2: distanceInMeters,
                        address: '${first.addressLine}',
                        distance: dis));
                  }
                });
              }
            });
          } else {
            location.changeSettings(accuracy: LocationAccuracy.high);
            location.onLocationChanged.listen((locationData) async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              var lat = 0.0;
              var long = 0.0;
              lat = prefs.getDouble("lat") ?? -6.1476692;
              long = prefs.getDouble("long") ?? 106.7746505;
              if (locationData != null && lat != null && long != null) {
                final coordinates = new Coordinates(
                    locationData.latitude, locationData.longitude);
                var addresses = await Geocoder.local
                    .findAddressesFromCoordinates(coordinates);
                var first = addresses.first;
                var dis = calculateDistance(
                    locationData.latitude, locationData.longitude, lat, long);
                double distanceInMeters = GeoLocator.Geolocator.distanceBetween(
                    locationData.latitude, locationData.longitude, lat, long);

                _locationController.add(UserLocation(
                    latitude: locationData.latitude,
                    longitude: locationData.longitude,
                    latitudeOffice: lat ?? 0.0,
                    longitudeOffice: long ?? 0.0,
                    accuracy: locationData.accuracy,
                    address: '${first.addressLine}',
                    distance2: distanceInMeters,
                    distance: dis));
              }
            });
          }
        });
      }
    });
  }
  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }

    return _currentLocation;
  }
}

class UserLocation {
  final double latitude;
  final double longitude;
  final double latitudeOffice;
  final double longitudeOffice;
  final double distance;
  final double distance2;
  final double accuracy;
  final String address;

  UserLocation(
      {this.latitude = 0.0,
      this.longitude = 0.0,
      this.latitudeOffice = 0.0,
      this.longitudeOffice = 0.0,
      this.distance = 0.0,
      this.distance2 = 0.0,
      this.accuracy = 0.0,
      this.address});
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  try {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  } catch (e) {
    return 0.0;
  }
}
