## 0.1.0

* Added `TitleMorphEffect` enum with five transition styles:
  * `blur` — per-character blur fade (original, default)
  * `flip` — 3-D Y-axis rotation per character
  * `wave` — sine-wave ripple vertical offset
  * `skew` — horizontal shear warp with scale
  * `spiral` — arc curl path with Z-axis rotation
* Each effect uses a dedicated `AnimationController` per character for smooth,
  independent staggering.
* Updated example app with a chip row and popup menu to switch effects live.

## 0.0.1

* Initial release.
* `TitleMorph` widget with per-character blur-out / blur-in transition.
* `TitleMorphController` for programmatic morphing without setState.
* Configurable `staggerDuration`, `blurSigma`, `blurInDuration`,
  `blurOutDuration`, `swapDelay`, and `curve`.
