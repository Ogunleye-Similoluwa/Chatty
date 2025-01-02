// import 'dart:typed_data';

// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:rive/rive.dart';

// class AnimationCache {
//   static final _instance = AnimationCache._();
//   factory AnimationCache() => _instance;
//   AnimationCache._();

//   final _cacheManager = DefaultCacheManager();
//   final Map<String, RiveFile> _cachedAnimations = {};
//   final Map<String, bool> _preloadQueue = {};

//   // Preload animations
//   Future<void> preloadAnimations(List<String> urls) async {
//     for (final url in urls) {
//       if (!_preloadQueue.containsKey(url)) {
//         _preloadQueue[url] = true;
//         getAnimation(url).then((_) => _preloadQueue.remove(url));
//       }
//     }
//   }

//   Future<RiveFile?> getAnimation(String url, {int retryCount = 3}) async {
//     try {
//       // Check memory cache first
//       if (_cachedAnimations.containsKey(url)) {
//         return _cachedAnimations[url];
//       }

//       // Check disk cache
//       final file = await _cacheManager.getSingleFile(url);
//       final bytes = await file.readAsBytes();
//       final byteData = ByteData.sublistView(bytes);
//       final riveFile = RiveFile.import(byteData);
      
//       // Store in memory cache
//       _cachedAnimations[url] = riveFile;
      
//       return riveFile;
//     } catch (e) {
//       print('Animation cache error for $url: $e');
//       if (retryCount > 0) {
//         await Future.delayed(const Duration(seconds: 1));
//         return getAnimation(url, retryCount: retryCount - 1);
//       }
//       return null;
//     }
//   }

//   Future<void> clearCache() async {
//     _cachedAnimations.clear();
//     await _cacheManager.emptyCache();
//   }

//   bool isPreloading(String url) => _preloadQueue.containsKey(url);
// } 