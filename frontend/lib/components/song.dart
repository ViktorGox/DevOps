import 'package:exam_frontend/models/song.dart';
import 'package:exam_frontend/pages/song.dart';
import 'package:flutter/material.dart';

class SongComponent extends StatelessWidget {
  final Song song;

  const SongComponent({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: song.id,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => SongPage(song: song))
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover image
              Flexible(
                flex: 5,
                child: SizedBox(
                  child: Image.network(song.imageUrl, fit: BoxFit.cover),
                ),
              ),
              // Song artist (bold)
              Flexible(
                child: Center(
                  child: Text(
                    song.artist,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
              // Song title
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Center(
                    child: Text(
                      song.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}