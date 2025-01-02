import '../main.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../helper/global.dart';
import '../model/message.dart';

class MessageCard extends StatelessWidget {
  final Message message;

  const MessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.type == MessageType.user;

    return Padding(
      padding: EdgeInsets.only(bottom: mq.height * .02),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          
          Flexible(
            child: Container(
              padding: EdgeInsets.all(mq.width * .04),
              margin: EdgeInsets.only(
                left: isUser ? mq.width * .2 : 0,
                right: isUser ? 0 : mq.width * .2,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : isDark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15),
                  topRight: const Radius.circular(15),
                  bottomLeft: Radius.circular(isUser ? 15 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 15),
                ),
                border: Border.all(
                  color: isUser
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : Colors.transparent,
                ),
              ),
              child: Text(
                message.msg,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),

          if (isUser) _buildAvatar(),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.5, end: 0);
  }

  Widget _buildAvatar() {
    return Container(
      margin: EdgeInsets.only(
        left: message.type == MessageType.bot ? 0 : 8,
        right: message.type == MessageType.bot ? 8 : 0,
      ),
      child: CircleAvatar(
        backgroundColor: message.type == MessageType.bot
            ? Colors.blue.withOpacity(0.2)
            : Colors.green.withOpacity(0.2),
        child: Icon(
          message.type == MessageType.bot ? Icons.smart_toy : Icons.person,
          color: message.type == MessageType.bot ? Colors.blue : Colors.green,
        ),
      ),
    );
  }
}
