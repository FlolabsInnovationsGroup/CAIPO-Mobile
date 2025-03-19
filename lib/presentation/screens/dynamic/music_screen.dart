import 'package:flutter/material.dart';
import 'base_dynamic_screen.dart';

class MusicScreen extends BaseDynamicScreen {
  const MusicScreen({
    super.key,
    required super.command,
    super.commandData,
  });

  @override
  MusicScreenState createState() => MusicScreenState();
}

class MusicScreenState extends BaseDynamicScreenState<MusicScreen> {
  bool _isPlaying = false;
  double _volume = 0.8;
  Duration _songPosition = Duration.zero;
  final Duration _songDuration =
      const Duration(minutes: 3, seconds: 45); // Mock duration

  // Mock data
  final Map<String, String> _currentSong = {
    'title': 'Song Title',
    'artist': 'Artist Name',
    'album': 'Album Name',
    'coverUrl': 'https://example.com/cover.jpg',
  };

  final List<Map<String, String>> _recentlyPlayed = [
    {
      'title': 'Previous Song 1',
      'artist': 'Artist 1',
      'time': '2 min ago',
    },
    {
      'title': 'Previous Song 2',
      'artist': 'Artist 2',
      'time': '15 min ago',
    },
    {
      'title': 'Previous Song 3',
      'artist': 'Artist 3',
      'time': '1 hour ago',
    },
  ];

  @override
  void setupBackgroundAnimation() {
    backgroundStartAnimation = ColorTween(
      begin: const Color(0xFF9C27B0), // Purple for music
      end: const Color(0xFFBA68C8),
    ).animate(backgroundController);

    backgroundEndAnimation = ColorTween(
      begin: const Color(0xFFBA68C8),
      end: const Color(0xFF9C27B0),
    ).animate(backgroundController);
  }

  Widget _buildNowPlaying() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300],
              ),
              child: const Center(
                child: Icon(
                  Icons.music_note,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _currentSong['title']!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _currentSong['artist']!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () {
                    // Implement previous track
                  },
                ),
                IconButton(
                  iconSize: 48,
                  icon: Icon(_isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled),
                  onPressed: () {
                    setState(() {
                      _isPlaying = !_isPlaying;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    // Implement next track
                  },
                ),
              ],
            ),
            Slider(
              value: _songPosition.inSeconds.toDouble(),
              max: _songDuration.inSeconds.toDouble(),
              onChanged: (value) {
                setState(() {
                  _songPosition = Duration(seconds: value.toInt());
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_songPosition),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  _formatDuration(_songDuration),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.volume_down),
                Expanded(
                  child: Slider(
                    value: _volume,
                    onChanged: (value) {
                      setState(() {
                        _volume = value;
                      });
                    },
                  ),
                ),
                const Icon(Icons.volume_up),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyPlayed() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recently Played',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              _recentlyPlayed.length,
              (index) => ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.music_note),
                ),
                title: Text(_recentlyPlayed[index]['title']!),
                subtitle: Text(_recentlyPlayed[index]['artist']!),
                trailing: Text(
                  _recentlyPlayed[index]['time']!,
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  // Implement play from history
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget buildScreenContent(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'Music',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildNowPlaying(),
                    const SizedBox(height: 24),
                    _buildRecentlyPlayed(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
