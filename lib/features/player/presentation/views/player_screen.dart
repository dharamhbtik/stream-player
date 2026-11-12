import 'dart:async';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../playlist/domain/entities/channel.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final Channel channel;

  const PlayerScreen({super.key, required this.channel});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  BetterPlayerController? _playerController;
  bool _isControlsVisible = true;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  Timer? _hideControlsTimer;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _initializePlayer();
    _startHideControlsTimer();
  }

  void _initializePlayer() {
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.channel.streamUrl,
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 5000,
        maxBufferMs: 30000,
        bufferForPlaybackMs: 2500,
        bufferForPlaybackAfterRebufferMs: 5000,
      ),
      cacheConfiguration: const BetterPlayerCacheConfiguration(
        useCache: true,
        maxCacheSize: 100 * 1024 * 1024,
        maxCacheFileSize: 20 * 1024 * 1024,
      ),
      notificationConfiguration: BetterPlayerNotificationConfiguration(
        showNotification: true,
        title: widget.channel.name,
        author: AppConstants.appName,
        imageUrl: widget.channel.logoUrl,
      ),
    );

    _playerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        fit: BoxFit.contain,
        aspectRatio: 16 / 9,
        handleLifecycle: true,
        autoDetectFullscreenAspectRatio: true,
        autoDetectFullscreenDeviceOrientation: true,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          showControls: false, // We use custom controls
        ),
        eventListener: _onPlayerEvent,
        errorBuilder: (context, errorMessage) => _buildErrorWidget(errorMessage),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  void _onPlayerEvent(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        setState(() {
          _isLoading = false;
          _hasError = false;
          _retryCount = 0;
        });
        break;
      case BetterPlayerEventType.bufferingStart:
        setState(() => _isLoading = true);
        break;
      case BetterPlayerEventType.bufferingEnd:
        setState(() => _isLoading = false);
        break;
      case BetterPlayerEventType.exception:
        _handleError();
        break;
      default:
        break;
    }
  }

  void _handleError() {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _playerController?.retryDataSource();
        }
      });
    } else {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = 'Stream unavailable. Please try again later.';
      });
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(
      Duration(milliseconds: AppConstants.playerControlsHideDelay),
      () {
        if (mounted && _isControlsVisible) {
          setState(() => _isControlsVisible = false);
        }
      },
    );
  }

  void _toggleControls() {
    setState(() => _isControlsVisible = !_isControlsVisible);
    if (_isControlsVisible) {
      _startHideControlsTimer();
    }
  }

  void _seekRelative(int seconds) {
    final currentPosition = _playerController?.videoPlayerController?.value.position;
    if (currentPosition != null) {
      final newPosition = currentPosition + Duration(seconds: seconds);
      _playerController?.seekTo(newPosition);
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _playerController?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Player
          GestureDetector(
            onTap: _toggleControls,
            onDoubleTapDown: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              final tapX = details.globalPosition.dx;
              if (tapX < screenWidth / 2) {
                _seekRelative(-AppConstants.seekDuration);
              } else {
                _seekRelative(AppConstants.seekDuration);
              }
            },
            child: _buildPlayer(),
          ),

          // Loading Indicator
          if (_isLoading)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 3,
                ),
              ),
            ),

          // Custom Controls Overlay
          if (_isControlsVisible) _buildControlsOverlay(),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    if (_hasError) {
      return _buildErrorWidget(_errorMessage);
    }

    return _playerController != null
        ? BetterPlayer(controller: _playerController!)
        : const SizedBox();
  }

  Widget _buildControlsOverlay() {
    return AnimatedOpacity(
      opacity: _isControlsVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
            stops: const [0.0, 0.2, 0.8, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              _buildTopBar(),
              const Spacer(),
              // Center Controls
              _buildCenterControls(),
              const Spacer(),
              // Bottom Bar
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.channel.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.channel.groupTitle != null)
                  Text(
                    widget.channel.displayCategory,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          // PiP Button (Android only)
          IconButton(
            icon: const Icon(Icons.picture_in_picture_alt, color: Colors.white),
            onPressed: () {
              _playerController?.enablePictureInPicture(
                _playerController!.betterPlayerGlobalKey!,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Rewind 10s
        _buildControlButton(
          icon: Icons.replay_10,
          size: 40,
          onTap: () => _seekRelative(-AppConstants.seekDuration),
        ),
        const SizedBox(width: 32),
        // Play/Pause
        _buildPlayPauseButton(),
        const SizedBox(width: 32),
        // Forward 10s
        _buildControlButton(
          icon: Icons.forward_10,
          size: 40,
          onTap: () => _seekRelative(AppConstants.seekDuration),
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton() {
    final isPlaying = _playerController?.isPlaying() ?? false;
    
    return GestureDetector(
      onTap: () {
        if (isPlaying) {
          _playerController?.pause();
        } else {
          _playerController?.play();
        }
        setState(() {});
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size + 16,
        height: size + 16,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          // Quality info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          // Aspect Ratio Toggle
          IconButton(
            icon: const Icon(Icons.aspect_ratio, color: Colors.white),
            onPressed: _toggleAspectRatio,
          ),
          // Fullscreen Toggle
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: () {
              if (MediaQuery.of(context).orientation == Orientation.portrait) {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]);
              } else {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                ]);
              }
            },
          ),
        ],
      ),
    );
  }

  void _toggleAspectRatio() {
    final currentFit = _playerController?.betterPlayerConfiguration.fit;
    BoxFit newFit;
    
    switch (currentFit) {
      case BoxFit.contain:
        newFit = BoxFit.cover;
        break;
      case BoxFit.cover:
        newFit = BoxFit.fill;
        break;
      default:
        newFit = BoxFit.contain;
    }

    _playerController?.setOverriddenFit(newFit);
    setState(() {});
  }

  Widget _buildErrorWidget(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'Failed to play stream',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hasError = false;
                _isLoading = true;
                _retryCount = 0;
              });
              _playerController?.retryDataSource();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
