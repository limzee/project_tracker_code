import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(color: Color(0xFF0D1C2E),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              vertical: 35, horizontal: 25),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -230,
                left: -175,
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    color: Color(0xFF152534),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: -153,
                left: -116,
                child: Container(
                  width: 333,
                  height: 333,
                  decoration: BoxDecoration(
                    color: Color(0xFF1E2E3D),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sign in to your Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      )
                  ),
                  SizedBox(height: 15),
                  Text("Keep track of your items in no time",
                      style: TextStyle(
                        color: Color(0xFFB5B5B5),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ))
                ],

              )
            ],
          )
      ),
    );
  }
}