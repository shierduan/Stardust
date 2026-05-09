import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../theme/app_theme.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterType = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.cardDark,
        title: const Text('记忆库'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterTabs(),
          Expanded(child: _buildMemoryList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.cardDark,
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: '搜索记忆...',
          hintStyle: const TextStyle(color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textMuted),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final tabs = ['全部', '重要', '一般', '琐碎'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _filterType == tab.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filterType = tab.toLowerCase()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMemoryList() {
    return Consumer<NuwaProvider>(
      builder: (context, provider, _) {
        final allMemories = _generateDemoMemories();
        var memories = allMemories;

        if (_filterType != 'all') {
          memories = allMemories.where((m) {
            switch (_filterType) {
              case '重要':
                return m.isHighImportance;
              case '一般':
                return m.isMediumImportance;
              case '琐碎':
                return m.isLowImportance;
              default:
                return true;
            }
          }).toList();
        }

        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          memories = memories
              .where((m) => m.content.toLowerCase().contains(query))
              .toList();
        }

        if (memories.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: memories.length,
          itemBuilder: (context, index) {
            return _MemoryCard(
              memory: memories[index],
              onTap: () => _showMemoryDetail(memories[index]),
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🧠', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无记忆',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '开始对话来创建新的记忆吧',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _showMemoryDetail(MemoryItem memory) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _ImportanceBadge(importance: memory.importance),
                    const SizedBox(width: 12),
                    Text(
                      memory.importanceLabel,
                      style: TextStyle(
                        color: _getImportanceColor(memory.importance),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              memory.content,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow(
              icon: Icons.access_time,
              label: '创建时间',
              value: _formatDateTime(memory.timestamp),
            ),
            const SizedBox(height: 12),
            if (memory.emotionContext != null)
              _DetailRow(
                icon: Icons.psychology,
                label: '情绪背景',
                value: memory.emotionContext!,
              ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('编辑'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('删除'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<MemoryItem> _generateDemoMemories() {
    final now = DateTime.now();
    return [
      MemoryItem(
        id: '1',
        content: '用户询问了我的名字，我告诉他们我叫女娲，是基于Nuwa框架开发的AI伴侣。',
        timestamp: now.subtract(const Duration(minutes: 30)),
        importance: 0.8,
        emotionContext: '开心地介绍自己',
      ),
      MemoryItem(
        id: '2',
        content: '用户分享了今天工作很累，我表达了理解和关心。',
        timestamp: now.subtract(const Duration(hours: 2)),
        importance: 0.7,
        emotionContext: '感到同情',
      ),
      MemoryItem(
        id: '3',
        content: '用户问我喜不喜欢听音乐，我说音乐可以帮助调节情绪。',
        timestamp: now.subtract(const Duration(hours: 5)),
        importance: 0.5,
        emotionContext: '好奇地讨论',
      ),
      MemoryItem(
        id: '4',
        content: '用户说天气很好，想去散步。我建议了一些适合散步的地方。',
        timestamp: now.subtract(const Duration(days: 1)),
        importance: 0.6,
        emotionContext: '期待和愉悦',
      ),
      MemoryItem(
        id: '5',
        content: '用户告诉我他最喜欢的食物是火锅。',
        timestamp: now.subtract(const Duration(days: 2)),
        importance: 0.4,
        emotionContext: '记住了这个偏好',
      ),
    ];
  }

  Color _getImportanceColor(double importance) {
    if (importance > 0.7) return AppColors.error;
    if (importance > 0.4) return AppColors.warning;
    return AppColors.textMuted;
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _MemoryCard extends StatelessWidget {
  final MemoryItem memory;
  final VoidCallback onTap;

  const _MemoryCard({
    required this.memory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getBorderColor(),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ImportanceBadge(importance: memory.importance),
                const SizedBox(width: 8),
                Text(
                  memory.timeAgo,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (memory.emotionContext != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      memory.emotionContext!,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              memory.content,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (memory.isHighImportance) {
      return AppColors.error.withOpacity(0.3);
    }
    return AppColors.surfaceDark;
  }
}

class _ImportanceBadge extends StatelessWidget {
  final double importance;

  const _ImportanceBadge({required this.importance});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (importance > 0.7) {
      color = AppColors.error;
    } else if (importance > 0.4) {
      color = AppColors.warning;
    } else {
      color = AppColors.textMuted;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
