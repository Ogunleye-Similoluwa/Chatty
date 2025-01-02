import 'package:chatty/widget/cached_rive_animation.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomLoading extends StatelessWidget {
  const CustomLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 100,
      height: 100,
      child: CachedRiveAnimation(
        url: 'https://public.rive.app/community/files/2244-4437-ai-chatbot/loading.riv',
        fallbackAsset: 'assets/rive/fallback/loading.riv',
        placeholder: const CircularProgressIndicator(),
      ),
    );
  }
}
