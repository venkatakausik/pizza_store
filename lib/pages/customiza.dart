import 'package:flutter/material.dart';
import 'package:pizza_store/widgets/small_text.dart';

class CustomizePage extends StatelessWidget {
  const CustomizePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [SmallText(text: "Customize Page")],
        ),
      ),
    );
  }
}
