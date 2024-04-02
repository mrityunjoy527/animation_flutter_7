import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class Polygon extends CustomPainter {
  final int sides;

  Polygon(this.sides);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final angle = (pi * 2) / sides;
    final angles = List.generate(sides, (index) => angle * index);

    path.moveTo(center.dx + radius * cos(0), center.dy + radius * sin(0));

    for (final angle in angles) {
      path.lineTo(
          center.dx + radius * cos(angle), center.dy + radius * sin(angle));
    }

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate is Polygon && oldDelegate.sides != sides;
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late AnimationController _sidesController;
  late Animation<int> _sidesAnimation;
  late AnimationController _sizeController;
  late Animation _sizeAnimation;
  late AnimationController _rotationController;
  late Animation _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _sidesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _sidesAnimation = IntTween(
      begin: 3,
      end: 10,
    ).animate(_sidesController);

    _sizeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _sizeAnimation = Tween(
      begin: 20.0,
      end: 400.0,
    ).chain(CurveTween(curve: Curves.bounceInOut)).animate(_sizeController);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _rotateAnimation = Tween(
      begin: 0,
      end: 2 * pi,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_rotationController);
  }

  @override
  void dispose() {
    _sidesController.dispose();
    _sizeController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sidesController.repeat(reverse: true);
    _sizeController.repeat(reverse: true);
    _rotationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _sidesController,
            _sizeController,
            _rotationController,
          ]),
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateX(_rotateAnimation.value)
                ..rotateY(_rotateAnimation.value)
                ..rotateZ(_rotateAnimation.value),
              child: CustomPaint(
                painter: Polygon(_sidesAnimation.value),
                child: SizedBox(
                  height: _sizeAnimation.value,
                  width: _sizeAnimation.value,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
