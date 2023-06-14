import 'package:flutter/material.dart';

class SmallText extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  double height;
  FontWeight weight;
  TextOverflow overFlow;
  int maxLines;
  double spacing;
  SmallText(
      {super.key,
      this.color = Colors.black,
      required this.text,
      this.size = 14,
      this.height = 1.2,
      this.weight = FontWeight.w500,
      this.overFlow = TextOverflow.clip,
      this.spacing = 0,
      this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overFlow,
      style: TextStyle(
          letterSpacing: spacing,
          color: color,
          fontSize: size,
          fontFamily: 'Metropolis',
          fontWeight: weight,
          height: height),
    );
  }
}
