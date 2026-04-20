/// The visual transition style applied to each character during a morph.
///
/// Pass this to [TitleMorph.effect] to choose the animation style.
///
/// ```dart
/// TitleMorph(
///   title: _currentTitle,
///   effect: TitleMorphEffect.wave,
/// )
/// ```
enum TitleMorphEffect {
  /// Each character blurs out and blurs in with no additional movement.
  /// The original TitleMorph effect.
  blur,

  /// Characters rotate around the Y axis as they exit and enter,
  /// like a 3-D horizontal flip.
  flip,

  /// Characters animate with a sine-wave vertical offset — a ripple
  /// that travels left to right across the word.
  wave,

  /// Characters skew horizontally (italic-like warp) while fading,
  /// then un-skew as they arrive.
  skew,

  /// Characters follow a small outward arc as they leave and curl
  /// back in from below as they arrive.
  spiral,
}
