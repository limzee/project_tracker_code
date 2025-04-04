import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong;

import 'helpers.dart';
import 'map_screen.dart';

class UnitScreen extends StatefulWidget {
  final Map<String, dynamic> gpsUnit;

  const UnitScreen({required this.gpsUnit, super.key});

  @override
  State<UnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<UnitScreen> {
  List<Map<String, dynamic>> gpsHistory = [];

  void listenToGpsHistory() {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('gpsUnits')
        .doc(widget.gpsUnit['id'])
        .collection('gpsData')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) emptyMarkers!();
      List<Map<String, dynamic>> newGpsHistory = snapshot.docs.map((doc) {
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
        gpsHistory = newGpsHistory;
      });
    });
  }

  String timestampToFormattedString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    listenToGpsHistory();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            scrolledUnderElevation: 0.0,
            backgroundColor: Colors.transparent,
            title: Text(
              "${widget.gpsUnit['name']}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          body: ListView.builder(
            itemCount: gpsHistory.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  moveMap!(latlong.LatLng(
                      double.parse(gpsHistory[index]['latitude'].toString()),
                      double.parse(gpsHistory[index]['longitude'].toString())));
                },
                title: Text(
                    timestampToFormattedString(gpsHistory[index]['timestamp'])),
                subtitle: FutureBuilder(
                  future: getStreetName(
                      double.parse(gpsHistory[index]['latitude']),
                      double.parse(gpsHistory[index]['longitude'])),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading...");
                    }
                    return Text(snapshot.data.toString());
                  },
                ),
                leading: Icon(Icons.history),
              );
            },
          )),
    );
  }
}
