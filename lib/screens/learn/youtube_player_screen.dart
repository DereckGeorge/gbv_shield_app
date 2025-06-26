import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;

  const YoutubePlayerScreen({
    Key? key,
    required this.videoId,
    required this.title,
  }) : super(key: key);

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    // Set to portrait initially
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );

    _controller.addListener(_onPlayerStateChange);
  }

  void _onPlayerStateChange() {
    if (_controller.value.isFullScreen != _isFullScreen) {
      setState(() => _isFullScreen = _controller.value.isFullScreen);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isFullScreen) {
          _controller.toggleFullScreenMode();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: _isFullScreen ? null : AppBar(
          title: Text(widget.title),
          backgroundColor: const Color(0xFF7C3AED),
        ),
        body: YoutubePlayerBuilder(
          onExitFullScreen: () {
            // When exiting fullscreen, set back to portrait
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
            SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.manual,
              overlays: SystemUiOverlay.values,
            );
            if (mounted) {
              setState(() => _isFullScreen = false);
            }
          },
          onEnterFullScreen: () {
            // When entering fullscreen, allow all orientations
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
            if (mounted) {
              setState(() => _isFullScreen = true);
            }
          },
          player: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: const Color(0xFF7C3AED),
            progressColors: const ProgressBarColors(
              playedColor: Color(0xFF7C3AED),
              handleColor: Color(0xFF7C3AED),
            ),
            onEnded: (data) {
              // When video ends, ensure we're back in portrait if not in fullscreen
              if (!_isFullScreen) {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ]);
              }
            },
          ),
          builder: (context, player) {
            return Column(
              children: [
                player,
                if (!_isFullScreen) Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
