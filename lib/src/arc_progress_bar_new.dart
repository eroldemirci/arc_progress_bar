import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vector;
import 'classes/arc_paint.dart';
import 'extensions/nums.dart';

/// The arc progress bar widget
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
      this.onAnimationEnd})
      : super(key: key);

  /// The current progress of the arc in percentage
  final double percentage;

  /// The size of the handle
  final double? handleSize;

  /// Widget to replace the handle
  final Widget? handleWidget;

  /// The color of the handle
  final Color? handleColor;

  /// Internal padding of the widget
  final double innerPadding;

  /// Arc line thickness
  final double arcThickness;

  /// StrokeCap for the curve ends
  final StrokeCap strokeCap;

  /// Background color of the curve
  final Color backgroundColor;

  /// Foreground color of the curve
  final Color foregroundColor;

  /// Widget to display at the center of the curve
  final Widget? centerWidget;

  /// Widget to display at the bottom left of the curve
  final Widget? bottomLeftWidget;

  /// Widget to display at the bottom right of the curve
  final Widget? bottomRightWidget;

  /// Widget to display at the bottom center of the curve
  final Widget? bottomCenterWidget;

  /// Action after the progress change animation
  final Function? onAnimationEnd;

  /// Action before the progress change animation
  final Function? onAnimationStart;

  // Curve for the progress change Animation
  final Curve animationCurve;

  // Animation duration for the progress change
  final Duration animationDuration;

  // Preserve the previous state of the animation
  final bool animateFromLastPercent;

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

//
  @override
  Widget build(BuildContext context) {
    _handleSize = widget.handleSize ?? (widget.arcThickness * 2);
    _handleColor = widget.handleColor ?? widget.foregroundColor;
    // bug check!!
    _percent = _percent.isNaN ? 0 : _percent;

    // Converting the percentage progress to degrees, NB: since the arc is 180
    final sweep = _percent.clamp(0, 100) * (180 / 100);
    return LayoutBuilder(builder: (ctx, constraints) {
      double radiusForHandle = (constraints.maxWidth) / 2;
      radiusForHandle = radiusForHandle - (_handleSize / 2);

      if (constraints.maxWidth < 500) canvasSize = constraints.maxWidth;
      return Stack(
        children: [
          CustomPaint(
            size: Size(
              canvasSize,
              canvasSize / 1.8,
            ),
            painter: ArcPaint(vector.radians((180)), widget.backgroundColor,
                widget.arcThickness, widget.strokeCap,
                padding: widget.innerPadding),
          ),
          CustomPaint(
            size: Size(
              canvasSize,
              canvasSize / 1.65,
            ),
            painter: ArcPaint(vector.radians((sweep)), widget.foregroundColor,
                widget.arcThickness, widget.strokeCap,
                padding: widget.innerPadding),
          ),
          if (widget.bottomLeftWidget != null)
            Positioned(
                bottom: widget.innerPadding,
                left: 0,
                child: widget.bottomLeftWidget!),
          if (widget.bottomRightWidget != null)
            Positioned(
                bottom: widget.innerPadding,
                right: 0,
                child: widget.bottomRightWidget!),
          if (widget.bottomCenterWidget != null)
            Positioned(
                bottom: widget.innerPadding,
                left: 0,
                right: 0,
                child: Align(
                  alignment: AlignmentDirectional.center,
                  child: widget.bottomCenterWidget!,
                )),
          if (widget.centerWidget != null)
            Positioned(
                right: 0,
                left: 0,
                top: 0,
                bottom: 0,
                child: Align(
                    alignment: AlignmentDirectional.center,
                    child: widget.centerWidget!)),
          Positioned(
              left: ((radiusForHandle) -
                  ((((radiusForHandle +
                          (_handleSize / 2) -
                          widget.innerPadding) *
                      math.sin(vector.radians(
                          (_percent.clampRange(min: 90, max: -90)))))))),
              top: ((radiusForHandle) -
                  ((((radiusForHandle +
                          (_handleSize / 2) -
                          widget.innerPadding) *
                      math.cos(vector.radians(
                          (_percent.clampRange(min: 90, max: -90)))))))),
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
              )),
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
