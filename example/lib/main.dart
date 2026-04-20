import 'package:flutter/material.dart';
import 'package:titlemorph/titlemorph.dart';

void main() => runApp(const TitleMorphExampleApp());

class TitleMorphExampleApp extends StatelessWidget {
  const TitleMorphExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TitleMorph Example',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const _ExampleShell(),
    );
  }
}

// ── Tab data ──────────────────────────────────────────────────────────────────

class _Tab {
  const _Tab({required this.title, required this.icon});
  final String title;
  final IconData icon;
}

const _tabs = [
  _Tab(title: 'Home',     icon: Icons.home_rounded),
  _Tab(title: 'Discover', icon: Icons.explore_rounded),
  _Tab(title: 'Activity', icon: Icons.notifications_rounded),
  _Tab(title: 'Profile',  icon: Icons.person_rounded),
];

// ── Shell ─────────────────────────────────────────────────────────────────────

class _ExampleShell extends StatefulWidget {
  const _ExampleShell();

  @override
  State<_ExampleShell> createState() => _ExampleShellState();
}

class _ExampleShellState extends State<_ExampleShell> {
  final _pageController = PageController();
  int _tabIndex = 0;
  TitleMorphEffect _effect = TitleMorphEffect.blur;

  // All available effects for the picker
  static const _effects = TitleMorphEffect.values;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) => setState(() => _tabIndex = i);

  void _onNavTapped(int i) {
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TitleMorph(
          title: _tabs[_tabIndex].title,
          effect: _effect,
        ),
        centerTitle: true,
        elevation: 0,
        // Effect picker in the actions area
        actions: [
          PopupMenuButton<TitleMorphEffect>(
            icon: const Icon(Icons.auto_awesome_rounded),
            tooltip: 'Change effect',
            initialValue: _effect,
            onSelected: (e) => setState(() => _effect = e),
            itemBuilder: (_) => _effects
                .map(
                  (e) => PopupMenuItem(
                    value: e,
                    child: Row(
                      children: [
                        Icon(
                          _effect == e
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          size: 18,
                          color: _effect == e
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Text(e.label),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Effect chip row for quick switching
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _effects.map((e) {
                  final selected = _effect == e;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(e.label),
                      selected: selected,
                      onSelected: (_) => setState(() => _effect = e),
                      avatar: Text(e.icon, style: const TextStyle(fontSize: 14)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              children: _tabs
                  .map(
                    (t) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(t.icon, size: 64,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 16),
                          Text(
                            t.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Effect: ${_effect.label}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: _onNavTapped,
        destinations: _tabs
            .map((t) => NavigationDestination(icon: Icon(t.icon), label: t.title))
            .toList(),
      ),
    );
  }
}

// ── Convenience extensions ────────────────────────────────────────────────────

extension on TitleMorphEffect {
  String get label => switch (this) {
        TitleMorphEffect.blur   => 'Blur',
        TitleMorphEffect.flip   => 'Flip',
        TitleMorphEffect.wave   => 'Wave',
        TitleMorphEffect.skew   => 'Skew',
        TitleMorphEffect.spiral => 'Spiral',
      };

  String get icon => switch (this) {
        TitleMorphEffect.blur   => '🌫️',
        TitleMorphEffect.flip   => '🔄',
        TitleMorphEffect.wave   => '〰️',
        TitleMorphEffect.skew   => '↗️',
        TitleMorphEffect.spiral => '🌀',
      };
}
