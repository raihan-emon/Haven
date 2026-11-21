import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/floating_nav.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});
  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _i = 0;

  void _setNav(bool visible) {
    final c = ref.read(navVisibleProvider.notifier);
    if (c.state != visible) c.state = visible;
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    if (n is UserScrollNotification) {
      if (n.direction == ScrollDirection.reverse) {
        _setNav(false); // scrolling down
      } else if (n.direction == ScrollDirection.forward) {
        _setNav(true); // scrolling up
      }
    } else if (n is ScrollUpdateNotification &&
        n.metrics.pixels <= n.metrics.minScrollExtent + 1) {
      _setNav(true); // back at the top
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final visible = ref.watch(navVisibleProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: _i == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _i != 0) {
          setState(() => _i = 0);
          _setNav(true);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: IndexedStack(
                index: _i,
                children: const [
                  SearchScreen(),
                  FavoritesScreen(),
                  SettingsScreen(),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: kNavMargin + bottomInset,
              child: IgnorePointer(
                ignoring: !visible,
                child: AnimatedSlide(
                  offset: visible ? Offset.zero : const Offset(0, 1.6),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: visible ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: FloatingNav(
                      index: _i,
                      onSelected: (i) {
                        setState(() => _i = i);
                        _setNav(true);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
