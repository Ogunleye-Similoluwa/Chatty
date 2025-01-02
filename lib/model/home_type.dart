import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screen/feature/chatbot_feature.dart';
import '../screen/feature/image_feature.dart';
import '../screen/feature/translator_feature.dart';

enum HomeType { aiChatBot, aiImage, aiTranslator }

extension MyHomeType on HomeType {
  //title
  String get title => switch (this) {
        HomeType.aiChatBot => 'AI ChatBot',
        HomeType.aiImage => 'AI Image Creator',
        HomeType.aiTranslator => 'Language Translator',
      };

  //lottie
  String get animation => switch (this) {
        HomeType.aiChatBot => 'https://public.rive.app/community/files/2244-4437-ai-chatbot/main.riv',
        HomeType.aiImage => 'https://public.rive.app/community/files/2196-4348-ai-art-generation/main.riv',
        HomeType.aiTranslator => 'https://public.rive.app/community/files/1867-3678-translation/main.riv',
      };

  //for alignment
  bool get leftAlign => switch (this) {
        HomeType.aiChatBot => true,
        HomeType.aiImage => false,
        HomeType.aiTranslator => true,
      };

  //for padding
  EdgeInsets get padding => switch (this) {
        HomeType.aiChatBot => EdgeInsets.zero,
        HomeType.aiImage => const EdgeInsets.all(20),
        HomeType.aiTranslator => EdgeInsets.zero,
      };


  //for navigation
  VoidCallback get onTap => switch (this) {
        HomeType.aiChatBot => () => Get.to(() => const ChatBotFeature()),
        HomeType.aiImage => () => Get.to(() => const ImageFeature()),
        HomeType.aiTranslator => () => Get.to(() => const TranslatorFeature()),
      };

  String get fallbackAnimation => switch (this) {
        HomeType.aiChatBot => 'assets/rive/fallback/chatbot.riv',
        HomeType.aiImage => 'assets/rive/fallback/art.riv',
        HomeType.aiTranslator => 'assets/rive/fallback/translate.riv',
      };
}
