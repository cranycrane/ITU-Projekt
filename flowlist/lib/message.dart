class Message {
  final int messageId;
  final int fromUserId;
  final int toUserId;
  final String messageText;
  final String timestamp;
  final bool isRead;

  Message({
    required this.messageId,
    required this.fromUserId,
    required this.toUserId,
    required this.messageText,
    required this.timestamp,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageID'],
      fromUserId: json['fromUserID'],
      toUserId: json['toUserID'],
      messageText: json['messageText'],
      timestamp: json['timestamp'],
      isRead: json['isRead'] == 1,
    );
  }
}
