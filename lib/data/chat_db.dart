import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'chat_db.g.dart';

class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  IntColumn get timestamp =>
      integer().withDefault(Constant(DateTime.now().millisecondsSinceEpoch))();
  BoolColumn get isUser => boolean()(); // true=用户 false=AI
}

@DriftDatabase(tables: [ChatMessages])
class ChatDb extends _$ChatDb {
  ChatDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'chat.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  /* ========== 留出的读取历史函数 ========== */
  Future<List<ChatMessage>> loadHistory({
    required int limit,
    required int offset,
  }) async {
    return (select(chatMessages)
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)])
          ..limit(limit, offset: offset))
        .get();
  }

  /* ========== 新增一条消息 ========== */
  Future<int> insertMessage(String content, bool isUser) async {
    return into(
      chatMessages,
    ).insert(ChatMessagesCompanion.insert(content: content, isUser: isUser));
  }

  /* ============== 单条删除 ============== */
  Future<int> deleteMessage(int id) =>
      (delete(chatMessages)..where((t) => t.id.equals(id))).go();

  /* ============== 批量删除 ============== */
  Future<int> deleteMessages(List<int> ids) =>
      (delete(chatMessages)..where((t) => t.id.isIn(ids))).go();

  /* ============== 清空全部 ============== */
  Future<int> clearAllMessages() => delete(chatMessages).go();
}
