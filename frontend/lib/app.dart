import 'package:exam_frontend/pages/home.dart';
import 'package:flutter/material.dart';

class PlaylistApp extends StatelessWidget {
  final String title;

  const PlaylistApp({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      builder: (context, _) =>
          Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              iconTheme: const IconThemeData(color: Colors.black),
              title: const Text('Playlist with the best songs!'),
            ),
            body: Navigator(
                onGenerateRoute: (route) {
                  if (route.name == '/') return MaterialPageRoute(builder: (_) => const HomePage());
                  return null;
                },
            ),
          ),
    );
  }
}