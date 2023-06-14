import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  double latitude = 37.421632;
  double longitude = 122.084664;
  bool permissionAllowed = false;
  var selectedAddress;
  bool loading = false;

  Future<Position> getCurrentPosition() async {
    bool _serviceEnabled;
    LocationPermission _permissionGranted;

    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      await Geolocator.openLocationSettings();
      if (!_serviceEnabled) {}
    }

    _permissionGranted = await Geolocator.checkPermission();
    if (_permissionGranted == LocationPermission.denied) {
      _permissionGranted = await Geolocator.requestPermission();
      if (_permissionGranted == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (_permissionGranted == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (position != null) {
      this.latitude = position.latitude;
      this.longitude = position.longitude;

      List<Placemark> _placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      this.selectedAddress = _placemarks.first;

      this.permissionAllowed = true;
      notifyListeners();
    } else {
      print("Permission not allowed");
    }
    return position;
  }

  void onCameraMove(CameraPosition position) async {
    this.latitude = position.target.latitude;
    this.longitude = position.target.longitude;
    notifyListeners();
  }

  Future<void> getMoveCamera() async {
    List<Placemark> _placemarks =
        await placemarkFromCoordinates(this.latitude, this.longitude);

    this.selectedAddress = _placemarks.first;
    notifyListeners();
  }

  Future<void> savePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var addressLine = this.selectedAddress.street! +
        ", " +
        this.selectedAddress.subLocality! +
        ", " +
        this.selectedAddress.locality! +
        ", " +
        this.selectedAddress.country! +
        ", " +
        this.selectedAddress.postalCode!;
    prefs.setDouble('latitude', this.latitude);
    prefs.setDouble('longitude', this.longitude);
    prefs.setString('address', addressLine);
    prefs.setString('location', this.selectedAddress.name!);
  }
}
