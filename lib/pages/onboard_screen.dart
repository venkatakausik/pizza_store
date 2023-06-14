import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pizza_store/widgets/small_text.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

final _controller = PageController(
  initialPage: 0,
);

List<Widget> _pages = [
  Container(
    color: Colors.white,
    child: Column(
      children: [
        Expanded(child: Image.asset("assets/images/cat-0.png")),
        SmallText(
          text: "Set your delivery location",
          color: Colors.black,
        ),
      ],
    ),
  ),
];

class _OnBoardScreenState extends State<OnBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _controller,
            children: _pages,
          ),
        ),
      ],
    );
  }
}
