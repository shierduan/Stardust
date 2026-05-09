class MemoryItem {
  final String id;
  final String content;
  final DateTime timestamp;
  final double importance;
  final Map<String, dynamic>? metadata;
  final String? emotionContext;
  final List<double>? vector;

  const MemoryItem({
    required this.id,
    required this.content,
    required this.timestamp,
    this.importance = 0.5,
    this.metadata,
    this.emotionContext,
    this.vector,
  });

  bool get isHighImportance => importance > 0.7;
  bool get isMediumImportance => importance > 0.4 && importance <= 0.7;
  bool get isLowImportance => importance <= 0.4;

  String get importanceLabel {
    if (isHighImportance) return '重要';
    if (isMediumImportance) return '一般';
    return '琐碎';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  MemoryItem copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    double? importance,
    Map<String, dynamic>? metadata,
    String? emotionContext,
    List<double>? vector,
  }) {
    return MemoryItem(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      importance: importance ?? this.importance,
      metadata: metadata ?? this.metadata,
      emotionContext: emotionContext ?? this.emotionContext,
      vector: vector ?? this.vector,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'importance': importance,
    'metadata': metadata,
    'emotion_context': emotionContext,
    'vector': vector,
  };

  factory MemoryItem.fromJson(Map<String, dynamic> json) {
    return MemoryItem(
      id: json['id'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      importance: (json['importance'] as num?)?.toDouble() ?? 0.5,
      metadata: json['metadata'] as Map<String, dynamic>?,
      emotionContext: json['emotion_context'] as String?,
      vector: (json['vector'] as List?)?.cast<double>(),
    );
  }
}
