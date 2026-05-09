import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../../core/services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.cardDark,
      title: Consumer<NuwaProvider>(
        builder: (context, provider, _) {
          return Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: AppColors.gradientPrimary,
                  ),
                ),
                child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.config.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    provider.isConnected ? '在线' : '离线',
                    style: TextStyle(
                      fontSize: 12,
                      color: provider.isConnected
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.psychology_outlined),
          onPressed: () => _showEmotionPanel(),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: _clearChat,
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return Consumer<NuwaProvider>(
      builder: (context, provider, _) {
        final messages = provider.messages;

        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return ChatBubble(
              message: message,
              showThought: provider.config.showThoughtBubble,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceDark,
            ),
            child: const Center(
              child: Text('💬', style: TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '开始一段新的对话',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '在这里与女娲分享你的想法吧',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 32),
          _buildQuickReplies(),
        ],
      ),
    );
  }

  Widget _buildQuickReplies() {
    final quickReplies = [
      '你好呀',
      '今天心情怎么样？',
      '你在想什么？',
      '讲个故事吧',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: quickReplies.map((reply) {
        return GestureDetector(
          onTap: () {
            _inputController.text = reply;
            _sendMessage();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              reply,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _focusNode,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '输入消息...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceDark,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isTyping ? null : _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isTyping
                      ? [AppColors.textMuted, AppColors.textMuted]
                      : AppColors.gradientPrimary,
                ),
                shape: BoxShape.circle,
                boxShadow: _isTyping
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: _isTyping
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isTyping) return;

    _inputController.clear();
    setState(() => _isTyping = true);

    final provider = context.read<NuwaProvider>();
    final configProvider = context.read<AppConfigProvider>();

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    provider.addMessage(userMessage);

    final loadingMessage = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_loading',
      content: '思考中...',
      isUser: false,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );
    provider.addMessage(loadingMessage);

    _scrollToBottom();

    try {
      final apiService = ApiService.fromConfig(configProvider.config);
      final result = await apiService.processInput(
        userInput: text,
        currentState: provider.state,
        retrievedMemories: provider.recentMemories,
      );

      provider.updateMessage(loadingMessage.id,
          loadingMessage.copyWith(status: MessageStatus.sent));

      if (result != null) {
        final reply = result['reply'] as String? ?? '抱歉，我现在无法回应。';
        final thought = result['thought'] as String?;

        final assistantMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: reply,
          isUser: false,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
          thought: thought,
        );

        provider.updateMessage(
            loadingMessage.id,
            assistantMessage.copyWith(
              content: reply,
            ));

        _simulateStateUpdate(provider);
      } else {
        provider.updateMessage(
          loadingMessage.id,
          loadingMessage.copyWith(
            content: '抱歉，无法连接到服务器。请检查设置中的服务器配置。',
            status: MessageStatus.error,
          ),
        );
      }
    } catch (e) {
      provider.updateMessage(
        loadingMessage.id,
        loadingMessage.copyWith(
          content: '发生错误: $e',
          status: MessageStatus.error,
        ),
      );
    } finally {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _simulateStateUpdate(NuwaProvider provider) {
    final emotionUpdates = <String, double>{};
    final emotions = EmotionalSpectrum.emotions;
    for (var emotion in emotions) {
      final current = provider.emotionalSpectrum[emotion];
      final delta = (0.1 - (current - 0.5).abs() * 0.1);
      emotionUpdates[emotion] = (current + delta).clamp(0.3, 0.7);
    }
    provider.updateEmotionalSpectrum(emotionUpdates);

    provider.updateBioRhythm(
      energy: (provider.bioRhythm.energy - 0.02).clamp(0.0, 1.0),
      social: (provider.bioRhythm.social + 0.05).clamp(0.0, 1.0),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text(
          '清空对话',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '确定要清空所有对话记录吗？',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<NuwaProvider>().clearMessages();
              Navigator.pop(context);
            },
            child: const Text(
              '确定',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmotionPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 350,
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Consumer<NuwaProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '当前状态',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BioRhythmIndicator(
                  bioRhythm: provider.bioRhythm,
                  compact: true,
                ),
                const SizedBox(height: 20),
                const Text(
                  '主要情绪',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                EmotionBarList(
                  emotionalSpectrum: provider.emotionalSpectrum,
                  maxDisplay: 4,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
