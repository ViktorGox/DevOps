import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/song.dart';

class SongPage extends StatelessWidget {
  final Song song;

  const SongPage({super.key, required this.song});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(song.artist),
      ),
      body: Hero(
        tag: song.id,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: Text("${song.title} (${song.year})")),
            Center(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 300.0,
                    minWidth: 300.0,
                    maxWidth: max(MediaQuery.of(context).size.width / 4, 300.0),
                    maxHeight: max(MediaQuery.of(context).size.width / 4, 300.0),
                  ),
                  child: Image.network(song.imageUrl, width: MediaQuery.of(context).size.width)
              ),
            ),
          ],
        ),
      ),
    );
  }
}