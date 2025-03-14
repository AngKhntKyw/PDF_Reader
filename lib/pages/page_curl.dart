import 'package:flutter/material.dart';

class RealisticPageCurlDemo extends StatefulWidget {
  @override
  _RealisticPageCurlDemoState createState() => _RealisticPageCurlDemoState();
}

class _RealisticPageCurlDemoState extends State<RealisticPageCurlDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _startAnimation() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Realistic Page Curling Effect')),
      body: Center(
        child: GestureDetector(
          onTap: _startAnimation,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Background Page
                  Container(
                    width: 300,
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Background Page',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),

                  // Curling Page
                  Transform(
                    alignment: Alignment.topLeft,
                    transform:
                        Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // Perspective
                          ..rotateX(_animation.value * -0.5) // Tilt the page
                          ..rotateY(_animation.value * 1.5), // Curl the page
                    child: ClipPath(
                      clipper: PageCurlClipper(_animation.value),
                      child: Container(
                        width: 300,
                        height: 400,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: Offset(5, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Curling Page',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class PageCurlClipper extends CustomClipper<Path> {
  final double animationValue;

  PageCurlClipper(this.animationValue);

  @override
  Path getClip(Size size) {
    final path = Path();
    final curlHeight = size.height * animationValue;

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - curlHeight);
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height,
      size.width * 0.5,
      size.height - curlHeight * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height - curlHeight,
      0,
      size.height - curlHeight,
    );
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
