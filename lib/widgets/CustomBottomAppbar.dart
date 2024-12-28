import 'package:flutter/material.dart';

class CustomShapeBottomAppBar extends StatelessWidget {
  final List<Widget> actions;
  final double height;
  final double topPadding;
  final double bottomPadding;

  CustomShapeBottomAppBar({
    this.actions = const [],
    this.height = 120,
    this.topPadding = 60.0,
    this.bottomPadding = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: InvertedWaveClipper(),
      child: Container(
        height: height, // Adjustable height
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
              top: topPadding, bottom: bottomPadding, left: 16.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: actions,
          ),
        ),
      ),
    );
  }
}

class InvertedWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.3); // Start wave at 30% of the height
    path.quadraticBezierTo(
        size.width / 4, 0, size.width / 2, size.height * 0.3);
    path.quadraticBezierTo(
        3 * size.width / 4, size.height * 0.6, size.width, size.height * 0.3);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
