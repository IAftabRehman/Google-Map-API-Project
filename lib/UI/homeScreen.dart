import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(33.72993324248651, 73.03831168800549),
    zoom: 17,
  );

  List<Marker> _marker = [];
  List<Marker> _list =  [
    Marker(
      markerId: MarkerId('1'),
      position: LatLng(33.72993324248651, 73.03831168800549),
      infoWindow: InfoWindow(title: "Faisal Masque"),
    ),
  ];

  String coordinatesResult = '';
  String addressResult = '';

  Future<void> getAddressFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placeMark = await placemarkFromCoordinates(lat, lon);
      Placemark place = placeMark[0];
      setState(() {
        addressResult =
            '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
      });
      print(addressResult.toString());
    } catch (e) {
      setState(() {
        addressResult = 'Error: $e';
      });
    }
  }

  Future<Position?> getCurrentLocation() async {
    await Geolocator.requestPermission().then((value) {}).onError((
      error,
      stackTrace,
    ) {
      print("error" + error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _marker.addAll(_list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue, title: Text("Home Screen")),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text("Address is: ${addressResult.toString()}"),
                SizedBox(height: 5),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(20, 10),
                  ),
                  onPressed: () {
                    setState(() {
                      getAddressFromCoordinates(
                        27.830131305009175,
                        79.30190530946963,
                      );
                    });
                  },
                  child: Center(
                    child: Text(
                      "Click",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: GoogleMap(
              initialCameraPosition: initialCameraPosition,
              mapType: MapType.satellite,
              markers: Set<Marker>.of(_marker),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          getCurrentLocation().then((value) async {
            print(value!.latitude.toString() + " " + value.latitude.toString());
            _marker.add(
              Marker(
                markerId: MarkerId('2'),
                position: LatLng(value.latitude, value.altitude),
                infoWindow: InfoWindow(
                  title: "My Current Location"
                )
              )
            );
            CameraPosition cameraPosition = CameraPosition(target: LatLng(value.latitude, value.altitude), zoom: 14);

            final GoogleMapController controller = await _controller.future;

            controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {

            });
          });
        },
        child: Icon(Icons.location_on),
      ),
    );
  }
}
