import 'package:flutter/material.dart';

class Neumorphism extends StatelessWidget {
  Neumorphism({
    super.key,
    required this.child,
    this.distance = 30,
    this.blur = 50,
    this.margin,
    this.padding,
    this.isReverse = false,
    this.innerShadow = false,
  });
  final primary = const Color(0xffe4e2dc);
  final darkprimary = const Color(0xffc5c2bd);
  final Widget child;
  final double distance;
  final double blur;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool isReverse;
  final bool innerShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
          color: primary,
          shape: BoxShape.circle,
          boxShadow: isReverse
              ? [
                  BoxShadow(
                      blurRadius: blur,
                      color: darkprimary,
                      offset: Offset(-distance, -distance)),
                  BoxShadow(
                      blurRadius: blur,
                      color: Colors.white,
                      offset: Offset(distance, distance))
                ]
              : [
                  BoxShadow(
                      blurRadius: blur,
                      color: Colors.white,
                      offset: Offset(-distance, -distance)),
                  BoxShadow(
                      blurRadius: blur,
                      color: darkprimary,
                      offset: Offset(distance, distance))
                ]),
      child: innerShadow
          ? TopContainer(primary: primary, child: child)
          : child,
    );
  }
}

class TopContainer extends StatelessWidget {
  const TopContainer({
    super.key,
     this.primary =const Color(0xffe4e2dc),
    required this.child, this.margin, this.padding,
  });

  final Color primary;
  final Widget child;
 final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin, 
      padding: padding,
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [ Color(0xffc5c2bd), Colors.white])),
        child: child,
      );
  }
}
