class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;
  final String? thought;
  final Map<String, dynamic>? skillResult;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.thought,
    this.skillResult,
  });

  bool get isSent => status == MessageStatus.sent;
  bool get isSending => status == MessageStatus.sending;
  bool get isError => status == MessageStatus.error;

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageStatus? status,
    String? thought,
    Map<String, dynamic>? skillResult,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      thought: thought ?? this.thought,
      skillResult: skillResult ?? this.skillResult,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'is_user': isUser,
    'timestamp': timestamp.toIso8601String(),
    'status': status.name,
    'thought': thought,
    'skill_result': skillResult,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['is_user'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: MessageStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      thought: json['thought'] as String?,
      skillResult: json['skill_result'] as Map<String, dynamic>?,
    );
  }
}

enum MessageStatus {
  sending,
  sent,
  error,
}
