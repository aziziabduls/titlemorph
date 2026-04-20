part of 'title_morph.dart';

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
