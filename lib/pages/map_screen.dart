import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pizza_store/pages/home/home_screen.dart';
import 'package:pizza_store/pages/home/main_page.dart';
import 'package:pizza_store/pages/landing_screen.dart';
import 'package:pizza_store/pages/main_screen.dart';
import 'package:pizza_store/providers/auth_provider.dart';
import 'package:pizza_store/providers/location_provider.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  static const String id = 'map-screen';

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng currentLocation = LatLng(37.421632, 122.084664);
  late GoogleMapController _mapController;
  bool _locating = false;
  bool _loggedIn = false;
  late User? user;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() {
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });

    if (user != null) {
      setState(() {
        _loggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);
    final _auth = Provider.of<AuthProvider>(context);
    setState(() {
      currentLocation = LatLng(locationData.latitude, locationData.longitude);
    });

    void onCreated(GoogleMapController controller) {
      setState(() {
        _mapController = controller;
      });
    }

    return Scaffold(
        body: SafeArea(
            child: Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: currentLocation,
            zoom: 14.4746,
          ),
          zoomControlsEnabled: false,
          minMaxZoomPreference: MinMaxZoomPreference(1.5, 20.8),
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          mapToolbarEnabled: true,
          onCameraMove: (CameraPosition position) {
            setState(() {
              _locating = true;
            });
            locationData.onCameraMove(position);
          },
          onMapCreated: onCreated,
          onCameraIdle: () {
            setState(() {
              _locating = false;
            });
            locationData.getMoveCamera();
          },
        ),
        Center(
            child: Container(
                height: 50,
                margin: EdgeInsets.only(bottom: 40),
                child: Icon(
                  Icons.location_pin,
                  size: 50,
                  color: Colors.red,
                ))),
        Positioned(
          bottom: 0.0,
          child: Container(
            height: 200,
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _locating
                  ? LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 20),
                child: TextButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.location_searching,
                      color: Theme.of(context).primaryColor,
                    ),
                    label: SmallText(
                        weight: FontWeight.bold,
                        color: Colors.black,
                        overFlow: TextOverflow.ellipsis,
                        size: 20,
                        text: _locating
                            ? "Locating..."
                            : locationData.selectedAddress == null
                                ? 'Locating...'
                                : locationData.selectedAddress.name!)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: SmallText(
                    color: Colors.black54,
                    text: _locating
                        ? ''
                        : locationData.selectedAddress == null
                            ? ''
                            : locationData.selectedAddress.street! +
                                ", " +
                                locationData.selectedAddress.subLocality! +
                                ", " +
                                locationData.selectedAddress.locality! +
                                ", " +
                                locationData.selectedAddress.country! +
                                ", " +
                                locationData.selectedAddress.postalCode!),
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: AbsorbPointer(
                    absorbing: _locating ? true : false,
                    child: ElevatedButton(
                        onPressed: () {
                          locationData.savePrefs();

                          if (_loggedIn == false) {
                            Navigator.pushNamed(context, LoginScreen.id);
                          } else {
                            setState(() {
                              _auth.latitude = locationData.latitude;
                              _auth.longitude = locationData.longitude;
                              _auth.address = locationData
                                      .selectedAddress.street! +
                                  ", " +
                                  locationData.selectedAddress.subLocality! +
                                  ", " +
                                  locationData.selectedAddress.locality! +
                                  ", " +
                                  locationData.selectedAddress.country! +
                                  ", " +
                                  locationData.selectedAddress.postalCode!;
                              _auth.location =
                                  locationData.selectedAddress.name!;
                            });
                            print("Location ${_auth.location}");
                            _auth.updateUser(
                              id: user!.uid,
                              number: user!.phoneNumber!,
                            );
                            Navigator.pushNamed(context, MainScreen.id);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            primary: _locating
                                ? Colors.grey
                                : Theme.of(context).primaryColor),
                        child: SmallText(
                          text: "Confirm location",
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            ]),
          ),
        )
      ],
    )));
  }
}
