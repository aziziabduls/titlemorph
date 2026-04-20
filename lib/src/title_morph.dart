import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A widget that animates title text with a per-character blur reveal effect.
///
/// Each character individually blurs out then blurs in when [title] changes,
/// creating a smooth morphing transition similar to SwiftUI's
/// `contentTransition(.interpolate)`.
///
/// Typically used as the `title` of an [AppBar]:
///
/// ```dart
/// AppBar(
///   title: TitleMorph(title: _tabs[_currentIndex].label),
/// )
/// ```
///
/// For programmatic control (e.g. triggering a transition without rebuilding),
/// provide a [TitleMorphController]:
///
/// ```dart
/// final _controller = TitleMorphController();
///
/// AppBar(
///   title: TitleMorph(
///     title: _title,
///     controller: _controller,
///   ),
/// )
///
/// // Later:
/// _controller.morph('New Title');
/// ```
class TitleMorph extends StatefulWidget {
  /// The text to display.
  const TitleMorph({
    super.key,
    required this.title,
    this.controller,
    this.style,
    this.staggerDuration = const Duration(milliseconds: 28),
    this.blurInDuration = const Duration(milliseconds: 220),
    this.blurOutDuration = const Duration(milliseconds: 160),
    this.swapDelay = const Duration(milliseconds: 80),
    this.blurSigma = 7.0,
    this.curve = Curves.easeInOut,
  });

  /// The text to display. Changing this value triggers the morph animation.
  final String title;

  /// Optional controller for programmatic morphing.
  final TitleMorphController? controller;

  /// Text style. Falls back to the ambient [AppBarTheme.titleTextStyle],
  /// then to a 20sp semi-bold style.
  final TextStyle? style;

  /// Delay between each successive character animating.
  ///
  /// Smaller values make the effect feel snappier; larger values create a
  /// more pronounced wave. Defaults to 28ms.
  final Duration staggerDuration;

  /// Duration of the blur-in animation per character. Defaults to 220ms.
  final Duration blurInDuration;

  /// Duration of the blur-out animation per character. Defaults to 160ms.
  final Duration blurOutDuration;

  /// Pause between finishing blur-out and starting blur-in. Defaults to 80ms.
  final Duration swapDelay;

  /// Maximum blur sigma applied when a character is fully hidden.
  /// Defaults to 7.0.
  final double blurSigma;

  /// Animation curve for each character's opacity. Defaults to [Curves.easeInOut].
  final Curve curve;

  @override
  State<TitleMorph> createState() => _TitleMorphState();
}

class _TitleMorphState extends State<TitleMorph> {
  late String _displayTitle;
  final Set<int> _visibleChars = {};
  bool _transitioning = false;

  @override
  void initState() {
    super.initState();
    _displayTitle = widget.title;
    widget.controller?._attach(this);
    _revealAll();
  }

  @override
  void didUpdateWidget(TitleMorph old) {
    super.didUpdateWidget(old);

    if (old.controller != widget.controller) {
      old.controller?._detach();
      widget.controller?._attach(this);
    }

    if (old.title != widget.title && !_transitioning) {
      _runTransition(widget.title);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    super.dispose();
  }

  // ── Internal API used by TitleMorphController ─────────────────────────────

  void _morphTo(String newTitle) {
    if (!_transitioning) _runTransition(newTitle);
  }

  // ── Animation helpers ─────────────────────────────────────────────────────

  void _revealAll() {
    for (var i = 0; i < _displayTitle.length; i++) {
      Future.delayed(widget.staggerDuration * i, () {
        if (mounted) setState(() => _visibleChars.add(i));
      });
    }
  }

  Future<void> _runTransition(String next) async {
    _transitioning = true;

    // Blur out left → right
    for (var i = 0; i < _displayTitle.length; i++) {
      await Future.delayed(widget.staggerDuration);
      if (!mounted) return;
      setState(() => _visibleChars.remove(i));
    }

    await Future.delayed(widget.swapDelay);
    if (!mounted) return;

    // Swap text while everything is invisible
    setState(() {
      _displayTitle = next;
      _visibleChars.clear();
    });

    // Blur in left → right
    _revealAll();

    // Wait for last char to finish before accepting next transition
    final settle =
        widget.staggerDuration * _displayTitle.length + widget.blurInDuration;
    await Future.delayed(settle);

    _transitioning = false;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).appBarTheme.titleTextStyle ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
    final effectiveStyle = widget.style ?? defaultStyle;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_displayTitle.length, (i) {
        final visible = _visibleChars.contains(i);
        return AnimatedOpacity(
          duration: visible ? widget.blurInDuration : widget.blurOutDuration,
          curve: widget.curve,
          opacity: visible ? 1.0 : 0.0,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: visible ? 0.0 : widget.blurSigma,
              sigmaY: visible ? 0.0 : widget.blurSigma,
              tileMode: TileMode.decal,
            ),
            child: Text(
              // Preserve whitespace as non-breaking so Row doesn't collapse it
              _displayTitle[i] == ' ' ? '\u00a0' : _displayTitle[i],
              style: effectiveStyle,
            ),
          ),
        );
      }),
    );
  }
}

/// An optional controller that lets you trigger a morph programmatically
/// without calling [setState] on a parent widget.
///
/// ```dart
/// class _MyState extends State<MyWidget> {
///   final _controller = TitleMorphController();
///   String _title = 'Home';
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(
///         title: TitleMorph(
///           title: _title,
///           controller: _controller,
///         ),
///       ),
///       body: ElevatedButton(
///         onPressed: () => _controller.morph('Settings'),
///         child: const Text('Go to Settings'),
///       ),
///     );
///   }
/// }
/// ```
class TitleMorphController {
  _TitleMorphState? _state;

  void _attach(_TitleMorphState state) => _state = state;
  void _detach() => _state = null;

  /// Triggers the morph animation to [newTitle].
  ///
  /// Safe to call even if the attached [TitleMorph] is currently animating —
  /// the transition will be queued until the current one completes.
  void morph(String newTitle) => _state?._morphTo(newTitle);

  /// Releases references. Call this inside [State.dispose].
  void dispose() => _state = null;
}
