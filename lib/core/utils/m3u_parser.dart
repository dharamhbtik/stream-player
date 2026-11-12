import 'package:uuid/uuid.dart';
import '../../features/playlist/domain/entities/channel.dart';
import '../../features/playlist/domain/entities/playlist.dart';
import '../errors/exceptions.dart';

/// Parser for M3U and M3U8 playlist files
class M3uParser {
  final Uuid _uuid = const Uuid();

  /// Parse M3U content and return a ParsedPlaylist
  ParsedPlaylist parse({
    required String content,
    required String playlistId,
    required String playlistName,
    required String sourceUrl,
    bool isLocal = false,
  }) {
    final lines = content.split('\n').map((e) => e.trim()).toList();
    
    if (lines.isEmpty) {
      throw ParsingException(message: 'Empty playlist content');
    }

    // Validate M3U header (be lenient - some playlists may not have it)
    final hasHeader = lines.isNotEmpty && lines[0].toUpperCase().startsWith('#EXTM3U');
    
    final channels = <Channel>[];
    final categories = <String>{};
    final languages = <String>{};
    final countries = <String>{};

    String? currentName;
    String? currentLogo;
    String? currentGroup;
    String? currentLanguage;
    String? currentCountry;

    for (int i = hasHeader ? 1 : 0; i < lines.length; i++) {
      final line = lines[i];
      
      if (line.isEmpty || line.startsWith('#EXTM3U')) {
        continue;
      }

      if (line.startsWith('#EXTINF:')) {
        // Parse EXTINF line
        final parsed = _parseExtInf(line);
        currentName = parsed['name'];
        currentLogo = parsed['tvg-logo'];
        currentGroup = parsed['group-title'];
        currentLanguage = parsed['tvg-language'];
        currentCountry = parsed['tvg-country'];
      } else if (!line.startsWith('#') && line.isNotEmpty) {
        // This is a stream URL
        if (currentName != null && _isValidUrl(line)) {
          final channel = Channel(
            id: _uuid.v4(),
            name: currentName,
            streamUrl: line,
            logoUrl: currentLogo,
            groupTitle: currentGroup,
            language: currentLanguage,
            country: currentCountry,
            playlistId: playlistId,
          );

          channels.add(channel);

          // Collect metadata for filters
          if (currentGroup != null && currentGroup.isNotEmpty) {
            categories.add(currentGroup);
          }
          if (currentLanguage != null && currentLanguage.isNotEmpty) {
            languages.add(currentLanguage);
          }
          if (currentCountry != null && currentCountry.isNotEmpty) {
            countries.add(currentCountry);
          }
        }

        // Reset for next entry
        currentName = null;
        currentLogo = null;
        currentGroup = null;
        currentLanguage = null;
        currentCountry = null;
      }
    }

    if (channels.isEmpty) {
      throw ParsingException(message: 'No valid channels found in playlist');
    }

    final playlist = Playlist(
      id: playlistId,
      name: playlistName,
      sourceUrl: sourceUrl,
      isLocal: isLocal,
      addedAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      channelCount: channels.length,
      categories: categories.toList()..sort(),
      languages: languages.toList()..sort(),
      countries: countries.toList()..sort(),
    );

    return ParsedPlaylist(playlist: playlist, channels: channels);
  }

  /// Parse EXTINF line and extract metadata
  Map<String, String?> _parseExtInf(String line) {
    final result = <String, String?>{
      'name': null,
      'tvg-logo': null,
      'group-title': null,
      'tvg-language': null,
      'tvg-country': null,
    };

    // Extract channel name (after the last comma)
    final commaIndex = line.lastIndexOf(',');
    if (commaIndex != -1 && commaIndex < line.length - 1) {
      result['name'] = line.substring(commaIndex + 1).trim();
    }

    // Extract attributes using regex
    final attributes = <String, String>{};
    final attrRegex = RegExp(r'([a-zA-Z-]+)="([^"]*)"');
    
    for (final match in attrRegex.allMatches(line)) {
      if (match.groupCount >= 2) {
        final key = match.group(1)?.toLowerCase();
        final value = match.group(2);
        if (key != null && value != null) {
          attributes[key] = value;
        }
      }
    }

    result['tvg-logo'] = attributes['tvg-logo'];
    result['group-title'] = attributes['group-title'];
    result['tvg-language'] = attributes['tvg-language'];
    result['tvg-country'] = attributes['tvg-country'];

    // Fallback: try to extract channel name from tvg-name if name is empty
    if ((result['name'] == null || result['name']!.isEmpty) && 
        attributes.containsKey('tvg-name')) {
      result['name'] = attributes['tvg-name'];
    }

    return result;
  }

  /// Validate if string is a valid stream URL
  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      // Accept http, https, and rtmp/rtsp protocols
      return uri.hasScheme && 
             (uri.scheme == 'http' || 
              uri.scheme == 'https' || 
              uri.scheme == 'rtmp' || 
              uri.scheme == 'rtsp');
    } catch (_) {
      return false;
    }
  }

  /// Validate M3U content before full parsing
  bool validateContent(String content) {
    if (content.isEmpty) return false;
    
    final lines = content.split('\n').map((e) => e.trim()).toList();
    
    // Check for at least some valid content
    bool hasExtInf = false;
    bool hasUrl = false;
    
    for (final line in lines) {
      if (line.startsWith('#EXTINF:')) {
        hasExtInf = true;
      }
      if (!line.startsWith('#') && 
          line.isNotEmpty && 
          _isValidUrl(line)) {
        hasUrl = true;
      }
      if (hasExtInf && hasUrl) return true;
    }
    
    return hasExtInf && hasUrl;
  }
}
