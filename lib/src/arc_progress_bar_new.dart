import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vector;
import 'classes/arc_paint.dart';
import 'extensions/nums.dart';

class ArcProgressBar extends StatefulWidget {
  const ArcProgressBar(
      {Key? key,
      this.percentage = 0,
      this.innerPadding = 16,
      this.animateFromLastPercent = true,
      this.animationDuration = const Duration(seconds: 1),
      this.animationCurve = Curves.easeInOutCubic,
      this.handleSize,
      this.handleWidget,
      this.handleColor,
      this.arcThickness = 10,
      this.strokeCap = StrokeCap.square,
      this.backgroundColor = Colors.black12,
      this.foregroundColor = Colors.black,
      this.bottomCenterWidget,
      this.bottomRightWidget,
      this.bottomLeftWidget,
      this.centerWidget,
      this.onAnimationStart,
      this.onAnimationEnd,
      this.activeDotColor = Colors.green,
      this.inactiveDotColor = Colors.grey})
      : super(key: key);

  final double percentage;
  final double? handleSize;
  final Widget? handleWidget;
  final Color? handleColor;
  final double innerPadding;
  final double arcThickness;
  final StrokeCap strokeCap;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? centerWidget;
  final Widget? bottomLeftWidget;
  final Widget? bottomRightWidget;
  final Widget? bottomCenterWidget;
  final Function? onAnimationEnd;
  final Function? onAnimationStart;
  final Curve animationCurve;
  final Duration animationDuration;
  final bool animateFromLastPercent;

  // Yeni parametreler:
  final Color activeDotColor;
  final Color inactiveDotColor;

  @override
  State<ArcProgressBar> createState() => _ArcProgressBarState();
}

class _ArcProgressBarState extends State<ArcProgressBar>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController _animationController;

  double _handleSize = 10;
  double _percent = 0.0;
  double canvasSize = 300;
  Color _handleColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    _handleSize = widget.handleSize ?? (widget.arcThickness * 2);
    _handleColor = widget.handleColor ?? widget.foregroundColor;
    _percent = _percent.isNaN ? 0 : _percent;

    final sweep = _percent.clamp(0, 100) * (180 / 100);
    return LayoutBuilder(builder: (ctx, constraints) {
      double radiusForHandle = (constraints.maxWidth) / 2;
      radiusForHandle = radiusForHandle - (_handleSize / 2);

      if (constraints.maxWidth < 500) canvasSize = constraints.maxWidth;

      final dotPositions = [0.25, 0.5, 0.75, 1.0]; // 4 aşama için pozisyonlar

      return Stack(
        children: [
          CustomPaint(
            size: Size(canvasSize, canvasSize / 1.8),
            painter: ArcPaint(
                vector.radians(180), widget.backgroundColor, widget.arcThickness, widget.strokeCap,
                padding: widget.innerPadding),
          ),
          CustomPaint(
            size: Size(canvasSize, canvasSize / 1.65),
            painter: ArcPaint(
                vector.radians(sweep), widget.foregroundColor, widget.arcThickness, widget.strokeCap,
                padding: widget.innerPadding),
          ),
          // Her aşama için nokta eklemek
          ...List.generate(dotPositions.length, (index) {
            final dotPosition = dotPositions[index];
            final isActive = _percent >= (dotPosition * 100);

            return Positioned(
              left: (radiusForHandle -
                      (((radiusForHandle + (_handleSize / 2) - widget.innerPadding) *
                          math.sin(vector.radians(sweep * dotPosition))))) -
                  (_handleSize / 2),
              top: (radiusForHandle -
                      (((radiusForHandle + (_handleSize / 2) - widget.innerPadding) *
                          math.cos(vector.radians(sweep * dotPosition))))) -
                  (_handleSize / 2),
              child: CircleAvatar(
                radius: 3, // Nokta büyüklüğü
                backgroundColor: isActive ? widget.activeDotColor : widget.inactiveDotColor,
              ),
            );
          }),
          // Handle (toplam ilerlemeyi gösteren işaretçi)
          Positioned(
            left: ((radiusForHandle) -
                ((((radiusForHandle + (_handleSize / 2) - widget.innerPadding) *
                        math.sin(vector.radians((_percent.clampRange(min: 90, max: -90)))))))) -
                (_handleSize / 2),
            top: ((radiusForHandle) -
                ((((radiusForHandle + (_handleSize / 2) - widget.innerPadding) *
                        math.cos(vector.radians((_percent.clampRange(min: 90, max: -90)))))))) -
                (_handleSize / 2),
            child: Container(
              width: _handleSize,
              height: _handleSize,
              decoration: widget.handleWidget == null
                  ? BoxDecoration(
                      color: _handleColor,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: widget.handleWidget,
            ),
          ),
        ],
      );
    });
  }

  @override
  void initState() {
    _animationController =
        AnimationController(duration: widget.animationDuration, vsync: this);
    final curvedAnimation = CurvedAnimation(
        parent: _animationController, curve: widget.animationCurve);
    animation =
        Tween<double>(begin: 0, end: widget.percentage).animate(curvedAnimation)
          ..addListener(() {
            switch (_animationController.status) {
              case AnimationStatus.forward:
                if (widget.onAnimationStart != null) {
                  widget.onAnimationStart!();
                }
                break;
              case AnimationStatus.completed:
                if (widget.onAnimationEnd != null) {
                  widget.onAnimationEnd!();
                }
                break;
              default:
            }
            setState(() {
              _percent = animation.value;
            });
          });

    _animationController.forward();
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose(); // you need this
    super.dispose();
  }

  @override
  void didUpdateWidget(ArcProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animationController.duration = widget.animationDuration;
      animation = Tween(
              begin: widget.animateFromLastPercent ? oldWidget.percentage : 0.0,
              end: widget.percentage)
          .animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOutCubic),
      );
      _animationController.forward(from: 0.0);
    }
  }
}
