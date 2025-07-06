// import 'dart:math';

import 'package:flutter/material.dart';

class BasicExample extends StatelessWidget {
  const BasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PieChart(
          data: const [
            PieChartData(Colors.purple, 60),
            PieChartData(Colors.blue, 25),
            PieChartData(Colors.orange, 15),
          ],
          radius: 100,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Top',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Job Sources'),
            ],
          ),
        ),
      ),
    );
  }
}

class PieChart extends StatelessWidget {
  final List<PieChartData> data;
  final double radius;
  final double? strokeWidth;
  final Widget? child;

  PieChart(
      {super.key,
      required this.data,
      required this.radius,
      this.strokeWidth = 10,
      this.child})
      : assert(data.fold<double>(0, (sum, data) => sum + data.percent) <= 100);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PaintPieChart(strokeWidth!, data),
      size: Size.square(radius),
      child: SizedBox.square(
        dimension: radius * 2,
        child: Center(child: child),
      ),
    );
  }
}

class PieChartData {
  const PieChartData(this.color, this.percent);

  final Color color;
  final double percent;
}

// responsible for painting our chart
class _PainterData {
  const _PainterData(this.paint, this.radians);

  final Paint paint;
  final double radians;
}

class PaintPieChart extends CustomPainter {
  PaintPieChart(double strokeWidth, List<PieChartData> data) {
    // convert chart data to painter data
    dataList = data
        .map((e) => _PainterData(
              Paint()
                ..color = e.color
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..strokeCap = StrokeCap.round,
              // remove padding from stroke
              (e.percent - _padding) * _percentInRadians,
            ))
        .toList();
  }

  static const _percentInRadians = 0.062831853071796;
  static const _padding = 4;
  static const _paddingInRadians = _percentInRadians * _padding;
  // 0 radians is to the right, but since we want to start from the top
  // we'll use -90 degrees in radians
  static const _startAngle = -1.570796 + _paddingInRadians / 2;

  late final List dataList;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // keep track of start angle for next stroke
    double startAngle = _startAngle;

    for (final data in dataList) {
      final path = Path()..addArc(rect, startAngle, data.radians);

      startAngle += data.radians + _paddingInRadians;

      canvas.drawPath(path, data.paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
