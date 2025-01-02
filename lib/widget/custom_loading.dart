import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class CustomLoading extends StatelessWidget {
  const CustomLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 100,
      height: 100,
      child: RiveAnimation.asset(
        'assets/rive/loading.riv',
        fit: BoxFit.contain,
      ),
    );
  }
}
