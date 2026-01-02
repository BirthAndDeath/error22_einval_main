import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/chat_provider.dart';
import 'page/chat_page.dart';
import 'dart:async';

import 'package:error22_einval/error22_einval.dart' as error22_einval;

void main() {
  error22_einval.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FFI + Chat Demo',
      theme: ThemeData(fontFamily: 'MyFont', useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(), // FFI 演示页
        '/chat': (_) => ChangeNotifierProvider(
          create: (_) => ChatProvider(),
          child: const ChatPage(),
        ),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int sumResult;
  late Future<int> sumAsyncResult;

  @override
  void initState() {
    super.initState();
    sumResult = error22_einval.sum(1, 2);
    sumAsyncResult = error22_einval.sumAsync(3, 4);
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);

    return Scaffold(
      appBar: AppBar(title: const Text('Native Packages')),
      body: SingleChildScrollView(
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
            FutureBuilder<int>(
              future: sumAsyncResult,
              builder: (_, snap) => Text(
                'await sumAsync(3, 4) = ${snap.hasData ? snap.data : 'loading'}',
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ),
            spacerSmall,
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/chat'),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('AI chat测试'),
            ),
          ],
        ),
      ),
    );
  }
}
