import 'package:exam_frontend/components/loading.dart';
import 'package:exam_frontend/components/song.dart';
import 'package:exam_frontend/services/playlist_service.dart';
import 'package:flutter/material.dart';

import '../components/error.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PlaylistService().getPlaylist(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingComponent();
        }

        if (snapshot.hasError) {
          return ErrorComponent(error: snapshot.error.toString());
        }

        if (snapshot.hasData) {
          var playlist = snapshot.data!;
          return GridView.count(
            padding: const EdgeInsets.all(40.0),
            mainAxisSpacing: 20.0,
            crossAxisSpacing: 20.0,
            crossAxisCount: MediaQuery.of(context).size.width ~/ 250,
            children: playlist.map((song) => SongComponent(song: song)).toList(),
          );
        }

        return const Text('No data loaded. Check backend.');
      }
    );
  }
}
