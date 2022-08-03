import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget phoneBody;
  final Widget webBody;

  const ResponsiveLayout(
      {Key? key, required this.phoneBody, required this.webBody})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if(constraints.maxWidth < 500) {
          return phoneBody;
        } else {
          return webBody;
        }
      },
    );
  }
}
