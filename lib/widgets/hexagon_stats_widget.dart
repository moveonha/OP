import 'package:flutter/material.dart';
import 'dart:math' show pi, cos, sin;

class HexagonStatsWidget extends StatelessWidget {
  final Map<String, dynamic> characteristics;
  final Map<String, dynamic>? userPreferences;
  final double size;

  const HexagonStatsWidget({
    Key? key,
    required this.characteristics,
    this.userPreferences,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size + 40,
      child: CustomPaint(
        size: Size(size, size),
        painter: HexagonStatsPainter(
          characteristics: _normalizeValues(characteristics),
          userPreferences: userPreferences != null 
              ? _normalizeValues(userPreferences!) 
              : null,
          backgroundColor: Colors.grey[50]!,
          foregroundColor: Colors.orange.withOpacity(0.2),
          userColor: Colors.blue.withOpacity(0.2),
          strokeColor: Colors.orange,
          userStrokeColor: Colors.blue,
          guidelineColor: Colors.grey[300]!,
          labelColor: Colors.grey[600]!,
        ),
        child: Stack(
          children: _buildLabels(),
        ),
      ),
    );
  }

  Map<String, double> _normalizeValues(Map<String, dynamic> values) {
    Map<String, double> normalized = {};
    values.forEach((key, value) {
      if (value is num) {
        normalized[key] = value.toDouble();
      }
    });
    return normalized;
  }

  List<Widget> _buildLabels() {
    final center = size / 2;
    final radius = size * 0.48;
    const labels = {
      '단맛': 0,
      '신맛': 60,
      '쓴맛': 120,
      '탁도': 180,
      '향': 240,
      '청량감': 300,
    };

    return labels.entries.map((entry) {
      final angle = entry.value * pi / 180;
      final x = center + radius * cos(angle - pi / 2);
      final y = center + radius * sin(angle - pi / 2);
      
      final value = characteristics[_getKey(entry.key)] ?? 0.0;
      final displayValue = (value * 100).toInt();
      
      final userValue = userPreferences?[_getKey(entry.key)];
      final userDisplayValue = userValue != null ? (userValue * 100).toInt() : null;

      return Positioned(
        left: x - 40,
        top: y - 9,
        child: SizedBox(
          width: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      entry.key,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (userDisplayValue != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildValueLabel(displayValue, Colors.orange),
                          const SizedBox(width: 4),
                          _buildValueLabel(userDisplayValue, Colors.blue),
                        ],
                      ),
                    ] else
                      Text(
                        '$displayValue%',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildValueLabel(int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getKey(String label) {
    switch (label) {
      case '단맛': return 'sweet';
      case '신맛': return 'sour';
      case '쓴맛': return 'bitter';
      case '탁도': return 'turbidity';
      case '향': return 'fragrance';
      case '청량감': return 'crisp';
      default: return '';
    }
  }
}

class HexagonStatsPainter extends CustomPainter {
  final Map<String, double> characteristics;
  final Map<String, double>? userPreferences;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color userColor;
  final Color strokeColor;
  final Color userStrokeColor;
  final Color guidelineColor;
  final Color labelColor;

  HexagonStatsPainter({
    required this.characteristics,
    this.userPreferences,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.userColor,
    required this.strokeColor,
    required this.userStrokeColor,
    required this.guidelineColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    _drawGrid(canvas, center, radius);
    _drawDataArea(canvas, center, radius, characteristics, foregroundColor, strokeColor);
    
    if (userPreferences != null) {
      _drawDataArea(canvas, center, radius, userPreferences!, userColor, userStrokeColor);
    }
  }

  void _drawGrid(Canvas canvas, Offset center, double radius) {
    for (var i = 1; i <= 5; i++) {
      final gridRadius = radius * (i / 5);
      _drawHexagon(
        canvas,
        center,
        gridRadius,
        guidelineColor.withOpacity(0.3),
        true,
        0.5,
      );

      if (i < 5) {
        final percent = (i * 20).toString();
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$percent%',
            style: TextStyle(
              color: labelColor.withOpacity(0.5),
              fontSize: 8,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            center.dx - textPainter.width / 2,
            center.dy - gridRadius - textPainter.height - 2,
          ),
        );
      }
    }

    for (var i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * pi / 180;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(
        center,
        point,
        Paint()
          ..color = guidelineColor.withOpacity(0.3)
          ..strokeWidth = 0.5,
      );
    }
  }

  void _drawDataArea(
    Canvas canvas,
    Offset center,
    double radius,
    Map<String, double> data,
    Color fillColor,
    Color borderColor,
  ) {
    final path = Path();
    final values = [
      data['sweet'] ?? 0,
      data['sour'] ?? 0,
      data['bitter'] ?? 0,
      data['turbidity'] ?? 0,
      data['fragrance'] ?? 0,
      data['crisp'] ?? 0,
    ];

    for (var i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * pi / 180;
      final point = Offset(
        center.dx + radius * values[i] * cos(angle),
        center.dy + radius * values[i] * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    for (var i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * pi / 180;
      final point = Offset(
        center.dx + radius * values[i] * cos(angle),
        center.dy + radius * values[i] * sin(angle),
      );

      canvas.drawCircle(
        point,
        2.5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        point,
        1.5,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _drawHexagon(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    bool isStroke,
    double strokeWidth,
  ) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * pi / 180;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = isStroke ? PaintingStyle.stroke : PaintingStyle.fill
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}