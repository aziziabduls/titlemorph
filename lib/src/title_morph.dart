import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'title_morph_effect.dart';

export 'title_morph_effect.dart';

part 'title_morph_controller.dart';

/// A widget that animates AppBar titles with a per-character transition effect.
///
/// Each character animates individually when [title] changes. The visual style
/// is controlled by [effect]:
///
/// - [TitleMorphEffect.blur]   — per-character blur reveal (default)
/// - [TitleMorphEffect.flip]   — 3-D Y-axis rotation per character
/// - [TitleMorphEffect.wave]   — sine-wave ripple across the word
/// - [TitleMorphEffect.skew]   — horizontal skew warp fade
/// - [TitleMorphEffect.spiral] — small arc curl in/out
///
/// ```dart
/// AppBar(
///   title: TitleMorph(
///     title: _tabs[_index].label,
///     effect: TitleMorphEffect.wave,
///   ),
/// )
/// ```
class TitleMorph extends StatefulWidget {
  const TitleMorph({
    super.key,
    required this.title,
    this.effect = TitleMorphEffect.blur,
    this.controller,
    this.style,
    this.staggerDuration = const Duration(milliseconds: 28),
    this.blurInDuration = const Duration(milliseconds: 220),
    this.blurOutDuration = const Duration(milliseconds: 160),
    this.swapDelay = const Duration(milliseconds: 80),
    this.blurSigma = 7.0,
    this.curve = Curves.easeInOut,
  });

  /// The text to display. Changing this triggers the morph animation.
  final String title;

  /// The visual transition style. Defaults to [TitleMorphEffect.blur].
  final TitleMorphEffect effect;

  /// Optional controller for programmatic morphing.
  final TitleMorphController? controller;

  /// Text style. Falls back to [AppBarTheme.titleTextStyle], then 20sp/w600.
  final TextStyle? style;

  /// Delay between each successive character animating. Defaults to 28ms.
  final Duration staggerDuration;

  /// Blur-in (reveal) duration per character. Defaults to 220ms.
  final Duration blurInDuration;

  /// Blur-out (hide) duration per character. Defaults to 160ms.
  final Duration blurOutDuration;

  /// Pause between blur-out finishing and blur-in starting. Defaults to 80ms.
  final Duration swapDelay;

  /// Max blur sigma when [TitleMorphEffect.blur] is used. Defaults to 7.0.
  final double blurSigma;

  /// Animation curve per character. Defaults to [Curves.easeInOut].
  final Curve curve;

  @override
  State<TitleMorph> createState() => _TitleMorphState();
}

class _TitleMorphState extends State<TitleMorph> with TickerProviderStateMixin {
  late String _displayTitle;
  final List<AnimationController> _controllers = [];
  final List<bool> _revealing = [];
  bool _transitioning = false;

  @override
  void initState() {
    super.initState();
    _displayTitle = widget.title;
    widget.controller?._attach(this);
    _buildControllers(_displayTitle.length, startVisible: false);
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
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Controller management ─────────────────────────────────────────────────

  void _buildControllers(int length, {required bool startVisible}) {
    for (final c in _controllers) {
      c.dispose();
    }
    _controllers.clear();
    _revealing.clear();

    for (var i = 0; i < length; i++) {
      _controllers.add(AnimationController(
        vsync: this,
        duration: widget.blurInDuration,
        value: startVisible ? 1.0 : 0.0,
      ));
      _revealing.add(startVisible);
    }
  }

  // ── Internal API used by TitleMorphController ─────────────────────────────

  void _morphTo(String newTitle) {
    if (!_transitioning) _runTransition(newTitle);
  }

  // ── Animation helpers ─────────────────────────────────────────────────────

  void _revealAll() {
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(widget.staggerDuration * i, () {
        if (!mounted) return;
        setState(() => _revealing[i] = true);
        _controllers[i].duration = widget.blurInDuration;
        _controllers[i].forward();
      });
    }
  }

