# titlemorph

A Flutter widget that animates AppBar titles with **per-character transition effects** — inspired by SwiftUI's `contentTransition(.interpolate)`.

Each character animates individually when the title changes. Choose from five built-in effects.

---

## Effects

| Effect | Description |
|--------|-------------|
| `blur` | Each character blurs out and blurs in (default) |
| `flip` | 3-D Y-axis rotation, like a card turning |
| `wave` | Sine-wave ripple travels left to right |
| `skew` | Horizontal shear warp with subtle scale |
| `spiral` | Arc curl path with Z-axis rotation |

---

## Installation

```yaml
dependencies:
  titlemorph: ^0.0.2
```

```sh
flutter pub get
```

---



## Usage

### Basic

```dart
import 'package:titlemorph/titlemorph.dart';

AppBar(
  title: TitleMorph(
    title: _tabs[_currentIndex].label,
    effect: TitleMorphEffect.wave, // default: TitleMorphEffect.blur
  ),
)
```

Changing `title` automatically triggers the morph animation.

---

### Switching effects at runtime

```dart
TitleMorphEffect _effect = TitleMorphEffect.blur;

AppBar(
  title: TitleMorph(
    title: _currentTitle,
    effect: _effect,
  ),
  actions: [
    PopupMenuButton<TitleMorphEffect>(
      onSelected: (e) => setState(() => _effect = e),
      itemBuilder: (_) => TitleMorphEffect.values
          .map((e) => PopupMenuItem(value: e, child: Text(e.name)))
          .toList(),
    ),
  ],
)
```

---

### Programmatic control with `TitleMorphController`

```dart
class _MyState extends State<MyWidget> {
  final _controller = TitleMorphController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TitleMorph(
          title: 'Home',
          effect: TitleMorphEffect.spiral,
          controller: _controller,
        ),
      ),
      body: ElevatedButton(
        onPressed: () => _controller.morph('Settings'),
        child: const Text('Go to Settings'),
      ),
    );
  }
}
```

---

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `title` | `String` | **required** | The text to display |
| `effect` | `TitleMorphEffect` | `.blur` | Transition style |
| `controller` | `TitleMorphController?` | `null` | Programmatic control |
| `style` | `TextStyle?` | `null` | Falls back to `AppBarTheme.titleTextStyle` |
| `staggerDuration` | `Duration` | `28ms` | Delay between each character |
| `blurInDuration` | `Duration` | `220ms` | Reveal duration per character |
| `blurOutDuration` | `Duration` | `160ms` | Hide duration per character |
| `swapDelay` | `Duration` | `80ms` | Pause between out and in phases |
| `blurSigma` | `double` | `7.0` | Max blur amount (`.blur` effect only) |
| `curve` | `Curve` | `Curves.easeInOut` | Animation curve per character |

---

## Tuning tips

**Snappier feel**
```dart
TitleMorph(
  title: _title,
  effect: TitleMorphEffect.flip,
  staggerDuration: const Duration(milliseconds: 18),
  blurInDuration: const Duration(milliseconds: 150),
  blurOutDuration: const Duration(milliseconds: 100),
)
```

**Slower, dramatic feel**
```dart
TitleMorph(
  title: _title,
  effect: TitleMorphEffect.wave,
  staggerDuration: const Duration(milliseconds: 45),
  blurInDuration: const Duration(milliseconds: 320),
  curve: Curves.easeInOutCubic,
)
```

---

## How it works

1. Each character in `title` gets its own `AnimationController`.
2. On title change, controllers reverse (animate out) left-to-right with a stagger delay.
3. Once settled, the string is swapped while all characters are invisible.
4. Controllers then forward (animate in) left-to-right, revealing the new title.
5. Each effect applies a different `Transform` / `ImageFiltered` based on the controller value.

---

## License

MIT — see [LICENSE](LICENSE).
