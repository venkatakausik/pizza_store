import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pizza_store/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class CodToggleBar extends StatefulWidget {
  const CodToggleBar({super.key});

  @override
  State<CodToggleBar> createState() => _CodToggleBarState();
}

class _CodToggleBarState extends State<CodToggleBar> {
  int? selectedIndex = 1;
  @override
  Widget build(BuildContext context) {
    var _cartProvider = Provider.of<CartProvider>(context);
    return ToggleSwitch(
      multiLineText: true,
      minWidth: 100,
      initialLabelIndex: selectedIndex,
      inactiveBgColor: Colors.grey,
      inactiveFgColor: Colors.white,
      activeFgColor: Colors.white,
      activeBgColor: [Theme.of(context).primaryColor],
      labels: ["Pay online", "Cash on delivery"],
      totalSwitches: 2,
      onToggle: (index) {
        setState(() {
          selectedIndex = index;
        });
        _cartProvider.getPaymentMethod(index);
      },
    );
  }
}
