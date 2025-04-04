import 'package:flutter/material.dart';

class AddUnitScreen extends StatefulWidget {
  const AddUnitScreen({super.key});

  @override
  State<AddUnitScreen> createState() => _AddUnitScreenState();
}

class _AddUnitScreenState extends State<AddUnitScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Unit'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body:  Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: 200,
                width: 200,
                  child: Image.asset("assets/click.jpg")
              ),
              Column(children: [Text('Hold the pair button on the device for 5 seconds until the LED starts blinking rapidly.')
              ]),
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
          onPressed: () {
            Navigator.pushNamed(context, '/add_unit_2');
          },
          child: Text('Next', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
