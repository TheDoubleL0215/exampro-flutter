import 'package:exam_flutter/pages/HomePage.dart';
import 'package:exam_flutter/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures bindings are ready for async tasks
  await DatabaseService.instance.database; // Initialize the database
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'GB'), // British English
        Locale('en', 'US'), // American English
        Locale('de', 'DE'), // German
        // Add other locales if needed
      ],
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        fontFamily: 'ProductSans',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      darkTheme: ThemeData(
        fontFamily: 'ProductSans',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark, seedColor: Colors.blueAccent),
      ),
      home: HomePage(),
    );
  }
}
