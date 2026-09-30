import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../app/providers/user_provider.dart';
import 'admin_login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_products_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_inventory_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_customers_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_settings_screen.dart';

class AdminShell extends StatefulWidget {
  final int initialIndex;

  const AdminShell({super.key, this.initialIndex = 0});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  late int _selectedIndex;

  final List<Map<String, dynamic>> _navItems = const [
    {'title': 'Dashboard', 'icon': Icons.dashboard_rounded},
    {'title': 'Products', 'icon': Icons.inventory_2_rounded},
    {'title': 'Categories', 'icon': Icons.category_rounded},
    {'title': 'Inventory', 'icon': Icons.warehouse_rounded},
    {'title': 'Orders', 'icon': Icons.receipt_long_rounded},
    {'title': 'Customers', 'icon': Icons.people_rounded},
    {'title': 'Reports', 'icon': Icons.bar_chart_rounded},
    {'title': 'Settings', 'icon': Icons.settings_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onSelectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (!userProvider.isAdminLoggedIn) {
          return AdminLoginScreen(
            onLoginSuccess: () => setState(() {}),
          );
        }

        final isWide = MediaQuery.of(context).size.width >= 900;

        final screens = [
          AdminDashboardScreen(onNavigate: _onSelectTab),
          const AdminProductsScreen(),
          const AdminCategoriesScreen(),
          const AdminInventoryScreen(),
          const AdminOrdersScreen(),
          const AdminCustomersScreen(),
          const AdminReportsScreen(),
          const AdminSettingsScreen(),
        ];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'QuickCart Admin',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
              ],
            ),
            actions: [
              // Switch to Customer View
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.storefront_rounded, size: 16),
                label: const Text('Customer App'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              // Logout
              IconButton(
                tooltip: 'Logout Admin',
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                onPressed: () => userProvider.logoutAdmin(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          drawer: isWide
              ? null
              : Drawer(
                  child: _buildSidebarContent(),
                ),
          body: Row(
            children: [
              if (isWide)
                SizedBox(
                  width: 240,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(right: BorderSide(color: AppColors.border)),
                    ),
                    child: _buildSidebarContent(),
                  ),
                ),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: screens,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'MANAGEMENT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Store Admin Hub',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            itemCount: _navItems.length,
            itemBuilder: (context, index) {
              final item = _navItems[index];
              final isSelected = _selectedIndex == index;

              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                child: Material(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: ListTile(
                  dense: true,
                  leading: Icon(
                    item['icon'] as IconData,
                    color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                    size: 20,
                  ),
                  title: Text(
                    item['title'] as String,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? AppColors.secondary : AppColors.text,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {
                    _onSelectTab(index);
                    if (Navigator.of(context).canPop() && MediaQuery.of(context).size.width < 900) {
                      Navigator.of(context).pop(); // Close drawer on mobile
                    }
                  },
                ),
              ),
            );
          },
          ),
        ),
      ],
    );
  }
}
