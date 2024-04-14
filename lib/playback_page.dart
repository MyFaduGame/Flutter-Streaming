import 'package:flutter/material.dart';
import 'package:flutter_streaming/models/mux_model.dart';
import 'package:flutter_streaming/strings.dart';
import 'package:video_player/video_player.dart';


class PlaybackPage extends StatefulWidget {
  const PlaybackPage({
    super.key,
    required this.streamData,
  });

  final MuxLiveData streamData;

  @override
  State<PlaybackPage> createState() => _PlaybackPageState();
}

class _PlaybackPageState extends State<PlaybackPage> {
  late final VideoPlayerController _videoController;
  late final MuxLiveData _streamData;

  @override
  void initState() {
    super.initState();

    _streamData = widget.streamData;
    String playbackId = _streamData.playbackIds[0].id;

    _videoController = VideoPlayerController.network(
        '$muxStreamBaseUrl/$playbackId.$videoExtension')
      ..initialize().then((_) {
        setState(() {});
      });

    _videoController.play();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _videoController.value.isInitialized
            ? ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.pink,
                  ),
                  strokeWidth: 2,
                ),
              ),
      ),
    );
  }
}