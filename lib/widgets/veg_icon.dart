import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pizza_store/utils/dimensions.dart';

class VegIcon extends StatelessWidget {
  const VegIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.crop_square_sharp,
          color: Colors.green,
          size: Dimensions.iconSize24,
        ),
        Icon(Icons.circle, color: Colors.green, size: Dimensions.iconSize8),
      ],
    );
  }
}
