enum MessageType { user, bot }

class Message {
  final String msg;
  final MessageType type;

  Message({
    required this.msg,
    required this.type,
  });
}