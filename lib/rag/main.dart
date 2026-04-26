// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_rag_app_poc/rag/home_screen.dart';
// import 'package:flutter_rag_app_poc/rag/rag_provider.dart';
// import 'package:provider/provider.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//       systemNavigationBarColor: Color(0xFF0A0E1A),
//     ),
//   );
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => RAGProvider(),
//       child: const AIEdgeRAGApp(),
//     ),
//   );
// }

// class AIEdgeRAGApp extends StatelessWidget {
//   const AIEdgeRAGApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'AI Edge RAG',
//       debugShowCheckedModeBanner: false,
//       theme: _buildTheme(),
//       home: const HomeScreen(),
//     );
//   }

//   ThemeData _buildTheme() {
//     return ThemeData(
//       brightness: Brightness.dark,
//       scaffoldBackgroundColor: const Color(0xFF0A0E1A),
//       colorScheme: const ColorScheme.dark(
//         primary: Color(0xFF00D4FF),
//         secondary: Color(0xFF7C3AED),
//         surface: Color(0xFF111827),
//         error: Color(0xFFEF4444),
//       ),
//       useMaterial3: true,
//     );
//   }
// }
