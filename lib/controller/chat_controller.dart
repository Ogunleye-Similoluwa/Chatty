import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../apis/apis.dart';
import '../helper/my_dialog.dart';
import '../model/message.dart';

class ChatController extends GetxController {
  final textC = TextEditingController();

  final scrollC = ScrollController();

  final list = <Message>[
    Message(msg: 'Hello, How can I help you?', type: MessageType.bot)
  ].obs;

  Future<void> askQuestion() async {
    if (textC.text.trim().isNotEmpty) {
      //user
      list.add(Message(msg: textC.text, type: MessageType.user));
      list.add(Message(msg: '', type: MessageType.bot));
      _scrollDown();

      final res = await APIs.getAnswer(textC.text);

      //ai bot
      list.removeLast();
      list.add(Message(msg: res, type: MessageType.bot));
      _scrollDown();

      textC.text = '';
    } else {
      MyDialog.info('Ask Something!');
    }
  }

  //for moving to end message
  void _scrollDown() {
    scrollC.animateTo(scrollC.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }
}
