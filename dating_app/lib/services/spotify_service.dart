import 'dart:convert';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

final dio = Dio();

class SpotifyService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final String clientId = "a2432d604dea4155aede9194512e9b46";
  final String redirectUri = "mydatingapp://spotify-auth";
  final List<String> scopes = [];

  String? _accessToken;
  String? _refreshToken;

  Future<bool> init() async {
    _accessToken = await _secureStorage.read(key: "spotify_access_token");
    _refreshToken = await _secureStorage.read(key: "spotify_refresh_token");
    return _accessToken != null;
  }

  Future<bool> login() async {
    try {
      final AuthorizationTokenResponse? result = await _appAuth
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              clientId,
              redirectUri,
              scopes: scopes,
              serviceConfiguration: const AuthorizationServiceConfiguration(
                authorizationEndpoint: "https://accounts.spotify.com/authorize",
                tokenEndpoint: "https://accounts.spotify.com/api/token",
              ),
            ),
          );

      if (result != null) {
        _accessToken = result.accessToken;
        _refreshToken = result.refreshToken;

        await _secureStorage.write(
          key: "spotify_access_token",
          value: _accessToken,
        );
        await _secureStorage.write(
          key: "spotify_refresh_token",
          value: _refreshToken,
        );

        return true;
      }
      return false;
    } catch (e) {
      print("Spotify login error: $e");
      return false;
    }
  }

  Future<List<Map<String, String>>> searchSongs(String query) async {
    if (_accessToken == null) return [];

    final response = await dio.get(
      "https://api.spotify.com/v1/search?q=$query&type=track&limit=20",
      options: Options(headers: {"Authorization": "Bearer $_accessToken"}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data);
      final List<Map<String, String>> results = [];

      for (var item in data["tracks"]["items"]) {
        final trackName = item["name"];
        final artistName = item["artists"][0]["name"];
        final artistId = item["artists"][0]["id"];

        // get artist genres
        final genreRes = await dio.get(
          "https://api.spotify.com/v1/artists/$artistId",
          options: Options(headers: {"Authorization": "Bearer $_accessToken"}),
        );
        String genre = "";
        if (genreRes.statusCode == 200) {
          final artistData = jsonDecode(genreRes.data);
          genre =
              (artistData["genres"] as List).isNotEmpty
                  ? artistData["genres"][0]
                  : "Unknown";
        }

        results.add({"track": trackName, "artist": artistName, "genre": genre});
      }
      return results;
    }
    return [];
  }
}
