import 'package:flutter/material.dart';
import '../data/chat_db.dart';
import '../model/message.dart';
import 'package:error22_einval/error22_einval.dart' as error22_einval;

class ChatProvider extends ChangeNotifier {
  final ChatDb _db = ChatDb();
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _hasMore = true;
  final int _pageSize = 20;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  /* 第一次进入：加载最新一页 */
  Future<void> loadInitial() async {
    _messages.clear();
    _hasMore = true;
    await _loadPage(0);
  }

  /* 懒加载：offset = 当前已有条数 */
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    await _loadPage(_messages.length);
  }

  Future<void> _loadPage(int offset) async {
    _isLoading = true;
    notifyListeners();
    try {
      final list = await _db.loadHistory(limit: _pageSize, offset: offset);
      if (list.length < _pageSize) _hasMore = false;
      _messages.insertAll(
        0,
        list.map((e) => Message.fromTable(e)).toList(),
      ); // 插到前面
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* 发送用户消息 + AI 回复 */
  Future<void> send(String text) async {
    // 1. 落库
    final userId = await _db.insertMessage(text, true);
    final userMsg = Message(
      id: userId,
      content: text,
      timestamp: DateTime.now(),
      isUser: true,
    );
    _messages.add(userMsg);

    // 2. 假装网络请求（留空）
    await _AiRequest(text);

    notifyListeners();
  }

  /* ============ 网络请求函数留空 ============= */
  Future<void> _AiRequest(String userText) async {
    // TODO: 调用模型 API,或者web服务器，返回结果

    error22_einval.sumAsync(2, 3);
    final aiText = 'AI:$userText';
    final aiId = await _db.insertMessage(aiText, false);
    final aiMsg = Message(
      id: aiId,
      content: aiText,
      timestamp: DateTime.now(),
      isUser: false,
    );
    _messages.add(aiMsg);
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  Future<void> removeMessage(int id) async {
    await _db.deleteMessage(id);
    _messages.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  /* 批删 */
  Future<void> removeMessages(List<int> ids) async {
    await _db.deleteMessages(ids);
    _messages.removeWhere((m) => ids.contains(m.id));
    notifyListeners();
  }

  /* 清空 */
  Future<void> clearHistory() async {
    await _db.clearAllMessages();
    _messages.clear();
    notifyListeners();
  }
}
