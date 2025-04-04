// map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_tracker/Components/map_screen/unit_list.dart';
import 'package:project_tracker/unit_screen.dart';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';

void Function(Marker)? addMarker;
void Function()? emptyMarkers;
void Function(LatLng)? moveMap;

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _initialPosition = LatLng(37.7749, -122.4194);
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  bool showingUnitList = false;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage("assets/click.jpg"), context);
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();

    addMarker = (Marker marker) {
      setState(() {
        _markers.add(marker);
      });
    };

    emptyMarkers = () {
      if (!mounted) return;
      setState(() {
        _markers.clear();
      });
      print("Markers cleared");
    };

    moveMap = (LatLng position) {
      _mapController.move(position, 15);
    };
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }
    // Request location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _mapController.move(_initialPosition, 15);
    });
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialPosition,
              initialZoom: 11.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: _markers)
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end, children: [
              if (showingUnitList) ...[
                SizedBox(
                  height: 300,
                  child: Navigator(
                    observers: [routeObserver],
                    onGenerateRoute: (settings) {
                      switch (settings.name) {
                        case '/unit':
                          final args = settings.arguments;
                          Map<String, dynamic>? gpsUnit;
                          if (args is Map<String, dynamic>) {
                            gpsUnit = args['gpsUnit'];
                          }
                          return MaterialPageRoute(
                            builder: (context) =>
                                UnitScreen(gpsUnit: gpsUnit ?? {}),
                          );
                        default:
                          return MaterialPageRoute(
                            builder: (context) => UnitList(),
                          );
                      }
                    },
                  ),
                ),
              ],
              SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.fromLTRB(60, 20, 60, 30),
                child: Stack(
                  clipBehavior: Clip.none,
                    children: [
                  ClipPath(
                    clipper: NavBarClipper(),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(45), // radius here
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {
                              logout();
                            },
                            icon: Icon(Icons.my_location)),

                        IconButton(
                          icon: Icon(FontAwesomeIcons.circlePlus),
                          onPressed: () {
                            Navigator.pushNamed(context, '/add_unit');
                          },
                        ),
                      ],
                    ),
                  ),

                ]),
              ),
            ]),
          ),
          Positioned(
            right: MediaQuery.of(context).size.width / 2 - 35,
            bottom: 35,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(45), // radius here
              ),
              clipBehavior: Clip.none,
              child: IconButton(
                icon: Icon(FontAwesomeIcons.list, size: 30),
                onPressed: () {
                  setState(() {
                    showingUnitList = !showingUnitList;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavBarClipper extends CustomClipper<ui.Path> {
  @override
  ui.Path getClip(Size size) {
    ui.Path path = ui.Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Define the half-circle cutout at the top center
    Rect circleRect = Rect.fromCenter(
      center: Offset(size.width / 2, 0), // Centered at the top
      width: size.width / 3, // Adjust width of cutout
      height: size.width / 3, // Must be equal to make a perfect half-circle
    );

    // Subtract the half-circle from the rectangle
    path.addOval(circleRect);

    return ui.Path.combine(
        ui.PathOperation.difference, path, ui.Path()..addOval(circleRect));
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => false;
}
