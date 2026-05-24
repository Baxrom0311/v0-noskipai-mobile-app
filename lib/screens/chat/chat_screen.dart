import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noskipai/config/app_theme.dart';
import 'package:noskipai/models/chat_message.dart';
import 'package:noskipai/providers/chat_provider.dart';
import 'package:noskipai/widgets/glassmorphic_container.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    Future.microtask(() => ref.read(chatProvider.notifier).fetchChatHistory());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Safety Signals',
            onPressed: () => context.push('/safety-signals'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      return _buildMessageBubble(message, index);
                    },
                  ),
          ),
          if (chatState.error != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: AppTheme.errorColor.withOpacity(0.1),
              child: Text(
                'Error: ${chatState.error}',
                style: TextStyle(color: AppTheme.errorColor, fontSize: 12),
              ),
            ),
          _buildMessageInput(chatState.isLoading),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.primaryColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('Start a conversation',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.textSecondaryColor)),
          const SizedBox(height: 8),
          Text(
            'Ask about medications, adherence tips,\nor get AI-powered health guidance',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) _buildAvatar(isUser),
              if (!isUser) const SizedBox(width: 8),
              Flexible(
                child: GlassmorphicContainer(
                  blur: 8,
                  opacity: isUser ? 0.3 : 0.1,
                  backgroundColor: isUser
                      ? AppTheme.primaryColor.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Safety level indicator
                      if (!isUser && message.safetyLevel != 'safe') _buildSafetyBadge(message.safetyLevel),
                      Text(message.content, style: Theme.of(context).textTheme.bodyMedium),
                      // Evidence cards
                      if (!isUser && message.evidenceCards.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...message.evidenceCards.map(_buildEvidenceCard),
                      ],
                      // Suggested actions
                      if (!isUser && message.suggestedActions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildSuggestedActions(message.suggestedActions),
                      ],
                    ],
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 8),
              if (isUser) _buildAvatar(isUser),
            ],
          ),
          // Feedback buttons for AI messages
          if (!isUser) _buildFeedbackRow(message, index),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (isUser ? AppTheme.accentColor : AppTheme.primaryColor).withOpacity(0.2),
      ),
      child: Icon(
        isUser ? Icons.person : Icons.auto_awesome,
        size: 16,
        color: isUser ? AppTheme.accentColor : AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildSafetyBadge(String level) {
    final color = _safetyColor(level);
    final label = level == 'critical' ? '⚠️ Critical' : level == 'warning' ? '⚠️ Warning' : '⚡ Caution';
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Color _safetyColor(String level) {
    switch (level) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'caution':
        return Colors.amber;
      default:
        return Colors.green;
    }
  }

  Widget _buildEvidenceCard(EvidenceCard card) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, size: 14, color: AppTheme.primaryColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  card.title,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(card.confidence * 100).toInt()}%',
                  style: TextStyle(fontSize: 10, color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(card.snippet, style: const TextStyle(fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(card.source.toUpperCase(), style: TextStyle(fontSize: 9, color: AppTheme.textSecondaryColor)),
        ],
      ),
    );
  }

  Widget _buildSuggestedActions(List<String> actions) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: actions.map((action) {
        return ActionChip(
          label: Text(action, style: const TextStyle(fontSize: 11)),
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          onPressed: () {
            _messageController.text = action;
          },
        );
      }).toList(),
    );
  }

  Widget _buildFeedbackRow(ChatMessage message, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFeedbackButton(
            icon: Icons.thumb_up_outlined,
            activeIcon: Icons.thumb_up,
            isActive: message.feedbackRating == 'up',
            onTap: () => ref.read(chatProvider.notifier).submitFeedback(index, 'up'),
          ),
          const SizedBox(width: 8),
          _buildFeedbackButton(
            icon: Icons.thumb_down_outlined,
            activeIcon: Icons.thumb_down,
            isActive: message.feedbackRating == 'down',
            onTap: () => ref.read(chatProvider.notifier).submitFeedback(index, 'down'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton({
    required IconData icon,
    required IconData activeIcon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          isActive ? activeIcon : icon,
          size: 16,
          color: isActive ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isLoading) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask me anything...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLines: null,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: isLoading ? null : (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send),
            onPressed: isLoading ? null : _sendMessage,
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final message = _messageController.text.trim();
    _messageController.clear();
    await ref.read(chatProvider.notifier).sendMessage(message);
    _scrollToBottom();
  }
}
