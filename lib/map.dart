import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _mapController = MapController(initMapWithUserPosition: true);
  List<GeoPoint> geoPoints = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: OSMFlutter(
        controller: _mapController,
        mapIsLoading: const Center(
          child: CircularProgressIndicator(),
        ),
        trackMyPosition: true,
        initZoom: 12,
        minZoomLevel: 9,
        maxZoomLevel: 18,
        stepZoom: 1.0,
        roadConfiguration: const RoadOption(
          roadColor: Colors.blueGrey,
        ),
        userLocationMarker: UserLocationMaker(
          personMarker: const MarkerIcon(
            icon: Icon(
              Icons.pin_drop,
              color: Colors.blue,
              size: 60,
            ),
          ),
          directionArrowMarker: const MarkerIcon(
            icon: Icon(
              Icons.double_arrow,
              size: 60,
            ),
          ),
        ),
        onMapIsReady: (isReady) async {
          if (isReady) {
            // Add user's current location marker
            GeoPoint myLocation = await _mapController.myLocation();
            geoPoints.add(myLocation);
            print("MyLocation:${geoPoints}=====================");
            await _mapController.enableTracking(enableStopFollow: false);
          }
        },
        onLocationChanged: (GeoPoint location) async {
          // Add user's current location to the list of points

          geoPoints.add(location);
          print("Location:${location}=====================");
          if (geoPoints.length >= 2) {
            // Draw a line between the last two points
            GeoPoint lastPoint = geoPoints[geoPoints.length - 2];

            //check user change location
            if (lastPoint.latitude != location.latitude ||
                lastPoint.longitude != location.longitude) {
              RoadInfo roadInfo = await _mapController.drawRoad(
                lastPoint,
                location,
                roadType: RoadType.foot,
                intersectPoint: geoPoints,
                roadOption: const RoadOption(
                  roadWidth: 15,
                  roadColor: Colors.blue,
                  zoomInto: true,
                ),
              );
              
            }
          }
        },
      ),
    );
  }
}
