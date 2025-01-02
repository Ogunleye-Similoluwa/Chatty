import '../../main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/chat_controller.dart';
import '../../helper/global.dart';
import '../../widget/message_card.dart';

class ChatBotFeature extends StatefulWidget {
  const ChatBotFeature({super.key});

  @override
  State<ChatBotFeature> createState() => _ChatBotFeatureState();
}

class _ChatBotFeatureState extends State<ChatBotFeature> {
  final _c = ChatController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Chat with Chatty',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Theme.of(context).primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.white : Theme.of(context).primaryColor,
            ),
            onPressed: () {
              _c.list.clear();
              _c.textC.clear();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: Obx(
              () => ListView(
                physics: const BouncingScrollPhysics(),
                controller: _c.scrollC,
                padding: EdgeInsets.only(
                  top: mq.height * .02,
                  bottom: mq.height * .1,
                  left: mq.width * .04,
                  right: mq.width * .04,
                ),
                children: _c.list.map((e) => MessageCard(message: e)).toList(),
              ),
            ),
          ),

          // Bottom Input Area
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: mq.width * .04,
              vertical: mq.height * .015,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Text Input
                Expanded(
                  child: TextFormField(
                    controller: _c.textC,
                    minLines: 1,
                    maxLines: 3,
                    onTapOutside: (e) => FocusScope.of(context).unfocus(),
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      isDense: true,
                      fillColor: isDark 
                          ? Colors.grey[800] 
                          : Colors.grey[100],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                // Send Button
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _c.askQuestion,
                    icon: const Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
