import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/controller/tabs/home_tab_controller.dart';
import 'package:monvexa/models/account_model.dart';

/// Call this function to show the Add Account bottom sheet
void showAddAccountBottomSheet() {
  Get.bottomSheet(
    const _AddAccountSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
  );
}

class _AddAccountSheet extends StatefulWidget {
  const _AddAccountSheet();

  @override
  State<_AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<_AddAccountSheet> {
  final _bankController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedType = 'personal';

  static const _types = ['personal', 'savings', 'business'];
  static const _typeLabels = {
    'personal': 'Personal',
    'savings': 'Savings',
    'business': 'Business',
  };

  @override
  void dispose() {
    _bankController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final bank = _bankController.text.trim();
    final name = _nameController.text.trim();
    if (bank.isEmpty || name.isEmpty) return;

    final account = AccountModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      bankName: bank,
      type: _selectedType,
      address: '',
    );
    HomeTabController.to.addAccount(account);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(28),
        topRight: Radius.circular(28),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottom),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Add Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 20),

              // Bank Name
              const Text('Bank Name',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: _bankController,
                decoration: _inputDecoration('e.g. HDFC Bank'),
              ),
              const SizedBox(height: 16),

              // Account Name
              const Text('Account Name',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration('e.g. Personal Account'),
              ),
              const SizedBox(height: 16),

              // Account Type
              const Text('Account Type',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _types.map((type) {
                  final selected = _selectedType == type;
                  return ChoiceChip(
                    label: Text(_typeLabels[type]!),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => _selectedType = type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Add Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    '+ Add Account',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );
}
