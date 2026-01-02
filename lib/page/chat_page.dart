import 'package:error22_einval_main/model/message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/chat_provider.dart';
import '../utils/file_picker.dart';
import 'package:error22_einval/error22_einval.dart' as error22_einval;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _ctrl = ScrollController();
  final TextEditingController _textCtrl = TextEditingController();
  late ChatProvider _provider;

  /* 监听滑到顶部触发懒加载 */
  void _scrollListener() {
    if (_ctrl.position.pixels <= _ctrl.position.minScrollExtent + 100 &&
        !_provider.isLoading) {
      _provider.loadMore();
    }
  }

  @override
  void initState() {
    super.initState();
    _provider = context.read<ChatProvider>();
    _ctrl.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadInitial().then((_) => _jumpToBottom());
    });
  }

  void _jumpToBottom() {
    if (_ctrl.hasClients) {
      _ctrl.animateTo(
        _ctrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 对话'),
        actions: [
          IconButton(
            icon: const Icon(Icons.vertical_align_bottom),
            onPressed: _jumpToBottom,
            tooltip: '回到最新',
          ),
        ],
      ),
      body: Column(
        children: [
          /* ========== 消息列表 ========== */
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (_, p, __) {
                if (p.messages.isEmpty && p.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 如果消息为空，显示背景图标
                if (p.messages.isEmpty && !p.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_nature,
                          size: 100,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '开始与AI对话',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Stack(
                  children: [
                    ListView.builder(
                      controller: _ctrl,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount:
                          p.messages.length +
                          (p.hasMore && p.isLoading ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i >= p.messages.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final m = p.messages[i];
                        return _bubble(m);
                      },
                    ),
                    // 添加一个浮动的AI图标在右下角
                    if (p.messages.isNotEmpty)
                      Positioned(
                        bottom: 20.0,
                        right: 20.0,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.psychology,
                            size: 30,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          /* ========== 功能按钮区域 ========== */
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(width: 1, color: Colors.grey)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final path = await pickSingleFile(
                        allowedExtensions: ['onnx'],
                      );
                      if (path == null) return;
                      debugPrint('用户选了：$path');
                      error22_einval.loadModel(path);
                      //todo load model
                    },
                    icon: const Icon(Icons.attach_file),
                    label: const Text('选择模型文件'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      //clear history
                      _provider.clearHistory().then((_) => _jumpToBottom());
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('清空历史'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /* ========== 输入栏 ========== */
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(width: 1, color: Colors.grey)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintText: '输入消息…',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _send,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();
    _provider.send(text).then((_) => _jumpToBottom());
  }

  Widget _bubble(Message m) {
    final isMe = m.isUser;
    return GestureDetector(
      // ← 1. 手势监听
      onLongPress: () => _showMsgMenu(context, m.id!, m.content), // ← 2. 长按弹菜单
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            m.content,
            style: TextStyle(color: isMe ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}

void _showMsgMenu(BuildContext ctx, int id, String content) {
  showMenu<int>(
    context: ctx,
    position: const RelativeRect.fromLTRB(0, 0, 0, 0), // 自动跟随长按位置
    items: [
      PopupMenuItem(
        value: 0,
        child: const Text('删除'),
        onTap: () => ctx.read<ChatProvider>().removeMessage(id),
      ),
    ],
  );
}
