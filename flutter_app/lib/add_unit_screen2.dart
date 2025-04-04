import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class AddUnitScreen2 extends StatefulWidget {
  const AddUnitScreen2({super.key});

  @override
  State<AddUnitScreen2> createState() => _AddUnitScreen2State();
}

class _AddUnitScreen2State extends State<AddUnitScreen2> {

  String _nfcResult = "Tap to scan NFC";
  bool scanComplete = false;
  String userId = "";
  String unitId = "";

  Future<void> _scanNFC() async {
    try {
      await FlutterNfcKit.finish();
      // Poll for an NFC tag. This will prompt the user to tap an NFC tag.
      NFCTag tag = await FlutterNfcKit.poll();
      if(tag.ndefAvailable ?? false) {
        var records = await FlutterNfcKit.readNDEFRecords();
        for (var record in records) {
          List<int> payload = record.payload!.toList();
          String payloadStatus = payload[0] == 0 ? "Success" : "Error";
          int languageCodeLength = payload[8] & 0x3F;
          List<int> textBytes = payload.sublist(2 + languageCodeLength);
          unitId = String.fromCharCodes(textBytes);
          startBluetooth(unitId);
        }
      }
      // You can access various properties like tag.id, tag.ndefMessage, etc.
      setState(() {
        _nfcResult = "NFC Tag ID: ${tag.id}";
      });

      // Optionally, finish the NFC session
      await FlutterNfcKit.finish();
    } catch (e) {
      setState(() {
        _nfcResult = "Error scanning NFC: $e";
      });
    }
  }

  void disconnectAllDevices() async {
    List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
    for (BluetoothDevice device in devices) {
      await device.disconnect();
      print("Disconnected: ${device.remoteId}");
    }
  }

  void startBluetooth(String macAdress) async {
    final Guid SERVICE_UUID = Guid("12345678-1234-5678-1234-56789abcdef0");
    final Guid CHAR_1_UUID = Guid("12345678-1234-5678-1234-56789abcdef1");
    final Guid CHAR_2_UUID = Guid("12345678-1234-5678-1234-56789abcdef2");

    disconnectAllDevices();
    print("Starting Bluetooth...");
    // listen to scan results
// Note: `onScanResults` clears the results between scans. You should use
//  `scanResults` if you want the current scan results *or* the results from the previous scan.
    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) async {
        if (results.isNotEmpty) {
          ScanResult r = results.last; // the most recently found device
          print(
              '${r.device.remoteId}: "${r.advertisementData.advName}" found!');
          if (r.device.remoteId.toString() == macAdress) {
            await r.device.connect();
            // stop scan
            await FlutterBluePlus.stopScan();
            for (BluetoothService service in await r.device
                .discoverServices()) {
              print('Service found: ${service.uuid}');
              for (BluetoothCharacteristic characteristic in service
                  .characteristics) {
                print('Characteristic found: ${characteristic.uuid}');
                if (characteristic.uuid == CHAR_1_UUID) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    print("User not found");
                    return;
                  }
                  userId = user.uid;
                  await characteristic.write(
                      userId.codeUnits, withoutResponse: false);
                      print("Wrote to characteristic 1");
                }
                if (characteristic.uuid == CHAR_2_UUID) {
                  await characteristic.write(
                      macAdress.codeUnits, withoutResponse: false);
                  print("Wrote to characteristic 1");
                }
              }
            }
            setState(() {
            scanComplete = true;
            });
          }
        }
      },
      onError: (e) => print(e),
    );

// cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(subscription);

// Wait for Bluetooth enabled & permission granted
// In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

// Start scanning w/ timeout
// Optional: use `stopScan()` as an alternative to timeout
    await FlutterBluePlus.startScan(
        withServices: [SERVICE_UUID], // match any of the specified services
        withNames: ["Tracker"], // *or* any of the specified names
        timeout: Duration(seconds: 30));

// wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
  }

  @override
  void initState() {
    super.initState();
    _scanNFC();
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
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              scanComplete ? Icon(Icons.check_circle, color: Colors.green, size: 100) :
              CircularProgressIndicator(),
              Column(children: [
                scanComplete ? Text('Device found!') :
                Text(
                    'Looking for the device...\nHold the phone close to the device.')
              ]),
              Text(_nfcResult),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 25),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: scanComplete ? () {
            Navigator.pushNamed(context, '/add_unit_3', arguments: {"userId": userId, "unitId": unitId});
          } : null,
          child: scanComplete ? Text('Add device', style: TextStyle(fontSize: 16)) : Text('Searching...', style: TextStyle(fontSize: 16))

          ,
        ),
      ),
    );
  }
}
