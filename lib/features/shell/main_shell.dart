import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/nav_provider.dart';
import '../categories/presentation/categories_page.dart';
import '../products/presentation/pages/product_list_page.dart';
import '../state_preview/presentation/state_preview_page.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _destinations = [
    (icon: Icons.home_outlined, selected: Icons.home, label: 'หน้าแรก'),
    (icon: Icons.category_outlined, selected: Icons.category, label: 'หมวดหมู่'),
    (
      icon: Icons.science_outlined,
      selected: Icons.science,
      label: 'จำลอง State'
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navIndexProvider);
    void select(int i) => ref.read(navIndexProvider.notifier).state = i;

    final body = IndexedStack(
      index: index,
      children: const [
        ProductListPage(),
        CategoriesPage(),
        StatePreviewPage(),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: index,
                  onDestinationSelected: select,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final d in _destinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selected),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: select,
            destinations: [
              for (final d in _destinations)
                NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selected),
                  label: d.label,
                ),
            ],
          ),
        );
      },
    );
  }
}
