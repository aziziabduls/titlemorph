/// TitleMorph — per-character animated title transitions for Flutter AppBars.
///
/// Inspired by SwiftUI's `contentTransition(.interpolate)`, each character
/// individually animates when the title changes. Choose from five effects:
///
/// - [TitleMorphEffect.blur]   — blur fade (default)
/// - [TitleMorphEffect.flip]   — 3-D Y-axis rotation
/// - [TitleMorphEffect.wave]   — sine-wave ripple
/// - [TitleMorphEffect.skew]   — horizontal shear warp
/// - [TitleMorphEffect.spiral] — arc curl with rotation
///
/// ```dart
/// AppBar(
///   title: TitleMorph(
///     title: _currentTitle,
///     effect: TitleMorphEffect.wave,
///   ),
/// )
/// ```
// ignore: unnecessary_library_name
library titlemorph;

export 'src/title_morph.dart';
export 'src/title_morph_effect.dart';
