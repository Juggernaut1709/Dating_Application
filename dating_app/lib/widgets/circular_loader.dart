import 'package:flutter/material.dart';

class CircularLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const CircularLoader({
    Key? key,
    this.size = 24.0,
    this.color = Colors.indigoAccent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
