import 'package:flutter/material.dart';
import 'dart:math' show pi, cos, sin;

class HexagonStatsWidget extends StatelessWidget {
  final Map<String, dynamic> characteristics;
  final Map<String, dynamic>? userPreferences; // 사용자 취향 데이터 추가
  final double size;

  const HexagonStatsWidget({
    Key? key,
    required this.characteristics,
    this.userPreferences,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size + 40,
      child: CustomPaint(
        size: Size(size, size),
        painter: HexagonStatsPainter(
          characteristics: characteristics,
          userPreferences: userPreferences,
          backgroundColor: Colors.grey[50]!,
          foregroundColor: Colors.orange.withOpacity(0.2),
          userColor: Colors.blue.withOpacity(0.2), // 사용자 취향 색상
          strokeColor: Colors.orange,
          userStrokeColor: Colors.blue, // 사용자 취향 테두리 색상
          guidelineColor: Colors.grey[300]!,
          labelColor: Colors.grey[600]!,
        ),
        child: Stack(
          children: _buildLabels(),
        ),
      ),
    );
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
      final value = ((characteristics[_getKey(entry.key)] ?? 0) * 100).toInt();
      final userValue = userPreferences != null 
          ? ((userPreferences![_getKey(entry.key)] ?? 0) * 100).toInt()
          : null;

      return Positioned(
        left: x - 40,
        top: y - 9,
        child: Container(
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
                    if (userValue != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$value%',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$userValue%',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ] else
                      Text(
                        '$value%',
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
  final Map<String, dynamic> characteristics;
  final Map<String, dynamic>? userPreferences;
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

    // 배경 그리드 그리기
    _drawGrid(canvas, center, radius);

    // 상품 데이터 영역 그리기
    _drawDataArea(canvas, center, radius, characteristics, foregroundColor, strokeColor);

    // 사용자 취향 데이터 영역 그리기
    if (userPreferences != null) {
      _drawDataArea(canvas, center, radius, userPreferences!, userColor, userStrokeColor);
    }
  }

  void _drawGrid(Canvas canvas, Offset center, double radius) {
    // 동심 육각형 그리기
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

      // 퍼센트 표시
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

    // 방사형 선 그리기
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

  void _drawDataArea(Canvas canvas, Offset center, double radius,
      Map<String, dynamic> data, Color fillColor, Color borderColor) {
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

    // 영역 채우기
    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    // 테두리 그리기
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 데이터 포인트 그리기
    for (var i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * pi / 180;
      final point = Offset(
        center.dx + radius * values[i] * cos(angle),
        center.dy + radius * values[i] * sin(angle),
      );

      canvas.drawCircle(
        point,
        3,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        point,
        2,
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