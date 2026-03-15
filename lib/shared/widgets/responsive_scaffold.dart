import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResponsiveScaffold extends StatefulWidget {
  final Widget body;

  const ResponsiveScaffold({super.key, required this.body});

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/log')) return 1;
    if (location.startsWith('/reports')) return 2;
    if (location.startsWith('/goals')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0; // Default
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/log');
        break;
      case 2:
        context.go('/reports');
        break;
      case 3:
        context.go('/goals');
        break;
      case 4:
        context.go('/more');
        break;
    }
  }

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.restaurant_outlined),
      selectedIcon: Icon(Icons.restaurant),
      label: 'Log',
    ),
    NavigationDestination(
      icon: Icon(Icons.insert_chart_outlined),
      selectedIcon: Icon(Icons.insert_chart),
      label: 'Reports',
    ),
    NavigationDestination(
      icon: Icon(Icons.flag_outlined),
      selectedIcon: Icon(Icons.flag),
      label: 'Goals',
    ),
    NavigationDestination(
      icon: Icon(Icons.more_horiz_outlined),
      selectedIcon: Icon(Icons.more_horiz),
      label: 'More',
    ),
  ];

  final List<NavigationRailDestination> _railDestinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: Text('Home'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.restaurant_outlined),
      selectedIcon: Icon(Icons.restaurant),
      label: Text('Log'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.insert_chart_outlined),
      selectedIcon: Icon(Icons.insert_chart),
      label: Text('Reports'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.flag_outlined),
      selectedIcon: Icon(Icons.flag),
      label: Text('Goals'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.more_horiz_outlined),
      selectedIcon: Icon(Icons.more_horiz),
      label: Text('More'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateSelectedIndex(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile Breakpoint (< 600px) -> Bottom Navigation Bar
        if (constraints.maxWidth < 600) {
          return Scaffold(
            body: widget.body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _onItemTapped(index, context),
              destinations: _destinations,
            ),
          );
        }
        
        // Tablet Breakpoint (600px - 1024px) -> Navigation Rail
        if (constraints.maxWidth < 1024) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) => _onItemTapped(index, context),
                  labelType: NavigationRailLabelType.all,
                  destinations: _railDestinations,
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: widget.body),
              ],
            ),
          );
        }
        
        // Desktop Breakpoint (> 1024px) -> Permanent Drawer
        return Scaffold(
          body: Row(
            children: [
              Container(
                width: 250, // Fixed width for drawer
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    DrawerHeader(
                      child: Center(
                        child: Text(
                          'SoruTrack Pro',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _railDestinations.length,
                        itemBuilder: (context, index) {
                          final destination = _railDestinations[index];
                          final isSelected = index == selectedIndex;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            child: ListTile(
                              selected: isSelected,
                              selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              leading: isSelected ? destination.selectedIcon : destination.icon,
                              title: destination.label,
                              onTap: () => _onItemTapped(index, context),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: widget.body),
            ],
          ),
        );
      },
    );
  }
}
