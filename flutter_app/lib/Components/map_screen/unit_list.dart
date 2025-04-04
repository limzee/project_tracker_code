import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../helpers.dart';
import '../../map_screen.dart';

class UnitList extends StatefulWidget {
  const UnitList({super.key});

  @override
  State<UnitList> createState() => _UnitListState();
}

class _UnitListState extends State<UnitList> with RouteAware {
  List<Map<String, dynamic>> gpsUnits = [];
  StreamSubscription<QuerySnapshot>? gpsUnitSubscription;

  void listenToGpsUnits() {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;
    gpsUnitSubscription?.cancel();
    gpsUnitSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('gpsUnits')
        .snapshots()
        .listen((snapshot) {
      emptyMarkers!();
      List<Map<String, dynamic>> newGpsUnits = snapshot.docs.map((doc) {
        final data = {"id": doc.id, ...doc.data()};
        Marker marker = Marker(
          width: 80.0,
          height: 80.0,
          point: latlong.LatLng(
              double.parse(data['latitude']), double.parse(data['longitude'])),
          child: const Icon(Icons.location_on, size: 40, color: Colors.black),
        );
        addMarker!(marker);
        return data;
      }).toList();
      setState(() {
        gpsUnits = newGpsUnits;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    listenToGpsUnits();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    gpsUnitSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    listenToGpsUnits();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(45), // radius here
      ),
      child: Column(
        children: [
          Text("Devices", style: Theme.of(context).textTheme.titleMedium),
          Divider(
            thickness: 0.4,
          ),
          Column(children: [
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: gpsUnits.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> data = gpsUnits[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/unit',
                      arguments: {'gpsUnit': data},
                    );
                  },
                  child: ListTile(
                    leading: Icon(Icons.location_on, size: 25),
                    title: Text(
                      data['name'],
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: FutureBuilder(
                      future: getStreetName(
                        double.parse(data['latitude']),
                        double.parse(data['longitude']),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Loading...");
                        }
                        return Text(
                          snapshot.data.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                );
              },
            ),
          ])
        ],
      ),
    );
  }
}
