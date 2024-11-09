// lib/widgets/hexagon_stats_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class HexagonStatsWidget extends StatelessWidget {
  final Map<String, double> characteristics;
  final double size;

  const HexagonStatsWidget({
    Key? key,
    required this.characteristics,
    this.size = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: HexagonStatsPainter(
        characteristics: characteristics,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

class HexagonStatsPainter extends CustomPainter {
  final Map<String, double> characteristics;
  final Color color;
  final List<String> labels = ['단맛', '신맛', '쓴맛', '탁도', '향', '청량함'];

  HexagonStatsPainter({
    required this.characteristics,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // 배경 육각형 그리기
    _drawBackground(canvas, center, radius);
    
    // 데이터 육각형 그리기
    _drawDataHexagon(canvas, center, radius);
    
    // 라벨 그리기
    _drawLabels(canvas, center, radius);
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 5개의 동심 육각형 그리기 (0-5 척도)
    for (int i = 1; i <= 5; i++) {
      final path = Path();
      for (int j = 0; j < 6; j++) {
        final angle = (j * 60) * math.pi / 180;
        final currentRadius = radius * i / 5;
        final point = Offset(
          center.dx + currentRadius * math.cos(angle),
          center.dy + currentRadius * math.sin(angle),
        );
        
        if (j == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawDataHexagon(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    final values = [
      characteristics['sweet'] ?? 0,      // 단맛
      characteristics['sour'] ?? 0,       // 신맛
      characteristics['bitter'] ?? 0,      // 쓴맛
      characteristics['turbidity'] ?? 0,   // 탁도
      characteristics['fragrance'] ?? 0,   // 향
      characteristics['crisp'] ?? 0,       // 청량함
    ];

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final value = values[i] / 5.0;  // 0-5 척도로 정규화
      final point = Offset(
        center.dx + radius * value * math.cos(angle),
        center.dy + radius * value * math.sin(angle),
      );
      
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // 외곽선 그리기
    paint
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 2.0;
    canvas.drawPath(path, paint);
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    final textStyle = TextStyle(
      color: Colors.black87,
      fontSize: radius * 0.15,
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final offset = Offset(
        center.dx + (radius + 25) * math.cos(angle),
        center.dy + (radius + 25) * math.sin(angle),
      );

      final textSpan = TextSpan(
        text: labels[i],
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          offset.dx - textPainter.width / 2,
          offset.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}