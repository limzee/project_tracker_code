import 'package:geocoding/geocoding.dart';

Future<String> getStreetName (double latitude, double longitude) async {
  String streetName = "";
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.first.street != null) {
      streetName = placemarks.first.street.toString();
    } else {
      streetName = "Street not found";
    }
  } catch (e) {
    streetName = "Failed to get street name";
  }
  if (streetName == null || streetName.isEmpty) {
    streetName = "Lat: ${latitude.toStringAsFixed(2)}, Long: ${longitude.toStringAsFixed(2)}";
  }
  return streetName;
}