  Future<void> _runTransition(String next) async {
    _transitioning = true;

    // Phase 1: animate out left → right
    for (var i = 0; i < _controllers.length; i++) {
      await Future.delayed(widget.staggerDuration);
      if (!mounted) return;
      setState(() => _revealing[i] = false);
      _controllers[i].duration = widget.blurOutDuration;
      _controllers[i].reverse();
    }

    await Future.delayed(widget.swapDelay);
    if (!mounted) return;

    // Phase 2: swap text
    setState(() => _displayTitle = next);
    _buildControllers(next.length, startVisible: false);

    // Phase 3: animate in left → right
    _revealAll();

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
        final ch = _displayTitle[i] == ' ' ? '\u00a0' : _displayTitle[i];
        return _Character(
          key: ValueKey('${widget.effect.name}-$i-$_displayTitle'),
          character: ch,
          controller: _controllers[i],
          revealing: _revealing[i],
          effect: widget.effect,
          style: effectiveStyle,
          blurSigma: widget.blurSigma,
          curve: widget.curve,
          charIndex: i,
          totalChars: _displayTitle.length,
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-character router
// ─────────────────────────────────────────────────────────────────────────────

class _Character extends StatelessWidget {
  const _Character({
    super.key,
    required this.character,
    required this.controller,
    required this.revealing,
    required this.effect,
    required this.style,
    required this.blurSigma,
    required this.curve,
    required this.charIndex,
    required this.totalChars,
  });

  final String character;
  final AnimationController controller;
  final bool revealing;
  final TitleMorphEffect effect;
  final TextStyle style;
  final double blurSigma;
  final Curve curve;
  final int charIndex;
  final int totalChars;

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(parent: controller, curve: curve);

    return switch (effect) {
      TitleMorphEffect.blur => _BlurChar(
          anim: anim,
          character: character,
          style: style,
          blurSigma: blurSigma,
        ),
      TitleMorphEffect.flip => _FlipChar(
          anim: anim,
          revealing: revealing,
          character: character,
          style: style,
        ),
      TitleMorphEffect.wave => _WaveChar(
          anim: anim,
          revealing: revealing,
          character: character,
          style: style,
          charIndex: charIndex,
          totalChars: totalChars,
        ),
      TitleMorphEffect.skew => _SkewChar(
          anim: anim,
          revealing: revealing,
          character: character,
          style: style,
        ),
      TitleMorphEffect.spiral => _SpiralChar(
          anim: anim,
          revealing: revealing,
          character: character,
          style: style,
        ),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Effect: blur — per-character blur fade (original effect)
// ─────────────────────────────────────────────────────────────────────────────

class _BlurChar extends StatelessWidget {
  const _BlurChar({
    required this.anim,
    required this.character,
    required this.style,
    required this.blurSigma,
  });

  final Animation<double> anim;
  final String character;
  final TextStyle style;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) {
        final sigma = ui.lerpDouble(blurSigma, 0.0, anim.value)!;
        return Opacity(
          opacity: anim.value,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: sigma,
              sigmaY: sigma,
              tileMode: TileMode.decal,
            ),
            child: child,
          ),
        );
      },
      child: Text(character, style: style),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Effect: flip — 3-D Y-axis rotation
// ─────────────────────────────────────────────────────────────────────────────

class _FlipChar extends StatelessWidget {
  const _FlipChar({
    required this.anim,
    required this.revealing,
    required this.character,
    required this.style,
  });

  final Animation<double> anim;
  final bool revealing;
  final String character;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) {
        // Rotate from -90° → 0° when revealing, 0° → 90° when hiding
        final angle = revealing
            ? (1.0 - anim.value) * -math.pi / 2
            : anim.value * math.pi / 2;
        return Opacity(
          opacity: anim.value,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.003) // perspective
              ..rotateY(angle),
            child: child,
          ),
        );
      },
      child: Text(character, style: style),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Effect: wave — sine-wave ripple vertical offset
// ─────────────────────────────────────────────────────────────────────────────

class _WaveChar extends StatelessWidget {
  const _WaveChar({
    required this.anim,
    required this.revealing,
    required this.character,
    required this.style,
    required this.charIndex,
    required this.totalChars,
  });

  final Animation<double> anim;
  final bool revealing;
  final String character;
  final TextStyle style;
  final int charIndex;
  final int totalChars;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) {
        final phase = charIndex / math.max(totalChars - 1, 1);
        // Arc pulse along the sine
        final sineArc = math.sin(anim.value * math.pi + phase * math.pi) * -4.0;
        // Slide in from below when revealing, slide up and away when hiding
        final slideY =
            revealing ? (1.0 - anim.value) * 14.0 : anim.value * -14.0;
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(0, slideY + sineArc),
            child: child,
          ),
        );
      },
      child: Text(character, style: style),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Effect: skew — horizontal shear warp
// ─────────────────────────────────────────────────────────────────────────────

class _SkewChar extends StatelessWidget {
  const _SkewChar({
    required this.anim,
    required this.revealing,
    required this.character,
    required this.style,
  });

  final Animation<double> anim;
  final bool revealing;
  final String character;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) {
        // Shear collapses rightward on exit, expands from left on entry
        final skewX =
            revealing ? (1.0 - anim.value) * 0.55 : anim.value * -0.55;
        final scaleX =
            revealing ? 0.6 + anim.value * 0.4 : 1.0 - anim.value * 0.4;
        return Opacity(
          opacity: anim.value,
          child: Transform(
            alignment: Alignment.bottomLeft,
            transform: Matrix4.identity()
              ..scale(scaleX, 1.0)
              ..setEntry(0, 1, skewX),
            child: child,
          ),
        );
      },
      child: Text(character, style: style),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Effect: spiral — arc curl path with rotation
// ─────────────────────────────────────────────────────────────────────────────

class _SpiralChar extends StatelessWidget {
  const _SpiralChar({
    required this.anim,
    required this.revealing,
    required this.character,
    required this.style,
  });

  final Animation<double> anim;
  final bool revealing;
  final String character;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) {
        // t=1 → fully visible, t=0 → fully hidden
        final t = revealing ? anim.value : 1.0 - anim.value;
        final angle = (1.0 - t) * math.pi * 0.45;
        final dx = (1.0 - t) * 10.0 * math.sin(angle);
        final dy = (1.0 - t) * -13.0;
        final rot = revealing ? (1.0 - anim.value) * -0.45 : anim.value * 0.45;
        return Opacity(
          opacity: anim.value,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(dx, dy)
              ..rotateZ(rot),
            child: child,
          ),
        );
      },
      child: Text(character, style: style),
    );
  }
}
