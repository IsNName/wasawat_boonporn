import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'movies_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Manager',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
        primaryColor: Colors.deepPurple,
      ),
      home: const MoviesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
