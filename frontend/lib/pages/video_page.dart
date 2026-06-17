import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerScreen extends StatefulWidget {
  final String videoId;
  const YoutubePlayerScreen({super.key, required this.videoId});

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        forceHD: true,
        useHybridComposition: true,
        disableDragSeek: false,
        hideThumbnail: true,
        loop: true
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent.withValues(alpha: 1),
      body: YoutubePlayerBuilder(
        onExitFullScreen: () {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        },
        onEnterFullScreen: () {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        },
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: const Color(0xFFE10600),
          onReady: () => setState(() => _isPlayerReady = true),
          bottomActions: const [
            CurrentPosition(),
            ProgressBar(isExpanded: true),
            RemainingDuration(),
            FullScreenButton(),
          ],
        ),
        builder: (context, player) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // TOP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Container(
                        width: 3,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE10600),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'F1 2026',
                              style: GoogleFonts.orbitron(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              'OPENING TITLES',
                              style: GoogleFonts.orbitron(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFE10600),
                                letterSpacing: 2.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // DIVIDER
                Divider(
                  color: Colors.white.withValues(alpha: 0.07),
                  height: 1,
                ),

                // VIDEO
                Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom : 60),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: player,  // ← plain, no wrapping
                        ),
                      ),
                    ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}