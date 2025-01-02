// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:rive/rive.dart';
// import '../helper/animation_cache.dart';

// class CachedRiveAnimation extends StatefulWidget {
//   final String url;
//   final String fallbackAsset;
//   final BoxFit fit;
//   final Widget? placeholder;

//   const CachedRiveAnimation({
//     super.key,
//     required this.url,
//     required this.fallbackAsset,
//     this.fit = BoxFit.contain,
//     this.placeholder,
//   });

//   @override
//   State<CachedRiveAnimation> createState() => _CachedRiveAnimationState();
// }

// class _CachedRiveAnimationState extends State<CachedRiveAnimation> {
//   late Future<RiveFile?> _animationFuture;
//   int _errorCount = 0;
//   static const _maxErrors = 3;

//   @override
//   void initState() {
//     super.initState();
//     _loadAnimation();
//   }

//   void _loadAnimation() {
//     _animationFuture = AnimationCache().getAnimation(widget.url);
//   }

//   void _handleError(dynamic error) {
//     _errorCount++;
//     if (_errorCount < _maxErrors) {
//       print('Retrying animation load (attempt $_errorCount): $error');
//       setState(() => _loadAnimation());
//     } else {
//       print('Max retries reached, using fallback: $error');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<RiveFile?>(
//       future: _animationFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return widget.placeholder ?? const CircularProgressIndicator();
//         }

//         if (snapshot.hasError || !snapshot.hasData) {
//           _handleError(snapshot.error);
//           return RiveAnimation.asset(
//             widget.fallbackAsset,
//             fit: widget.fit,
//           ).animate().fadeIn(duration: const Duration(milliseconds: 300));
//         }

//         return RiveAnimation.direct(
//           snapshot.data!,
//           fit: widget.fit,
//         ).animate().fadeIn(duration: const Duration(milliseconds: 300));
//       },
//     );
//   }
// } 