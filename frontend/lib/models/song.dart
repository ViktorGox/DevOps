import 'package:json_annotation/json_annotation.dart';
part 'song.g.dart';

@JsonSerializable()
class Song {
  final int id;
  final String artist;
  final String title;
  final int year;
  final String imageUrl;

  Song({
    this.id = 1,
    this.artist = '',
    this.title = '',
    this.year = 1900,
    this.imageUrl = ''
  });

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
  Map<String, dynamic> toJson() => _$SongToJson(this);
}