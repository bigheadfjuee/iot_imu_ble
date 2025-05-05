import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/global_state.dart';
import 'app_colors.dart';

class LinePage extends ConsumerStatefulWidget {
  const LinePage({super.key});

  final Color axColor = AppColors.contentColorBlue;
  final Color ayColor = AppColors.contentColorYellow;
  final Color azColor = AppColors.contentColorOrange;
  final Color gxColor = AppColors.contentColorGreen;
  final Color gyColor = AppColors.contentColorPink;
  final Color gzColor = AppColors.contentColorCyan;

  @override
  ConsumerState<LinePage> createState() => _LinePageState();
}

class _LinePageState extends ConsumerState<LinePage> {
  final limitCount = 100;
  final axPoints = <FlSpot>[];
  final ayPoints = <FlSpot>[];
  final azPoints = <FlSpot>[];

  final gxPoints = <FlSpot>[];
  final gyPoints = <FlSpot>[];
  final gzPoints = <FlSpot>[];

  double xValue = 0;
  double step = 0.05;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      while (axPoints.length > limitCount) {
        axPoints.removeAt(0);
        ayPoints.removeAt(0);
        azPoints.removeAt(0);
      }
      setState(() {
        axPoints.add(FlSpot(xValue, math.sin(xValue)));
        ayPoints.add(FlSpot(xValue, math.cos(xValue)));
        azPoints.add(FlSpot(xValue, math.sin(xValue + 3)));
      });
      xValue += step;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ayPoints.isNotEmpty
        ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Text(
              'x: ${xValue.toStringAsFixed(1)}',
              style: const TextStyle(
                color: AppColors.contentColorBlack,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'aX: ${axPoints.last.y.toStringAsFixed(1)}',
              style: TextStyle(
                color: widget.axColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'aY: ${ayPoints.last.y.toStringAsFixed(1)}',
              style: TextStyle(
                color: widget.ayColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'aZ: ${azPoints.last.y.toStringAsFixed(1)}',
              style: TextStyle(
                color: widget.azColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.5,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: LineChart(
                  LineChartData(
                    minY: -1,
                    maxY: 1,
                    minX: axPoints.first.x,
                    maxX: axPoints.last.x,
                    lineTouchData: const LineTouchData(enabled: false),
                    clipData: const FlClipData.all(),
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      axLine(axPoints),
                      ayLine(ayPoints),
                      azLine(azPoints),
                    ],
                    titlesData: const FlTitlesData(show: false),
                  ),
                ),
              ),
            ),
          ],
        )
        : Container();
  }

  LineChartBarData axLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(show: false),
      gradient: LinearGradient(
        colors: [widget.axColor.withValues(alpha: 0), widget.axColor],
        stops: const [0.1, 1.0],
      ),
      barWidth: 3,
      isCurved: false,
    );
  }

  LineChartBarData ayLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(show: false),
      gradient: LinearGradient(
        colors: [widget.ayColor.withValues(alpha: 0), widget.ayColor],
        stops: const [0.1, 1.0],
      ),
      barWidth: 3,
      isCurved: false,
    );
  }

  LineChartBarData azLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(show: false),
      gradient: LinearGradient(
        colors: [widget.azColor.withValues(alpha: 0), widget.azColor],
        stops: const [0.1, 1.0],
      ),
      barWidth: 3,
      isCurved: false,
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
