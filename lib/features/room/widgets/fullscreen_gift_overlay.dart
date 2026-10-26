import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/virtual_gift_model.dart';

class FullscreenGiftOverlay extends StatefulWidget {
  final ActiveGiftEvent event;
  final VoidCallback onFinished;

  const FullscreenGiftOverlay({
    super.key,
    required this.event,
    required this.onFinished,
  });

  @override
  State<FullscreenGiftOverlay> createState() => _FullscreenGiftOverlayState();
}

class _FullscreenGiftOverlayState extends State<FullscreenGiftOverlay> with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;
  Timer? _dismissTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

    _initializeVideo();
    _startAutoDismissTimer();
  }

  void _initializeVideo() async {
    final url = widget.event.gift.videoUrl;
    if (url == null || url.isEmpty) return;

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await _controller!.initialize();
      if (!mounted) return;

      await _controller!.setVolume(0.85);
      await _controller!.setLooping(false);
      await _controller!.play();

      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      debugPrint('Video Gift Init Error (Graceful fallback): $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  void _startAutoDismissTimer() {
    final duration = Duration(seconds: widget.event.gift.durationSeconds);
    _dismissTimer = Timer(duration, () {
      _handleClose();
    });
  }

  void _handleClose() {
    if (!mounted) return;
    _dismissTimer?.cancel();
    _dismissTimer = null;

    _fadeController.reverse().then((_) {
      _cleanupResources();
      widget.onFinished();
    });
  }

  void _cleanupResources() {
    try {
      _controller?.pause();
      _controller?.dispose();
      _controller = null;
    } catch (_) {}
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _cleanupResources();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gift = widget.event.gift;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.black.withOpacity(0.78),
          ),
          if (_isVideoInitialized && _controller != null)
            Center(
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            )
          else
            _buildCinematicFallback(gift),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.85),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.85),
                ],
                stops: const [0.0, 0.25, 0.75, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E1065), Color(0xFF1E1B4B), Color(0xFF0F051D)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFFFB800), blurRadius: 20, spreadRadius: 2),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD700), width: 2),
                      ),
                      child: ClipOval(
                        child: widget.event.senderAvatar.isNotEmpty
                            ? Image.network(widget.event.senderAvatar, fit: BoxFit.cover)
                            : const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.event.senderName,
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('أرسل', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${gift.name} ➔ ${widget.event.targetSeatName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFB800), Color(0xFFFF8800)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 3),
                          Text(
                            '${gift.coins}',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 80, right: 16),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Icon(Icons.close, color: Colors.white70, size: 18),
                  ),
                  onPressed: _handleClose,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCinematicFallback(VirtualGiftItem gift) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(gift.icon, style: const TextStyle(fontSize: 110)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF0055), Color(0xFFFF8800)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Color(0xFFFF4500), blurRadius: 25)],
            ),
            child: Text(
              gift.name,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
