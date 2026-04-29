class ChatMessage {
  final String id;
  final String userId;
  final String content;
  final String role; // 'user' or 'assistant'
  final double? riskScore;
  final List<String>? recommendations;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.content,
    required this.role,
    this.riskScore,
    this.recommendations,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      role: json['role'] as String,
      riskScore: (json['risk_score'] as num?)?.toDouble(),
      recommendations: json['recommendations'] != null
          ? List<String>.from(json['recommendations'] as List)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'role': role,
      'risk_score': riskScore,
      'recommendations': recommendations,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
