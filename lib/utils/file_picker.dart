import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

/// 让用户选**单个文件**；返回绝对路径或 null（取消）
Future<String?> pickSingleFile({
  List<String>? allowedExtensions, // 例 ['txt', 'json']
  String? dialogTitle, // 弹窗标题
}) async {
  final result = await FilePicker.platform.pickFiles(
    type: allowedExtensions == null ? FileType.any : FileType.custom,
    allowedExtensions: allowedExtensions,
    dialogTitle: dialogTitle ?? '请选择文件',
    allowMultiple: false, // 单选
    withData: false, // 只要路径，不要内容
  );

  if (result == null || result.files.isEmpty) return null;

  // 拿到绝对路径
  final path = result.files.single.path;
  return path == null ? null : p.absolute(path);
}
