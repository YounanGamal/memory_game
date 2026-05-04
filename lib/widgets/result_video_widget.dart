import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class ResultVideoWidget extends StatefulWidget {
  final bool isSuccess;
  final VoidCallback? onPlayAgain;
  final double width;
  final double height;

  const ResultVideoWidget({
    super.key,
    required this.isSuccess,
    this.onPlayAgain,
    this.width = 180,
    this.height = 140,
  });

  @override
  State<ResultVideoWidget> createState() => _ResultVideoWidgetState();
}

class _ResultVideoWidgetState extends State<ResultVideoWidget> {
  static const List<String> _successVideos = [
    'assets/video/success1.mp4',
    'assets/video/success2.mp4',
  ];
  static const String _failVideo = 'assets/video/fail1.mp4';
  static final Random _random = Random();
  static String? _lastSuccessVideo;

  VideoPlayerController? _controller;
  String? _currentAsset;
  bool _isInitializing = true;
  bool _hasError = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _loadResultVideo();
  }

  @override
  void didUpdateWidget(covariant ResultVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSuccess != widget.isSuccess) {
      _loadResultVideo();
    }
  }

  Future<void> _loadResultVideo({bool keepSameAsset = false}) async {
    final assetPath = keepSameAsset && _currentAsset != null
        ? _currentAsset!
        : _pickVideoAsset();

    setState(() {
      _isInitializing = true;
      _hasError = false;
      _isFinished = false;
      _currentAsset = assetPath;
    });

    await _disposeController();

    try {
      await _verifyAssetExists(assetPath);

      final controller = VideoPlayerController.asset(assetPath);
      _controller = controller;
      controller.addListener(_handleVideoTick);

      await controller.initialize();
      await controller.setLooping(false);

      if (!mounted) {
        await _disposeController();
        return;
      }

      setState(() {
        _isInitializing = false;
      });
      await controller.play();
    } catch (e) {
      debugPrint('Result video failed to load ($assetPath): $e');
      await _disposeController();
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = true;
        });
      }
    }
  }

  String _pickVideoAsset() {
    if (!widget.isSuccess) return _failVideo;

    if (_successVideos.length == 1) return _successVideos.first;

    final candidates = _successVideos
        .where((asset) => asset != _lastSuccessVideo)
        .toList(growable: false);
    final selected = candidates[_random.nextInt(candidates.length)];
    _lastSuccessVideo = selected;
    return selected;
  }

  Future<void> _verifyAssetExists(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      if (data.lengthInBytes == 0) {
        throw StateError('Asset is empty');
      }
    } on FlutterError catch (e) {
      debugPrint('Missing result video asset: $assetPath');
      throw StateError(e.message);
    }
  }

  void _handleVideoTick() {
    final controller = _controller;
    if (!mounted || controller == null || !controller.value.isInitialized) {
      return;
    }

    final position = controller.value.position;
    final duration = controller.value.duration;
    final finished = duration != Duration.zero && position >= duration;

    if (finished != _isFinished) {
      setState(() => _isFinished = finished);
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _hasError) {
      return;
    }

    if (_isFinished) {
      await controller.seekTo(Duration.zero);
      if (mounted) setState(() => _isFinished = false);
      await controller.play();
      if (mounted) setState(() {});
      return;
    }

    controller.value.isPlaying
        ? await controller.pause()
        : await controller.play();
    if (mounted) setState(() {});
  }

  Future<void> _replay() async {
    widget.onPlayAgain?.call();
    await _loadResultVideo(keepSameAsset: true);
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    if (controller == null) return;

    controller.removeListener(_handleVideoTick);
    await controller.pause();
    await controller.dispose();
  }

  @override
  void dispose() {
    final controller = _controller;
    _controller = null;
    controller?.removeListener(_handleVideoTick);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildVideoFrame(),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _isInitializing ? null : _replay,
          icon: const Icon(Icons.replay_rounded),
          label: const Text('Play Again'),
        ),
      ],
    );
  }

  Widget _buildVideoFrame() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _buildVideoContent(),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    final controller = _controller;

    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError || controller == null || !controller.value.isInitialized) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_off_rounded, size: 42, color: Colors.grey),
            SizedBox(height: 8),
            Text('Video unavailable'),
          ],
        ),
      );
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey(_currentAsset),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _togglePlayback,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
            if (!controller.value.isPlaying || _isFinished)
              const Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
