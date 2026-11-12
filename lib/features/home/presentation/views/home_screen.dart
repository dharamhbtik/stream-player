import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/channel_card.dart';
import '../../../../core/widgets/search_bar.dart' as custom;
import '../../../../core/widgets/skeleton_loaders.dart';
import '../../../playlist/domain/entities/channel.dart';
import '../../../playlist/presentation/providers/playlist_provider.dart';
import '../../../playlist/presentation/views/add_playlist_screen.dart';
import '../../../player/presentation/views/player_screen.dart';
import '../../../settings/presentation/views/settings_screen.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlistState = ref.watch(playlistProvider);
    final isGridView = ref.watch(isGridViewProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(playlistState),
            // Search Bar
            custom.SearchBar(
              onSearch: (query) => setState(() => _searchQuery = query),
            ),
            // Tab Bar
            _buildTabBar(),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllChannelsTab(playlistState, isGridView),
                  _buildCategoriesTab(playlistState, isGridView),
                  _buildLanguagesTab(playlistState, isGridView),
                  _buildFavoritesTab(playlistState, isGridView, isPremium),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddPlaylist(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Playlist',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(PlaylistState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.accentGradient.createShader(bounds),
                child: const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '${state.channels.length} channels',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
          const Spacer(),
          // View Mode Toggle
          IconButton(
            onPressed: () => ref.read(settingsProvider.notifier).toggleViewMode(),
            icon: Icon(
              ref.watch(isGridViewProvider)
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
              color: AppColors.textSecondaryDark,
            ),
          ),
          // Settings
          IconButton(
            onPressed: () => _navigateToSettings(),
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textSecondaryDark,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        indicator: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Categories'),
          Tab(text: 'Languages'),
          Tab(text: 'Favorites'),
        ],
      ),
    );
  }

  Widget _buildAllChannelsTab(PlaylistState state, bool isGridView) {
    if (state.isLoading) {
      return PageSkeleton(isGrid: isGridView);
    }

    if (state.channels.isEmpty) {
      return _buildEmptyState();
    }

    final channels = _searchQuery.isEmpty
        ? state.channels
        : ref.watch(filteredChannelsProvider(_searchQuery));

    return _buildChannelGrid(channels, isGridView);
  }

  Widget _buildCategoriesTab(PlaylistState state, bool isGridView) {
    if (state.isLoading) {
      return const PageSkeleton();
    }

    if (state.categories.isEmpty) {
      return _buildEmptyState(message: 'No categories found');
    }

    if (_selectedCategory != null) {
      final channels = ref.watch(channelsByCategoryProvider(_selectedCategory!));
      return Column(
        children: [
          _buildBackButton(),
          Expanded(child: _buildChannelGrid(channels, isGridView)),
        ],
      );
    }

    return _buildCategoryList(state.channelsByCategory);
  }

  Widget _buildLanguagesTab(PlaylistState state, bool isGridView) {
    if (state.isLoading) {
      return const PageSkeleton();
    }

    if (state.languages.isEmpty) {
      return _buildEmptyState(message: 'No languages found');
    }

    if (_selectedLanguage != null) {
      final channels = ref.watch(channelsByLanguageProvider(_selectedLanguage!));
      return Column(
        children: [
          _buildBackButton(isLanguage: true),
          Expanded(child: _buildChannelGrid(channels, isGridView)),
        ],
      );
    }

    return _buildLanguageList(state.channelsByLanguage);
  }

  Widget _buildFavoritesTab(PlaylistState state, bool isGridView, bool isPremium) {
    if (!isPremium) {
      return _buildPremiumPrompt();
    }

    if (state.favoriteChannels.isEmpty) {
      return _buildEmptyState(
        message: 'No favorites yet',
        icon: Icons.favorite_border,
      );
    }

    return _buildChannelGrid(state.favoriteChannels, isGridView);
  }

  Widget _buildChannelGrid(List<Channel> channels, bool isGridView) {
    return AnimationLimiter(
      child: isGridView
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: channels.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  columnCount: 3,
                  duration: Duration(milliseconds: AppConstants.fadeInAnimationDuration),
                  child: FadeInAnimation(
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: ChannelCard(
                        channel: channels[index],
                        isGridView: true,
                        onTap: () => _playChannel(channels[index]),
                        onFavoriteTap: () => _toggleFavorite(channels[index]),
                      ),
                    ),
                  ),
                );
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: channels.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: Duration(milliseconds: AppConstants.fadeInAnimationDuration),
                  child: FadeInAnimation(
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: ChannelCard(
                        channel: channels[index],
                        isGridView: false,
                        onTap: () => _playChannel(channels[index]),
                        onFavoriteTap: () => _toggleFavorite(channels[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildCategoryList(Map<String, List<Channel>> categoryMap) {
    final categories = categoryMap.keys.toList()..sort();
    
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final count = categoryMap[category]?.length ?? 0;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: Duration(milliseconds: AppConstants.fadeInAnimationDuration),
            child: FadeInAnimation(
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: _buildGroupTile(
                  title: category,
                  count: count,
                  icon: Icons.folder_outlined,
                  onTap: () => setState(() => _selectedCategory = category),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageList(Map<String, List<Channel>> languageMap) {
    final languages = languageMap.keys.toList()..sort();
    
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final language = languages[index];
          final count = languageMap[language]?.length ?? 0;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: Duration(milliseconds: AppConstants.fadeInAnimationDuration),
            child: FadeInAnimation(
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: _buildGroupTile(
                  title: language,
                  count: count,
                  icon: Icons.language_outlined,
                  onTap: () => setState(() => _selectedLanguage = language),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupTile({
    required String title,
    required int count,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                      Text(
                        '$count channels',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondaryDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton({bool isLanguage = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                if (isLanguage) {
                  _selectedLanguage = null;
                } else {
                  _selectedCategory = null;
                }
              });
            },
            icon: const Icon(Icons.arrow_back, size: 18),
            label: Text(isLanguage ? _selectedLanguage! : _selectedCategory!),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    String message = 'No channels yet',
    IconData icon = Icons.playlist_add,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: AppColors.textTertiaryDark),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your M3U playlist to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.premiumGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Premium Feature',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Upgrade to Premium to save your favorite channels and access them anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryDark,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.premiumGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // TODO: Implement premium purchase
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    child: Text(
                      'Upgrade to Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playChannel(Channel channel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlayerScreen(channel: channel),
      ),
    );
  }

  void _toggleFavorite(Channel channel) {
    final isPremium = ref.read(isPremiumProvider);
    if (!isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upgrade to Premium to use favorites'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ref.read(playlistProvider.notifier).toggleFavorite(channel);
  }

  void _navigateToAddPlaylist() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddPlaylistScreen(),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}
