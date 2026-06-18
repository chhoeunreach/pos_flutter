import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/di/injection.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final List<_NavItem> _primaryItems = [
    _NavItem('Dashboard', Icons.dashboard_outlined, Icons.dashboard, '/'),
    _NavItem('Purchases', Icons.shopping_cart_outlined, Icons.shopping_cart,
        '/purchases'),
    _NavItem(
        'Sales', Icons.receipt_long_outlined, Icons.receipt_long, '/sales'),
    _NavItem(
        'Transfer', Icons.swap_horiz_outlined, Icons.swap_horiz, '/transfers'),
  ];

  final List<_NavItem> _secondaryItems = [
    _NavItem('POS', Icons.point_of_sale_outlined, Icons.point_of_sale, '/pos'),
    _NavItem(
        'Products', Icons.inventory_2_outlined, Icons.inventory_2, '/products'),
    _NavItem('Customers', Icons.people_outline, Icons.people, '/customers'),
    _NavItem('Suppliers', Icons.local_shipping_outlined, Icons.local_shipping,
        '/suppliers'),
    _NavItem('Reports', Icons.bar_chart_outlined, Icons.bar_chart, '/reports'),
    _NavItem('Payments', Icons.payments_outlined, Icons.payments, '/payments'),
    _NavItem('Todos', Icons.checklist_outlined, Icons.checklist, '/todos'),
    _NavItem('Settings', Icons.settings_outlined, Icons.settings, '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900
        ? _buildTabletLayout()
        : _buildPhoneLayout();
  }

  Widget _buildPhoneLayout() {
    return Scaffold(
      drawer: _buildDrawer(),
      body: Builder(
        builder: (scaffoldContext) => Stack(
          children: [
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (prev, current) =>
                  !current.isAuthenticated && prev.isAuthenticated,
              listener: (context, state) =>
                  context.go(AppConfig.hasServerUrl ? '/login' : '/connect'),
              child: widget.child,
            ),
            Positioned(
              left: 0,
              top: MediaQuery.of(context).size.height * 0.42,
              child: Material(
                color: Theme.of(context).colorScheme.primary,
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(20)),
                elevation: 2,
                child: InkWell(
                  borderRadius:
                      const BorderRadius.horizontal(right: Radius.circular(20)),
                  onTap: () => Scaffold.of(scaffoldContext).openDrawer(),
                  child: const SizedBox(
                    width: 36,
                    height: 52,
                    child: Icon(Icons.menu, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final currentIndex = _selectedPrimaryIndex(context);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        context.go(_primaryItems[index].route);
      },
      items: _primaryItems.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        return BottomNavigationBarItem(
          icon: Icon(currentIndex == idx ? item.activeIcon : item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }

  Widget _buildTabletLayout() {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, current) =>
          !current.isAuthenticated && prev.isAuthenticated,
      listener: (context, state) =>
          context.go(AppConfig.hasServerUrl ? '/login' : '/connect'),
      child: Row(
        children: [
          _buildDesktopSidebar(),
          const VerticalDivider(width: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 232,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Icon(Icons.store,
                      size: 30, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'POS',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _SidebarSection(
                    label: 'Main',
                    children: _primaryItems
                        .map((item) => _SidebarButton(
                              item: item,
                              selected: _isRouteSelected(context, item.route),
                              onTap: () => context.go(item.route),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  _SidebarSection(
                    label: 'Other',
                    children: _secondaryItems
                        .map((item) => _SidebarButton(
                              item: item,
                              selected: _isRouteSelected(context, item.route),
                              onTap: () => context.go(item.route),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: OutlinedButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.store,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('POS'),
              subtitle: const Text('Menu'),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text('Main',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  ..._primaryItems.map((item) => _drawerItem(item)),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text('Other',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  ..._secondaryItems.map((item) => _drawerItem(item)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: _confirmLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(_NavItem item) {
    return ListTile(
      selected: _isRouteSelected(context, item.route),
      leading: Icon(
          _isRouteSelected(context, item.route) ? item.activeIcon : item.icon),
      title: Text(item.label),
      onTap: () {
        Navigator.pop(context);
        context.go(item.route);
      },
    );
  }

  int _selectedPrimaryIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final index =
        _primaryItems.indexWhere((item) => _routeMatches(path, item.route));
    return index < 0 ? 0 : index;
  }

  bool _isRouteSelected(BuildContext context, String route) {
    return _routeMatches(GoRouterState.of(context).uri.path, route);
  }

  bool _routeMatches(String path, String route) {
    if (route == '/') return path == '/';
    return path == route || path.startsWith('$route/');
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout == true && mounted) {
      context.read<AuthBloc>().add(LogoutEvent());
    }
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  const _NavItem(this.label, this.icon, this.activeIcon, this.route);
}

class _SidebarSection extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _SidebarSection({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? Theme.of(context).colorScheme.primary : Colors.grey[700];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Ink(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.12)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(selected ? item.activeIcon : item.icon,
                    color: color, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
