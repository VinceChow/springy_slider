import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primaryColor: Color(0xFFFF6688),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _buildTextButton(String title, bool isOnLight) {
    return FlatButton(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: isOnLight ? Theme.of(context).primaryColor : Colors.white,
        ),
      ),
      onPressed: () {
        // TODO:
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          brightness: Brightness.light,
          iconTheme: IconThemeData(
            color: Theme.of(context).primaryColor,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.menu,
            ),
            onPressed: () {
              // TODO:
            },
          ),
          actions: <Widget>[
            _buildTextButton('settings'.toUpperCase(), true),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: SpringySlider(
                markCount: 12,
                positiveColor: Theme.of(context).primaryColor,
                negativeColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            Container(
              color: Theme.of(context).primaryColor,
              child: Row(
                children: <Widget>[
                  _buildTextButton('more'.toUpperCase(), false),
                  Expanded(
                    child: Container(),
                  ),
                  _buildTextButton('stats'.toUpperCase(), false),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SpringySlider extends StatefulWidget {
  final int markCount;
  final Color positiveColor;
  final Color negativeColor;

  SpringySlider({
    this.markCount,
    this.positiveColor,
    this.negativeColor,
  });

  @override
  _SpringySliderState createState() => new _SpringySliderState();
}

class _SpringySliderState extends State<SpringySlider> {
  final double paddingTop = 50.0;
  final double paddingBottom = 50.0;
  final double sliderPercent = 0.5;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SliderMarks(
          markCount: widget.markCount,
          color: widget.positiveColor,
          paddingTop: paddingTop,
          paddingBottom: paddingBottom,
        ),
        ClipPath(
          clipper: SliderClipper(),
          child: Stack(
            children: <Widget>[
              Container(
                color: widget.positiveColor,
              ),
              SliderMarks(
                markCount: widget.markCount,
                color: widget.negativeColor,
                paddingTop: paddingTop,
                paddingBottom: paddingBottom,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: paddingTop,
            bottom: paddingBottom,
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final height = constraints.maxHeight;
              final sliderY = height * (1.0 - sliderPercent);
              final pointsYouNeed = (100 * (1.0 - sliderPercent)).round();
              final pointsYouHave = 100 - pointsYouNeed;

              return Stack(
                children: <Widget>[
                  Positioned(
                    left: 30.0,
                    top: sliderY - 50.0,
                    child: FractionalTranslation(
                      translation: Offset(0.0, -1.0),
                      child: Points(
                        points: pointsYouNeed,
                        isAboveSlider: true,
                        isPointsYouNeed: true,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 30.0,
                    top: sliderY + 50.0,
                    child: Points(
                      points: pointsYouHave,
                      isAboveSlider: false,
                      isPointsYouNeed: false,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class SliderMarks extends StatelessWidget {
  final int markCount;
  final Color color;
  final double paddingTop;
  final double paddingBottom;

  SliderMarks({
    this.markCount,
    this.color,
    this.paddingTop,
    this.paddingBottom,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SliderMarksPainter(
        markCount: markCount,
        color: color,
        markThickness: 2.0,
        paddingTop: paddingTop,
        paddingBottom: paddingBottom,
        paddingRight: 20.0,
      ),
      child: Container(),
    );
  }
}

class SliderMarksPainter extends CustomPainter {
  final double largeMarkWidth = 30.0;
  final double smallMarkWidth = 10.0;

  final int markCount;
  final Color color;
  final double markThickness;
  final double paddingTop;
  final double paddingBottom;
  final double paddingRight;
  final Paint markPaint;

  SliderMarksPainter({
    this.markCount,
    this.color,
    this.markThickness,
    this.paddingTop,
    this.paddingBottom,
    this.paddingRight,
  }) : markPaint = new Paint()
          ..color = color
          ..strokeWidth = markThickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final paintHeight = size.height - paddingTop - paddingBottom;
    final gap = paintHeight / (markCount - 1);

    for (int i = 0; i < markCount; i++) {
      double markWidth = smallMarkWidth;
      if (i == 0 || i == markCount - 1)
        markWidth = largeMarkWidth;
      else if (i == 1 || i == markCount - 2)
        markWidth = lerpDouble(smallMarkWidth, largeMarkWidth, 0.5);

      final markY = i * gap + paddingTop;

      canvas.drawLine(
        new Offset(size.width - paddingRight - markWidth, markY),
        new Offset(size.width - paddingRight, markY),
        markPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class SliderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path rect = Path();

    rect.addRect(
      new Rect.fromLTWH(
        0.0,
        size.height / 2,
        size.width,
        size.height / 2,
      ),
    );

    return rect;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class Points extends StatelessWidget {
  final int points;
  final bool isAboveSlider;
  final bool isPointsYouNeed;
  final Color color;

  Points({
    this.points,
    this.isAboveSlider = true,
    this.isPointsYouNeed = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = points / 100.0;
    final pointTextSize = 30.0 + (70.0 * percent);

    return Row(
      crossAxisAlignment:
          isAboveSlider ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        FractionalTranslation(
          translation: Offset(0.0, isAboveSlider ? 0.18 : -0.18),
          child: Text(
            '$points',
            style: TextStyle(
              fontSize: pointTextSize,
              color: color,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'POINTS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Text(
                isPointsYouNeed ? 'YOU NEED' : 'YOU HAVE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
