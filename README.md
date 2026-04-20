# titlemorph

A Flutter widget that animates AppBar titles with a **per-character blur reveal** effect — inspired by SwiftUI's `contentTransition(.interpolate)`.

Each character individually blurs out and blurs back in when the title changes, creating a smooth morphing transition that feels native on both iOS and Android.

---

## Features

- Per-character blur-out → blur-in stagger animation
- Drop-in replacement for `Text(...)` inside `AppBar.title`
- `TitleMorphController` for programmatic transitions
- Fully configurable: stagger speed, blur intensity, duration, curve
- No dependencies beyond Flutter itself
- Works with Material 2 and Material 3

---

## Installation

```yaml
dependencies:
  titlemorph: ^0.0.1
```

Then run:

```sh
flutter pub get
```

---

## Usage

### Basic — reactive on title change

```dart
import 'package:titlemorph/titlemorph.dart';

AppBar(
  title: TitleMorph(title: _tabs[_currentIndex].label),
)
```

Changing `title` automatically triggers the morph animation.

---

### With PageView / BottomNavigationBar

```dart
class _Shell extends StatefulWidget { ... }

class _ShellState extends State<_Shell> {
  final _pageController = PageController();
  int _index = 0;

  final _tabs = ['Home', 'Discover', 'Activity', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TitleMorph(title: _tabs[_index]),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _index = i),
        children: [ ... ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          );
        },
        destinations: _tabs
            .map((t) => NavigationDestination(icon: ..., label: t))
            .toList(),
      ),
    );
  }
}
```

---

### Programmatic control with `TitleMorphController`

Use a controller when you want to trigger a morph without lifting state to a parent widget.

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

## Customisation

| Parameter | Type | Default | Description |
|---|---|---|---|
| `title` | `String` | **required** | The text to display |
| `controller` | `TitleMorphController?` | `null` | For programmatic morphing |
| `style` | `TextStyle?` | `null` | Falls back to `AppBarTheme.titleTextStyle` |
| `staggerDuration` | `Duration` | `28ms` | Delay between each character animating |
| `blurInDuration` | `Duration` | `220ms` | Blur-in duration per character |
| `blurOutDuration` | `Duration` | `160ms` | Blur-out duration per character |
| `swapDelay` | `Duration` | `80ms` | Pause between blur-out finishing and blur-in starting |
| `blurSigma` | `double` | `7.0` | Max blur amount when a character is hidden |
| `curve` | `Curve` | `Curves.easeInOut` | Animation curve per character |

### Example — faster, snappier feel

```dart
TitleMorph(
  title: _currentTitle,
  staggerDuration: const Duration(milliseconds: 18),
  blurInDuration: const Duration(milliseconds: 160),
  blurOutDuration: const Duration(milliseconds: 120),
  blurSigma: 5.0,
)
```

### Example — slower, more dramatic feel

```dart
TitleMorph(
  title: _currentTitle,
  staggerDuration: const Duration(milliseconds: 45),
  blurSigma: 12.0,
  curve: Curves.easeInOutCubic,
)
```

---

## How it works

1. Each character in `title` is rendered as its own `Text` widget inside an `ImageFiltered` + `AnimatedOpacity` pair.
2. On title change, characters blur **out** left-to-right with a fixed stagger delay.
3. Once the blur-out settles, the internal string is swapped while everything is invisible.
4. Characters then blur **in** left-to-right with the same stagger, revealing the new title.
5. `TileMode.decal` on `ImageFilter.blur` prevents edge bleed between adjacent characters.

---

## License

MIT — see [LICENSE](LICENSE).
