import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class CloudyVideoBackground extends StatefulWidget {
  final Widget child;

  const CloudyVideoBackground({super.key, required this.child});

  @override
  State<CloudyVideoBackground> createState() => _CloudyVideoBackgroundState();
}

class _CloudyVideoBackgroundState extends State<CloudyVideoBackground> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      _videoPlayerController = VideoPlayerController.asset('assets/animations/nuageux.mp4');
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true,
        showControls: false,           // Pas de contrôles vidéo
        allowMuting: false,
        allowPlaybackSpeedChanging: false,
        allowFullScreen: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement de la vidéo: $e');
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          // Background vidéo ou fallback
          if (_isVideoInitialized && _chewieController != null)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoPlayerController.value.size.width,
                  height: _videoPlayerController.value.size.height,
                  child: Chewie(controller: _chewieController!),
                ),
              ),
            )
          else
          // Fallback en cas de problème
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF9E9E9E), // Gris nuageux
                      Color(0xFFBDBDBD), // Gris clair
                      Color(0xFFE0E0E0), // Gris très clair
                    ],
                  ),
                ),
              ),
            ),

          // Overlay pour lisibilité du texte
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(26),
                    Colors.black.withAlpha(77),
                  ],
                ),
              ),
            ),
          ),

          // Contenu par-dessus
          Positioned.fill(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}