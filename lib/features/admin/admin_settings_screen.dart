import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/custom_button.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _appNameController = TextEditingController(text: AppConstants.appName);
  final _taglineController = TextEditingController(text: AppConstants.appTagline);
  final _thresholdController = TextEditingController(text: '${AppConstants.freeDeliveryThreshold.toInt()}');
  final _deliveryFeeController = TextEditingController(text: '${AppConstants.standardDeliveryFee.toInt()}');
  final _minsController = TextEditingController(text: '${AppConstants.estimatedDeliveryMinutes}');

  @override
  void dispose() {
    _appNameController.dispose();
    _taglineController.dispose();
    _thresholdController.dispose();
    _deliveryFeeController.dispose();
    _minsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Store Configuration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Manage store policies, delivery limits, fees, and brand identity',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Brand & Identity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  AppTextField(controller: _appNameController, label: 'Store Name'),
                  const SizedBox(height: 12),
                  AppTextField(controller: _taglineController, label: 'Tagline'),
                  const Divider(height: 28),

                  const Text('Delivery & Fees', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _thresholdController,
                          label: 'Free Delivery Threshold (₹)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _deliveryFeeController,
                          label: 'Standard Delivery Fee (₹)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _minsController,
                    label: 'Target Delivery Time (Minutes)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Save Settings',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Store settings saved successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
