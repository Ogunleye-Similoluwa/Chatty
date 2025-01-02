import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screen/feature/chatbot_feature.dart';
import '../screen/feature/image_feature.dart';
import '../screen/feature/translator_feature.dart';

enum HomeType { 
  aiChatBot, 
  aiImage, 
  aiTranslator,
  imageAnalysis,
  faceDetection,
  textScanner,
  voiceTranslator
}

extension HomeTypeExtension on HomeType {
  String get name => switch (this) {
    HomeType.aiChatBot => 'AI ChatBot',
    HomeType.aiImage => 'AI Art',
    HomeType.aiTranslator => 'AI Translator',
    HomeType.imageAnalysis => 'Image Analysis',
    HomeType.faceDetection => 'Face Detection',
    HomeType.textScanner => 'Text Scanner',
    HomeType.voiceTranslator => 'Voice Translator',
  };

  String get lottie => switch (this) {
    HomeType.aiChatBot => 'assets/lottie/animation1.json',
    HomeType.aiImage => 'assets/lottie/animation2.json',
    HomeType.aiTranslator => 'assets/lottie/animation3.json',
    HomeType.imageAnalysis => 'assets/lottie/animation4.json',
    HomeType.faceDetection => 'assets/lottie/animation9.json',
    HomeType.textScanner => 'assets/lottie/animation7.json',
    HomeType.voiceTranslator => 'assets/lottie/animation8.json',
  };

  // Add default navigation
  VoidCallback get defaultNavigation => switch (this) {
    HomeType.aiChatBot => () => Get.to(() => const ChatBotFeature()),
    HomeType.aiImage => () => Get.to(() => const ImageFeature()),
    HomeType.aiTranslator => () => Get.to(() => const TranslatorFeature()),
    _ => () {}, // Default empty callback for other types
  };
}
