class EvidenceCard {
  final String source;
  final String title;
  final String snippet;
  final String? url;
  final double confidence;

  EvidenceCard({
    required this.source,
    required this.title,
    required this.snippet,
    this.url,
    this.confidence = 0.8,
  });

  factory EvidenceCard.fromJson(Map<String, dynamic> json) {
    return EvidenceCard(
      source: json['source'] as String? ?? '',
      title: json['title'] as String? ?? '',
      snippet: json['snippet'] as String? ?? '',
      url: json['url'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8,
    );
  }
}

class ChatMessage {
  final String? id;
  final String content;
  final String role;
  final String? intent;
  final String safetyLevel;
  final bool riskFlag;
  final List<EvidenceCard> evidenceCards;
  final List<String> suggestedActions;
  final DateTime? createdAt;
  // Feedback state (local only)
  String? feedbackRating; // 'up' | 'down' | null

  ChatMessage({
    this.id,
    required this.content,
    required this.role,
    this.intent,
    this.safetyLevel = 'safe',
    this.riskFlag = false,
    this.evidenceCards = const [],
    this.suggestedActions = const [],
    this.createdAt,
    this.feedbackRating,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString(),
      content: json['content'] as String? ?? json['reply'] as String? ?? '',
      role: json['role'] as String? ?? 'assistant',
      intent: json['intent'] as String?,
      safetyLevel: json['safety_level'] as String? ?? 'safe',
      riskFlag: json['risk_flag'] as bool? ?? false,
      evidenceCards: (json['evidence_cards'] as List?)
              ?.map((e) => EvidenceCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      suggestedActions: (json['suggested_actions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['timestamp'] != null || json['created_at'] != null
          ? DateTime.tryParse((json['timestamp'] ?? json['created_at']) as String)
          : null,
    );
  }

  /// Parse the structured AI chat response (from /ai/chat endpoint)
  factory ChatMessage.fromAIResponse(Map<String, dynamic> data) {
    return ChatMessage(
      content: data['reply'] as String? ?? '',
      role: 'assistant',
      intent: data['intent'] as String?,
      safetyLevel: data['safety_level'] as String? ?? 'safe',
      riskFlag: data['risk_flag'] as bool? ?? false,
      evidenceCards: (data['evidence_cards'] as List?)
              ?.map((e) => EvidenceCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      suggestedActions: (data['suggested_actions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: DateTime.now(),
    );
  }
}
