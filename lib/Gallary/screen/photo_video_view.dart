import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class PhotoVideoView extends StatefulWidget {
  final List<AssetEntity> data;
  final int index;
  const PhotoVideoView({super.key, required this.data, required this.index});

  @override
  State<PhotoVideoView> createState() => _PhotoVideoViewState();
}

class _PhotoVideoViewState extends State<PhotoVideoView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        itemCount: widget.data.length,
        controller: PageController(initialPage: widget.index),
        itemBuilder: (context, indexx) {
          final asset = widget.data[indexx];

          if (asset.type == AssetType.video) {
            return VideoPage(asset: asset);
          }

          return FutureBuilder<Uint8List?>(
            future: asset.thumbnailDataWithOption(
              const ThumbnailOption(
                size: ThumbnailSize(1080, 1920),
                quality: 90,
              ),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (snapshot.hasData && snapshot.data != null) {
                return PhotoView(
                  imageProvider: MemoryImage(snapshot.data!),
                  enableRotation: true,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                );
              }
              return const Center(
                child: Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class VideoPage extends StatefulWidget {
  final AssetEntity asset;
  const VideoPage({super.key, required this.asset});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  VideoPlayerController? _controller;
  bool showControls = true;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final file = await widget.asset.file;
    if (file == null) return;

    final controller = VideoPlayerController.file(file);
    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _controller!.addListener(_videoListener);
      });
      _controller?.play();
      _hideControlsAfterDelay();
    } catch (_) {
      controller.dispose();
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null || !_controller!.value.isInitialized)
      return;

    setState(() {
      position = _controller!.value.position;
    });

    if (_controller!.value.duration == _controller!.value.position) {
      setState(() {
        showControls = true; // Show replay button
      });
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 10), () {
      if (_controller != null && _controller!.value.isPlaying && mounted) {
        setState(() {
          showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        showControls = true;
      } else {
        if (_controller!.value.duration == _controller!.value.position) {
          _controller!.seekTo(Duration.zero);
        }
        _controller!.play();
        _hideControlsAfterDelay();
      }
    });
  }

  void _seekForward() {
    final newPosition = position + const Duration(seconds: 10);
    _controller!.seekTo(
      newPosition > _controller!.value.duration
          ? _controller!.value.duration
          : newPosition,
    );
    setState(() => showControls = true);
    _hideControlsAfterDelay();
  }

  void _seekBackward() {
    final newPosition = position - const Duration(seconds: 10);
    _controller!.seekTo(
      newPosition < Duration.zero ? Duration.zero : newPosition,
    );
    setState(() => showControls = true);
    _hideControlsAfterDelay();
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
@override
Widget build(BuildContext context) {
  if (_controller == null || !_controller!.value.isInitialized) {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  final bool isFinished = _controller!.value.duration == _controller!.value.position;
  final bool shouldShowIcon = !_controller!.value.isPlaying || isFinished;

  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      setState(() => showControls = !showControls);
      if (showControls && _controller!.value.isPlaying) {
        _hideControlsAfterDelay();
      }
    },
    child: Stack(
  fit: StackFit.expand,
  children: [
    // Video background
    Center(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      ),
    ),
    if (showControls)
      Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.2),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (shouldShowIcon)
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(
                      isFinished
                          ? Icons.replay_circle_filled
                          : Icons.play_circle_fill,
                      color: Colors.white.withOpacity(0.9),
                      size: 80,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),
              // Controls bar always at bottom
              Align(
                alignment: Alignment.bottomCenter,
                child: _VideoControls(
                  controller: _controller!,
                  position: position,
                  togglePlayPause: _togglePlayPause,
                  seekForward: _seekForward,
                  seekBackward: _seekBackward,
                ),
              ),
            ],
          ),
        ),
      ),
  ],
)

  );
}
}

class _VideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final Duration position;
  final VoidCallback togglePlayPause;
  final VoidCallback seekForward;
  final VoidCallback seekBackward;

  const _VideoControls({
    required this.controller,
    required this.position,
    required this.togglePlayPause,
    required this.seekForward,
    required this.seekBackward,
  });

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    final hours = d.inHours;

    if (hours > 0) {
      return "${twoDigits(hours)}:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.black54,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.replay_10,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: seekBackward,
              ),
              IconButton(
                icon: Icon(
                  controller.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 48,
                ),
                onPressed: togglePlayPause,
              ),
              IconButton(
                icon: const Icon(
                  Icons.forward_10,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: seekForward,
              ),
            ],
          ),
          Row(
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),

              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6.0,
                    ),
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.grey.shade600,
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    min: 0.0,
                    max: controller.value.duration.inMilliseconds.toDouble(),
                    value: position.inMilliseconds.toDouble().clamp(
                      0.0,
                      controller.value.duration.inMilliseconds.toDouble(),
                    ),
                    onChanged: (double value) {
                      final newPosition = Duration(milliseconds: value.round());
                      controller.seekTo(newPosition);
                    },
                  ),
                ),
              ),

              Text(
                _formatDuration(controller.value.duration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}