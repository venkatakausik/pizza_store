import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pizza_store/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class CodToggleBar extends StatelessWidget {
  const CodToggleBar({super.key});

  @override
  Widget build(BuildContext context) {
    var _cartProvider = Provider.of<CartProvider>(context);
    return Container(
      color: Colors.white,
      child: ToggleSwitch(
        initialLabelIndex: 0,
        inactiveBgColor: Colors.grey,
        inactiveFgColor: Colors.grey[900],
        activeFgColor: Colors.white,
        activeBgColor: [Theme.of(context).primaryColor],
        labels: ["Pay online", "Cash on delivery"],
        totalSwitches: 2,
        onToggle: (index) {
          _cartProvider.getPaymentMethod(index);
        },
      ),
    );
  }
}
