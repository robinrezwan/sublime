import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TwoLayerCircularPercentIndicator extends StatelessWidget {
  const TwoLayerCircularPercentIndicator({
    Key? key,
    required this.radius,
    this.lineWidth = 6,
    required this.primaryProgressColor,
    required this.secondaryProgressColor,
    required this.backgroundColor,
    required this.primaryPercent,
    required this.secondaryPercent,
    required this.center,
  }) : super(key: key);

  final double radius;
  final double lineWidth;
  final Color primaryProgressColor;
  final Color secondaryProgressColor;
  final Color backgroundColor;
  final double primaryPercent;
  final double secondaryPercent;
  final Widget center;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircularPercentIndicator(
          radius: radius,
          lineWidth: lineWidth,
          backgroundWidth: lineWidth,
          progressColor: secondaryProgressColor,
          backgroundColor: backgroundColor,
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animateFromLastPercent: true,
          percent: secondaryPercent,
        ),
        CircularPercentIndicator(
          radius: radius,
          lineWidth: lineWidth,
          backgroundWidth: lineWidth,
          progressColor: primaryProgressColor,
          backgroundColor: Colors.transparent,
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animateFromLastPercent: true,
          percent: primaryPercent,
          center: center,
        ),
      ],
    );
  }
}
