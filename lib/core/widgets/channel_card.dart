import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../features/playlist/domain/entities/channel.dart';

/// Animated channel card with tap scale effect
class ChannelCard extends StatefulWidget {
  final Channel channel;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final bool showFavorite;
  final bool isGridView;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.onTap,
    this.onFavoriteTap,
    this.showFavorite = true,
    this.isGridView = true,
  });

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: AppConstants.cardAnimationDuration),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppConstants.cardScaleOnTap,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isGridView ? _buildGridCard() : _buildListCard();
  }

  Widget _buildGridCard() {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Channel Logo
                _buildLogo(size: AppConstants.channelLogoSize),
                const SizedBox(height: 10),
                // Channel Name
                Text(
                  widget.channel.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimaryDark,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Metadata chips
                if (widget.channel.groupTitle != null)
                  _buildChip(widget.channel.displayCategory),
                if (widget.showFavorite) ...[
                  const Spacer(),
                  _buildFavoriteButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListCard() {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Channel Logo
                _buildLogo(size: 44),
                const SizedBox(width: 14),
                // Channel Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.channel.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textPrimaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (widget.channel.groupTitle != null) ...[
                            _buildChip(widget.channel.displayCategory),
                            const SizedBox(width: 6),
                          ],
                          if (widget.channel.language != null)
                            _buildChip(widget.channel.displayLanguage),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.showFavorite) _buildFavoriteButton(),
                const SizedBox(width: 8),
                const Icon(
                  Icons.play_circle_filled,
                  color: AppColors.primary,
                  size: 32,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo({required double size}) {
    if (widget.channel.logoUrl != null && widget.channel.logoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: widget.channel.logoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildLogoPlaceholder(size),
          errorWidget: (context, url, error) => _buildLogoPlaceholder(size),
        ),
      );
    }
    return _buildLogoPlaceholder(size);
  }

  Widget _buildLogoPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          widget.channel.name.isNotEmpty ? widget.channel.name[0].toUpperCase() : 'C',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.primaryLight,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: widget.onFavoriteTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(
          widget.channel.isFavorite ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(widget.channel.isFavorite),
          color: widget.channel.isFavorite ? AppColors.error : AppColors.textSecondaryDark,
          size: 22,
        ),
      ),
    );
  }
}
