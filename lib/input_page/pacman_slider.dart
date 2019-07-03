import 'dart:math' as math;
import 'package:bmi_calculator/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const double _pacmanWidth = 21.0;
const double _sliderHorizontalMargin = 24.0;
const double _dotsLeftMargin = 8.0;

class Dot extends StatelessWidget {
  final double size;
  Dot({Key key, @required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenAwareSize(size, context),
      width: screenAwareSize(size, context),
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
    );
  }
}

class PacmanIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: screenAwareSize(16.0, context)),
      child: SvgPicture.asset(
        'images/pacman.svg',
        width: screenAwareSize(21.0, context),
        height: screenAwareSize(25.0, context),
      ),
    );
  }
}

class PacmanSlider extends StatefulWidget {
  final VoidCallback onSubmit;
  final AnimationController submitAnimationController;

  PacmanSlider({Key key, this.onSubmit, this.submitAnimationController})
      : super(key: key);

  @override
  _PacmanSliderState createState() => _PacmanSliderState();
}

class _PacmanSliderState extends State<PacmanSlider>
    with TickerProviderStateMixin {
  double _pacmanPosition = 24.0;
  AnimationController pacmanMovementController;
  Animation<double> pacmanAnimation;
  Animation<BorderRadius> _bordersAnimation;
  Animation<double> _submitWidthAnimation;

  double get width => _submitWidthAnimation?.value ?? 0.0;

  @override
  void initState() {
    super.initState();
    pacmanMovementController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _bordersAnimation = BorderRadiusTween(
            begin: BorderRadius.circular(8.0), end: BorderRadius.circular(50.0))
        .animate(
      CurvedAnimation(
        parent: widget.submitAnimationController,
        curve: Interval(0.0, 0.07),
      ),
    );
  }

  @override
  void dispose() {
    pacmanMovementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _submitWidthAnimation = Tween<double>(
          begin: constraints.maxWidth,
          end: screenAwareSize(52.0, context),
        ).animate(CurvedAnimation(
          parent: widget.submitAnimationController,
          curve: Interval(0.05, 0.15),
        ));
        return AnimatedBuilder(
          animation: widget.submitAnimationController,
          builder: (context, child) {
            Decoration decoration = BoxDecoration(
              borderRadius: _bordersAnimation.value,
              color: Theme.of(context).primaryColor,
            );

            return Center(
              child: Container(
                width: width,
                height: screenAwareSize(52.0, context),
                decoration: decoration,
                child: _submitWidthAnimation.isDismissed
                    ? GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () =>
                            _animatePacmanToEnd(width: constraints.maxWidth),
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: <Widget>[
                            AnimatedDots(),
                            _drawDotCurtain(decoration,
                                width: constraints.maxWidth),
                            _drawPacman(width: constraints.maxWidth),
                          ],
                        ),
                      )
                    : Container(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _drawDotCurtain(Decoration decoration, {double width = 0.0}) {
    if (width == 0.0) {
      return Container();
    }

    double marginRight =
        width - _pacmanPosition - screenAwareSize(_pacmanWidth / 2, context);

    return Positioned.fill(
      right: marginRight,
      child: Container(
        decoration: decoration,
      ),
    );
  }

  Widget _drawPacman({double width}) {
    if (pacmanAnimation == null && width != 0.0) {
      pacmanAnimation = _initPacmanAnimation(width);
    }

    return Positioned(
      left: _pacmanPosition,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) => _onPacmanDrag(width, details),
        onHorizontalDragEnd: (details) => _onPacmanEnd(width, details),
        child: PacmanIcon(),
      ),
    );
  }

  Animation<double> _initPacmanAnimation(double width) {
    Animation<double> animation =
        Tween(begin: 0.0, end: _pacmanMaxPosition(width))
            .animate(pacmanMovementController);

    animation.addListener(() {
      setState(() {
        _pacmanPosition = animation.value;
      });

      if (animation.status == AnimationStatus.completed) {
        _onPacmanSubmited();
      }
    });

    return animation;
  }

  _onPacmanSubmited() {
    widget?.onSubmit();
    Future.delayed(Duration(seconds: 1), () => _resetPacman());
  }

  _onPacmanDrag(double width, DragUpdateDetails details) {
    setState(() {
      _pacmanPosition += details.delta.dx;
      _pacmanPosition = math.max(_pacmanMinPosition(),
          math.min(_pacmanMaxPosition(width), _pacmanPosition));
    });
  }

  _onPacmanEnd(double width, DragEndDetails details) {
    bool isOverHalf =
        _pacmanPosition + screenAwareSize(_pacmanWidth / 2, context) >
            0.5 * width;

    if (isOverHalf) {
      _animatePacmanToEnd(width: width);
    } else {
      _resetPacman();
    }
  }

  _animatePacmanToEnd({double width}) {
    pacmanMovementController.forward(
        from: _pacmanPosition / _pacmanMaxPosition(width));
  }

  _resetPacman() {
    setState(() {
      _pacmanPosition = _pacmanMinPosition();
    });
  }

  double _pacmanMinPosition() =>
      screenAwareSize(_sliderHorizontalMargin, context);
  double _pacmanMaxPosition(double sliderWidth) =>
      sliderWidth -
      screenAwareSize(_sliderHorizontalMargin / 2 + _pacmanWidth, context);
}

class AnimatedDots extends StatefulWidget {
  @override
  _AnimatedDotsState createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots>
    with TickerProviderStateMixin {
  final int numberOfDots = 10;
  final double minOpacity = 0.1;
  final double maxOpacity = 0.5;
  AnimationController hintAnimationController;

  @override
  void initState() {
    super.initState();
    _initHintAnimationController();
    hintAnimationController.forward();
  }

  @override
  void dispose() {
    hintAnimationController.dispose();
    super.dispose();
  }

  void _initHintAnimationController() {
    hintAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    hintAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(milliseconds: 800), () {
          try {
            hintAnimationController.forward(from: 0.0);
          } catch (e) {}
        });
      }
    });
  }

  Animation<double> _initDotAnimation(int dotNumber) {
    double lastDotStartTime = 0.4;
    double dotAnimationDuration = 0.6;
    double begin = lastDotStartTime * dotNumber / numberOfDots;
    double end = begin + dotAnimationDuration;

    return SinusoidalAnimation(min: minOpacity, max: maxOpacity).animate(
      CurvedAnimation(
        parent: hintAnimationController,
        curve: Interval(begin, end),
      ),
    );
  }

  Widget _generateDot(int dotNumber) {
    Animation animation = _initDotAnimation(dotNumber);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
            opacity: animation.value,
            child: child,
          ),
      child: Dot(size: 9.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: screenAwareSize(
            _sliderHorizontalMargin + _pacmanWidth + _dotsLeftMargin, context),
        right: screenAwareSize(_sliderHorizontalMargin, context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(numberOfDots, _generateDot)
          ..add(
            Opacity(
              opacity: maxOpacity,
              child: Dot(size: 14.0),
            ),
          ),
      ),
    );
  }
}

class SinusoidalAnimation extends Animatable<double> {
  final double min;
  final double max;

  SinusoidalAnimation({this.min, this.max});

  @override
  double transform(double t) {
    return min + (max - min) * math.sin(math.pi * t);
  }
}
