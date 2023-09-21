import 'dart:math';

import 'package:compass/neumorphism.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Compass',
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
        color: Color.fromARGB(255, 102, 9, 2),
      )),
      debugShowCheckedModeBanner: false,
      home: const Compass(),
    );
  }
}

class Compass extends StatefulWidget {
  const Compass({super.key});

  @override
  State<Compass> createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  double? direction;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Compass'),
          centerTitle: true,
        ),
        body: StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error While reading from compass');
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              direction = snapshot.data!.heading;
              if (direction == null) {
                return const Text('There is No sensor in device');
              }
              return Stack(
                children: [
                  Neumorphism(
                    margin: EdgeInsets.all(size.width * 0.055),
                    padding: const EdgeInsets.all(12),
                    child: Transform.rotate(
                      angle: (direction! * (90 / 180) * -1),
                      child: CustomPaint(
                        size: size,
                        painter: CompassViewPainter(color: Colors.grey),
                      ),
                    ),
                  ),
                  Neumorphism(
                    margin: EdgeInsets.all(size.width * 0.267),
                    distance: 2.6,
                    blur: 6,
                    child: Neumorphism(
                      margin: EdgeInsets.all(size.width * 0.01),
                      distance: 0,
                      blur: 0,
                      isReverse: true,
                      innerShadow: true,
                      child: Neumorphism(
                        margin: EdgeInsets.all(size.width * 0.05),
                        distance: 4,
                        blur: 5,
                        child: TopContainer(
                          padding: EdgeInsets.all(size.width * 0.02),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 98, 176, 139),
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment(-5, -5),
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.fromARGB(255, 170, 203, 187),
                                  Color.fromARGB(255, 145, 185, 147),
                                ],
                              ),
                            ),
                            child: Text(
                              ' ${direction!.toInt().toString().padLeft(3, '0')}°',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }));
  }
}

class CompassViewPainter extends CustomPainter {
  final Color color;
  final int major;
  final int minor;
  final Cardinals card;

  CompassViewPainter({
    required this.color,
    this.major = 18,
    this.minor = 90,
    this.card = const {0: 'N', 90: 'E', 180: 'S', 270: 'W'},
  });

  late final majorScalePaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = color
    ..strokeWidth = 2.0;

  late final minaorScalePaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = color.withOpacity(0.7)
    ..strokeWidth = 1.0;

  late final majorScaleStyle = TextStyle(
    fontSize: 12,
    color: color,
  );

  late final cardStyle = const TextStyle(
      fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold);

  late final _majorTicks = _layoutScale(major);
  late final _minorTicks = _layoutScale(minor);
  late final _angleDigree = _layoutAngleScale(_majorTicks);

  @override
  void paint(Canvas canvas, Size size) {
    const origin = Offset.zero;
    final center = size.center(origin);
    final radius = size.width / 2;
    final majorTickLength = size.width * 0.08;
    final minorTickLength = size.width * 0.055;
    canvas.save();
    for (final angle in _majorTicks) {
      final tickStart =
          Offset.fromDirection(_correctAngle(angle.toRadian()), radius);
      final tickEnd = Offset.fromDirection(
        _correctAngle(angle.toRadian()),
        radius - majorTickLength,
      );
      canvas.drawLine(center + tickStart, center + tickEnd, majorScalePaint);
    }

    for (final angle in _minorTicks) {
      final tickStart =
          Offset.fromDirection(_correctAngle(angle.toRadian()), radius);
      final tickEnd = Offset.fromDirection(
        _correctAngle(angle.toRadian()),
        radius - minorTickLength,
      );
      canvas.drawLine(center + tickStart, center + tickEnd, minaorScalePaint);
    }

    for (final angle in _angleDigree) {
      final textPad = majorTickLength - size.width * 0.001;
      final textPainter = TextSpan(
        text: angle.toStringAsFixed(0),
        style: majorScaleStyle,
      ).toPainter()
        ..layout();

      final layoutOffset = Offset.fromDirection(
        _correctAngle(angle).toRadian(),
        radius - textPad,
      );
      final offset = center + layoutOffset;

      canvas.restore();
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(angle.toRadian());
      canvas.translate(-offset.dx, -offset.dy);
      textPainter.paint(
          canvas, Offset(offset.dx - (textPainter.width + 4), offset.dy));
    }

    for (final car in card.entries) {
      final textPad = majorTickLength + size.width * 0.04;
      final angle = car.key.toDouble();
      final text = car.value;
      final textPainter = TextSpan(
        text: text,
        style: cardStyle.copyWith(color: text == 'N' ? Colors.red : null),
      ).toPainter()
        ..layout();

      final layoutOffset = Offset.fromDirection(
        _correctAngle(angle).toRadian(),
        radius - textPad,
      );
      final offset = center + layoutOffset;

      canvas.restore();
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(angle.toRadian());
      canvas.translate(-offset.dx, -offset.dy);
      textPainter.paint(
          canvas, Offset(offset.dx - (textPainter.width / 0.7), offset.dy));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  List<double> _layoutScale(int ticks) {
    final scale = 360 / ticks;
    return List.generate(ticks, (index) => index * scale);
  }

  List<double> _layoutAngleScale(List<double> ticks) {
    List<double> angle = [];
    for (var i = 0; i < ticks.length; i++) {
      if (i == ticks.length - 1) {
        double degreeVal = (ticks[i] + 360) / 2;
        angle.add(degreeVal);
      } else {
        double degreeVal = (ticks[i] + ticks[i + 1]) / 2;
        angle.add(degreeVal);
      }
    }
    return angle;
  }

  double _correctAngle(double angle) => angle - 90;
}

extension on num {
  double toRadian() => this * pi / 180;
}

extension on TextSpan {
  TextPainter toPainter({TextDirection textDirection = TextDirection.ltr}) =>
      TextPainter(text: this, textDirection: textDirection);
}

typedef Cardinals = Map<num, String>;  // to define a new object 
