import './providers/tts_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/router.dart';
import 'models/fragment_models/document_fragment.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';


Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DocumentFragmentAdapter());
  await Hive.openBox<DocumentFragment>('fragments');

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TtsProvider()),
      ],
      child: ChatApp(),
    ),
  );
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Deepseek Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

