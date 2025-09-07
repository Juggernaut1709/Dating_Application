import 'package:flutter/material.dart';
import 'package:dating_app/services/spotify_service.dart';

class SongScreen extends StatefulWidget {
  const SongScreen({super.key});

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  final SpotifyService _spotifyService = SpotifyService();
  bool _loggedIn = false;
  List<Map<String, String>> _songs = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    bool loggedIn = await _spotifyService.init();
    setState(() => _loggedIn = loggedIn);
  }

  void _login() async {
    bool success = await _spotifyService.login();
    setState(() => _loggedIn = success);
  }

  void _searchSongs(String query) async {
    if (query.isEmpty) return;
    final results = await _spotifyService.searchSongs(query);
    setState(() => _songs = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Spotify Suggestions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF12c2e9), Color(0xFFc471ed)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(child: !_loggedIn ? _buildLoginUI() : _buildSearchUI()),
      ),
    );
  }

  Widget _buildLoginUI() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _login,
        icon: const Icon(Icons.music_note, color: Colors.white),
        label: const Text(
          "Login with Spotify",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1DB954), // Spotify green
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 6,
        ),
      ),
    );
  }

  Widget _buildSearchUI() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Search by song or artist...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.15),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: _searchSongs,
          ),
        ),

        // Song results
        Expanded(
          child:
              _songs.isEmpty
                  ? Center(
                    child: Text(
                      "Search for your favorite tracks 🎶",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  )
                  : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      final song = _songs[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.purpleAccent.withOpacity(
                              0.8,
                            ),
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            song["track"] ?? "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "${song["artist"]} • ${song["genre"]}",
                            style: TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // Could add "like" functionality later
                            },
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
