import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late GoogleMapController mapController;
  late String fromPointAddress;
  late String toPointAddress;
  Marker? fromPointMarker;
  Marker? toPointMarker;
  Set<Marker> get _markers {
    final markers = <Marker>{};
    if (fromPointMarker != null) markers.add(fromPointMarker!);
    if (toPointMarker != null) markers.add(toPointMarker!);

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(56.843, 69.645),
              zoom: 10.0,
            ),
            markers: _markers,
          ),
          Positioned(
            top: 30.0,
            right: 15.0,
            left: 15.0,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  TextField(
                    onSubmitted: (value) => searchAndNavigate,
                    onEditingComplete: () =>
                        searchAndNavigate(fromPointAddress, 'fromPoint'),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Откуда поедем',
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.only(left: 15.0, top: 15.0),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () =>
                            searchAndNavigate(fromPointAddress, 'fromPoint'),
                        iconSize: 30.0,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        fromPointAddress = val;
                      });
                    },
                  ),
                  const Divider(),
                  TextField(
                    onSubmitted: (value) => searchAndNavigate,
                    onEditingComplete: () =>
                        searchAndNavigate(toPointAddress, 'toPoint'),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Куда поедем',
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.only(left: 15.0, top: 15.0),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () =>
                            searchAndNavigate(toPointAddress, 'toPoint'),
                        iconSize: 30.0,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        toPointAddress = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          //
          // TODO BottomSheet
        ],
      ),
    );
  }

  void searchAndNavigate(String address, String pointName) async {
    final locations =
        (await GeocodingPlatform.instance.locationFromAddress(address))
            .map((e) => LatLng(e.latitude, e.longitude));

    print(locations.first);
    setState(() {
      if (pointName == 'fromPoint')
        fromPointMarker = _createMarker(locations.first, pointName);
      else if (pointName == 'toPoint')
        toPointMarker = _createMarker(locations.first, pointName);
    });

    _moveCamera();
  }

  void _moveCamera() {
    LatLng target;
    target = _markers.length == 2
        ? LatLng(
            (_markers.first.position.latitude +
                    _markers.last.position.latitude) /
                2,
            (_markers.first.position.longitude +
                    _markers.last.position.longitude) /
                2,
          )
        : _markers.first.position;
    print(target);

    var zoomLevel = 12.0;
    if (_markers.length == 2) {
      final radius = GeolocatorPlatform.instance.distanceBetween(
        _markers.first.position.latitude,
        _markers.first.position.longitude,
        _markers.last.position.latitude,
        _markers.last.position.longitude,
      );
      final scale = radius / 500;
      zoomLevel = (16 - log(scale * 1.2) / log(2));
    }
    print(zoomLevel);

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: target,
      zoom: zoomLevel,
    )));
  }

  void _onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }

  Marker _createMarker(LatLng position, String pointName) {
    return Marker(
      markerId: MarkerId(pointName),
      position: position,
      icon: BitmapDescriptor.defaultMarker,
    );
  }
}
