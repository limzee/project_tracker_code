import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AddUnitScreen3 extends StatefulWidget {
  final String userId;
  final String unitId;

  const AddUnitScreen3({
    required this.userId,
    required this.unitId,
    super.key
  });

  @override
  State<AddUnitScreen3> createState() => _AddUnitScreen3State();
}

class _AddUnitScreen3State extends State<AddUnitScreen3> {
  String unitName = "";

  void addDeviceToFirestore() async {
    print('addDeviceToFirestore called with unitName: $unitName');
    try {
      final data = {
        "name": unitName,
        "userId": widget.userId,
        "macAddress": widget.unitId,
      };
      final result = await FirebaseFunctions.instance.httpsCallable('initGpsUnit').call(
        data
      );
      print('Firebase Cloud Function returned: ${result.data}');
    } catch (e) {
      print('Error calling Firebase Cloud Function: $e');
    }
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Unit'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child:
            Container(
              padding: EdgeInsets.all(20),
              child: TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter the name of the unit',
              ),
              onChanged: (value) {
                setState(() {
                  unitName = value;
                });
              },
                        ),
            ),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 25),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: addDeviceToFirestore,
              child: Text('Add device', style: TextStyle(fontSize: 16))
          )
      ),
    );
  }
}
