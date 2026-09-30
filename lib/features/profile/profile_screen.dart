import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../app/providers/user_provider.dart';
import '../../app/providers/order_provider.dart';
import '../admin/admin_shell.dart';
import '../orders/orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  final void Function(int)? onNavigateTab;

  const ProfileScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, OrderProvider>(
      builder: (context, userProvider, orderProvider, _) {
        final user = userProvider.currentUser;
        final ordersCount = user != null ? orderProvider.getCustomerOrders(user.id).length : 0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            backgroundColor: Colors.white,
            actions: [
              // Quick Customer Switcher for Demo evaluation
              PopupMenuButton<User>(
                tooltip: 'Switch Demo Customer',
                icon: const Icon(Icons.swap_horiz_rounded),
                onSelected: (u) => userProvider.switchCustomer(u),
                itemBuilder: (context) => userProvider.users.map((u) {
                  return PopupMenuItem(
                    value: u,
                    child: Text('${u.name} (${u.id})'),
                  );
                }).toList(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user?.name.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Customer',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+91 ${user?.phone ?? ''}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Saved Addresses
                const Text(
                  'Saved Delivery Addresses',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 10),
                if (user != null && user.addresses.isNotEmpty)
                  ...user.addresses.map((addr) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                addr.title.toLowerCase() == 'home'
                                    ? Icons.home_rounded
                                    : Icons.work_rounded,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        addr.title,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                      if (addr.isDefault) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'DEFAULT',
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    addr.fullAddress,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),

                const SizedBox(height: 20),

                // General Options
                _buildMenuSection([
                  _buildMenuItem(
                    icon: Icons.receipt_long_rounded,
                    title: 'My Orders',
                    subtitle: '$ordersCount previous orders',
                    onTap: () {
                      if (onNavigateTab != null) {
                        onNavigateTab!(3);
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const OrdersScreen()),
                        );
                      }
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.admin_panel_settings_rounded,
                    title: 'Admin Management Panel',
                    subtitle: 'Manage products, categories, stock & orders',
                    highlightColor: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AdminShell()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.support_agent_rounded,
                    title: '24/7 Help & Support',
                    subtitle: 'Chat with our instant support team',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Support helpline: +91 98765 43210')),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About QuickCart',
                    subtitle: 'Version 1.0.0 • 10-Minute Quick Commerce',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'QuickCart',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2026 QuickCart Inc.',
                      );
                    },
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuSection(List<Widget> items) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.divider),
          itemBuilder: (_, index) => items[index],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? highlightColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: highlightColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.secondary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
    );
  }
}
