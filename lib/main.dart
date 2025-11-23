import 'package:flutter/material.dart';
import 'dart:async';

import 'package:error22_einval/error22_einval.dart' as error22_einval;

/// 应用程序入口点
void main() {
  error22_einval.init();
  runApp(const MyApp());
}

/// MyApp类是应用程序的根组件
/// 继承自StatefulWidget，表示这是一个有状态的组件
class MyApp extends StatefulWidget {
  /// 构造函数，使用super.key初始化键值
  const MyApp({super.key});

  /// 创建并返回与该widget关联的State对象
  @override
  State<MyApp> createState() => _MyAppState();
}

/// _MyAppState类是MyApp widget的状态管理类
class _MyAppState extends State<MyApp> {
  /// 存储同步计算结果的变量
  late int sumResult;

  /// 存储异步计算结果的Future变量
  late Future<int> sumAsyncResult;

  /// 初始化状态，在widget插入树时调用
  @override
  void initState() {
    super.initState();
    // 调用原生方法进行同步加法运算
    sumResult = error22_einval.sum(1, 2);
    // 调用原生方法进行异步加法运算
    sumAsyncResult = error22_einval.sumAsync(3, 4);
  }

  /// 构建widget的UI界面
  @override
  Widget build(BuildContext context) {
    // 定义文本样式
    const textStyle = TextStyle(fontSize: 25);
    // 定义小间距组件
    const spacerSmall = SizedBox(height: 10);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Native Packages')),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'This calls a native function through FFI that is shipped as source in the package. '
                  'The native code is built as part of the Flutter Runner build.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                Text(
                  'sum(1, 2) = $sumResult',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                // 使用FutureBuilder处理异步结果展示
                FutureBuilder<int>(
                  future: sumAsyncResult,
                  builder: (BuildContext context, AsyncSnapshot<int> value) {
                    // 根据异步结果是否准备好来决定显示内容
                    final displayValue = (value.hasData)
                        ? value.data
                        : 'loading';
                    return Text(
                      'await sumAsync(3, 4) = $displayValue',
                      style: textStyle,
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
