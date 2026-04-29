import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noskipai/services/api_service.dart';
import 'package:noskipai/models/chat_message.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ApiService apiService;

  ChatNotifier(this.apiService) : super(ChatState());

  Future<void> fetchChatHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await apiService.getChatHistory();
      final messages = (data as List)
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();
      
      state = state.copyWith(
        messages: messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendMessage(String content) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await apiService.sendChatMessage(content);
      final message = ChatMessage.fromJson(response);
      
      state = state.copyWith(
        messages: [...state.messages, message],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ChatNotifier(apiService);
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
