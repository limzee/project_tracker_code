import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final Function(String) onChanged;
  final bool isPassword;
  final String title;
  const CustomInputField({
    this.isPassword = false,
    required this.onChanged,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TextField(
          obscureText: isPassword,
          onChanged: onChanged,
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      10),
                  borderSide: BorderSide(
                      color: Color(0xFFDEDEDE),
                      width: 1)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      10),
                  borderSide: BorderSide(
                      color: Color(0xFFDEDEDE),
                      width: 1))
          ),
        ),
        Positioned(
            top: -10,
            left: 4,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 15, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Text(title,
                  style: TextStyle(
                    color: Color(0xFFB5B5B5),
                    letterSpacing: 0,
                  )),
            )

        )
      ],
    );
  }
}