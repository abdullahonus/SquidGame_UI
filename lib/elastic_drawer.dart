library elastic_drawer;

import 'package:flutter/material.dart';

class ElasticDrawerKey {
  static final drawer = GlobalKey<_ElasticDrawerState>();
  static final navigator = GlobalKey<NavigatorState>();
}

class ElasticDrawer extends StatefulWidget {
  final Key key = ElasticDrawerKey.drawer;

  /// Color of main page
  final Color mainColor;

  /// Color of drawer page
  final Color drawerColor;

  /// Content inside main page
  final Widget mainChild;

  /// Content inside drawer page
  final Widget drawerChild;

  ElasticDrawer(
      {required this.mainChild,
      required this.drawerChild,
      this.mainColor = Colors.white,
      this.drawerColor = Colors.blue});

  @override
  _ElasticDrawerState createState() => _ElasticDrawerState();
}

class _ElasticDrawerState extends State<ElasticDrawer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  Offset? _touchPosition;
  bool _slideOn = false;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  closeElasticDrawer(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_animationController.isCompleted) {
      _touchPosition = Offset(size.width - 20.0, size.height / 2);
      _animationController.reverse().then((value) => {
            setState(() {
              _touchPosition = Offset(20.0, size.height / 2);
              _slideOn = false;
            })
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        SizedBox(
          width: size.width,
          height: size.height,
          child: Scaffold(
            backgroundColor: widget.mainColor,
            body: Navigator(
                key: ElasticDrawerKey.navigator,
                onGenerateRoute: (settings) =>
                    MaterialPageRoute(builder: (context) => widget.mainChild)),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: _slideOn ? size.width - 10.0 : 30.0,
            height: size.height,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return ClipPath(
                  clipper: _CustomClipper(
                      _touchPosition,
                      Tween(begin: 0.0, end: 1.0)
                          .animate(CurvedAnimation(
                              curve: Curves.elasticOut,
                              reverseCurve: Curves.elasticIn,
                              parent: _animationController))
                          .value),
                  child: Scaffold(
                      backgroundColor: widget.drawerColor,
                      body: _slideOn ? widget.drawerChild : Container()),
                );
              },
            ),
          ),
        ),
        Row(
          children: <Widget>[
            SlideTransition(
              position: Tween(begin: Offset(-1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(
                curve: Curves.linear,
                parent: _animationController,
              )),
              child: GestureDetector(
                onPanDown: (details) {
                  _touchPosition = details.globalPosition;
                  setState(() {});
                },
                onPanUpdate: (details) {
                  _touchPosition = details.globalPosition;
                  setState(() {});
                },
                onPanEnd: (details) {
                  _touchPosition = Offset(size.width - 20.0, size.height / 2);
                  _animationController.reverse().then((value) => {
                        setState(() {
                          _touchPosition = Offset(20.0, size.height / 2);
                          _slideOn = false;
                        })
                      });
                },
                child: Container(width: 20.0, color: Colors.transparent),
              ),
            ),
            Spacer(),
            SlideTransition(
              position: Tween(begin: Offset.zero, end: Offset(1, 0))
                  .animate(CurvedAnimation(
                curve: Curves.linear,
                parent: _animationController,
              )),
              child: GestureDetector(
                onPanDown: (details) {
                  _slideOn = true;
                  _touchPosition = details.globalPosition;
                  setState(() {});
                },
                onPanUpdate: (details) {
                  _touchPosition = details.globalPosition;
                  setState(() {});
                },
                onPanEnd: (details) {
                  _touchPosition = Offset(0.0, size.height / 2);
                  _animationController.forward();
                },
                child: Container(width: 20.0, color: Colors.transparent),
              ),
            )
          ],
        )
      ],
    );
  }
}

class _CustomClipper extends CustomClipper<Path> {
  Offset? _touchPosition;
  double _endPosition;

  _CustomClipper(this._touchPosition, this._endPosition);

  @override
  Path getClip(Size size) {
    if (_touchPosition == null) _touchPosition = Offset(20.0, size.height / 2);
    Path path = Path();
    path.moveTo(size.width - 10, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width - 10 - size.width * _endPosition, size.height);
    path.cubicTo(_touchPosition!.dx, _touchPosition!.dy, _touchPosition!.dx,
        _touchPosition!.dy, size.width - 10 - size.width * _endPosition, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_CustomClipper oldClipper) => true;
}
