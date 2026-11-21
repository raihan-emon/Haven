import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../state/theme_settings.dart';

const double kNavHeight = 72;
const double kNavMargin = 12;
const double kNavSpace = kNavHeight + kNavMargin; // lift for buttons above it

/// true = nav bar and search bar shown, false = hidden (scrolling down)
final navVisibleProvider = StateProvider<bool>((ref) => true);

class FloatingNav extends ConsumerWidget {
  final int index;
  final ValueChanged<int> onSelected;

  const FloatingNav({super.key, required this.index, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final expressive =
        ref.watch(themeProvider.select((t) => t.expressive));

    return Material(
      color: cs.surfaceContainerHigh,
      elevation: 8,
      shadowColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      borderRadius: BorderRadius.circular(expressive ? kNavHeight / 2 : 20),
      clipBehavior: Clip.antiAlias,
      // NavigationBar adds the system padding (status bar etc.) to itself,
      // which made the pill too tall. Strip it so the height is exactly kNavHeight.
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
        child: NavigationBar(
          height: kNavHeight,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          selectedIndex: index,
          onDestinationSelected: onSelected,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.grid_view), label: 'Browse'),
            NavigationDestination(
                icon: Icon(Icons.favorite_border), label: 'Favorites'),
            NavigationDestination(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
