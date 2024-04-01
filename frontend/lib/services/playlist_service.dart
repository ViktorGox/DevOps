import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/song.dart';
import 'package:http/http.dart' as http;

class PlaylistService {

  Future<List<Song>> getPlaylist() async {
    final scheme = dotenv.env['SCHEME']!;
    final apiUrl = dotenv.env['API_URL']!;
    final uri = scheme == 'http' ? Uri.http(apiUrl, '/api/songs') : Uri.https(apiUrl, '/api/songs');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(response.statusCode);
    }

    return (jsonDecode(response.body) as List)
        .map((item) => Song.fromJson(item))
        .toList();
  }
}