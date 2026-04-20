/// TitleMorph — per-character blur reveal transition for Flutter AppBar titles.
///
/// Inspired by SwiftUI's `contentTransition(.interpolate)`, each character
/// individually blurs out and blurs in when the title changes, creating a
/// smooth morphing effect.
///
/// ```dart
/// AppBar(
///   title: TitleMorph(title: _currentTitle),
/// )
/// ```
// ignore: unnecessary_library_name
library titlemorph;

export 'src/title_morph.dart';
