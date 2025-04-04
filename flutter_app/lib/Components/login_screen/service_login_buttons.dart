import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServiceLoginButtons extends StatelessWidget {
  const ServiceLoginButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment
          .spaceBetween,
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: Icon(
              Icons.facebook, color: Colors.blue),
          // Facebook icon
          label: Text("Facebook",
              style: TextStyle(color: Colors.black)),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
                vertical: 15, horizontal: 30),
            side: BorderSide(
                color: Colors.grey.shade300),
            // Border color
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    8)),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: FaIcon(FontAwesomeIcons.google,
              color: Color(0xFFFF4F04)),
          // Facebook icon
          label: Text("Google",
              style: TextStyle(color: Colors.black)),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
                vertical: 15, horizontal: 42),
            side: BorderSide(
                color: Colors.grey.shade300),
            // Border color
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    8)),
          ),
        ),
      ],
    );
  }
}