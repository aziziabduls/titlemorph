import 'package:flutter/material.dart';
import 'package:titlemorph/titlemorph.dart';

void main() {
  runApp(const TitleMorphExampleApp());
}

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
  const _Tab({required this.title, required this.icon, required this.page});
  final String title;
  final IconData icon;
  final Widget page;
}

const _tabs = [
  _Tab(
    title: 'Home',
    icon: Icons.home_rounded,
    page: _PlaceholderPage(label: 'Home'),
  ),
  _Tab(
    title: 'Discover',
    icon: Icons.explore_rounded,
    page: _PlaceholderPage(label: 'Discover'),
  ),
  _Tab(
    title: 'Activity',
    icon: Icons.notifications_rounded,
    page: _PlaceholderPage(label: 'Activity'),
  ),
  _Tab(
    title: 'Profile',
    icon: Icons.person_rounded,
    page: _PlaceholderPage(label: 'Profile'),
  ),
];

// ── Shell ─────────────────────────────────────────────────────────────────────

class _ExampleShell extends StatefulWidget {
  const _ExampleShell();

  @override
  State<_ExampleShell> createState() => _ExampleShellState();
}

class _ExampleShellState extends State<_ExampleShell> {
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) => setState(() => _currentIndex = index);

  void _onNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ── Drop-in replacement: just swap Text(...) for TitleMorph(...) ──
        title: TitleMorph(
          title: _tabs[_currentIndex].title,
          // Optional tweaks:
          // staggerDuration: const Duration(milliseconds: 25),
          // blurSigma: 8.0,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: _tabs.map((t) => t.page).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavTapped,
        destinations: _tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon),
                label: t.title,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Placeholder pages ─────────────────────────────────────────────────────────

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label Page',
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
      ),
    );
  }
}
