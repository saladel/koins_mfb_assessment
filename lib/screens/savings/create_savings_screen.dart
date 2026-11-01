import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/savings_repository.dart';
import '../../providers/product_provider.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

/// Create a savings plan. Every field is required, per the brief.
class CreateSavingsScreen extends ConsumerStatefulWidget {
  const CreateSavingsScreen({super.key, this.initialProductId});

  /// Pre-selects the product dropdown when arriving from a product details
  /// screen.
  final String? initialProductId;

  @override
  ConsumerState<CreateSavingsScreen> createState() =>
      _CreateSavingsScreenState();
}

class _CreateSavingsScreenState extends ConsumerState<CreateSavingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _contributionController =
      TextEditingController();

  ProductModel? _selectedProduct;
  String? _selectedDuration;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    final String? id = widget.initialProductId;
    if (id == null || id.isEmpty) return;

    // Read, not watch: this only needs to run once.
    for (final ProductModel product in ref.read(productCatalogueProvider)) {
      if (product.id == id) {
        _selectedProduct = product;
        // The options are derived from the catalogue, so this term is always
        // one of them.
        _selectedDuration = product.duration;
        break;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _contributionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedProduct == null || _selectedDuration == null) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(savingsProvider.notifier).createPlan(
            name: _nameController.text,
            productType: _selectedProduct!.name,
            targetAmount: Formatters.parseAmount(_targetController.text),
            monthlyContribution:
                Formatters.parseAmount(_contributionController.text),
            duration: _selectedDuration!,
          );

      if (!mounted) return;

      _showSnack(
        'Savings Created Successfully',
        background: AppColors.success,
        icon: AppIcons.success,
      );
      context.goNamed(AppRoute.dashboard.routeName);
    } on PlanQueuedException catch (error) {
      // The plan is in Hive and queued in the outbox, so this is a warning
      // rather than a failure. Carry on to the dashboard, where the plan
      // shows with a "Pending sync" badge until the POST goes through.
      if (!mounted) return;

      _showSnack(
        error.message,
        background: AppColors.warning,
        icon: AppIcons.refresh,
      );
      context.goNamed(AppRoute.dashboard.routeName);
    } catch (_) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);
      _showSnack(
        'We could not create your plan. Please try again.',
        background: AppColors.error,
        icon: AppIcons.error,
      );
    }
  }

  void _showSnack(
    String message, {
    required Color background,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: background,
          duration: const Duration(seconds: 4),
          content: Row(
            children: <Widget>[
              Icon(icon, color: AppColors.white, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> catalogue = ref.watch(productCatalogueProvider);
    final List<String> durations = ref.watch(durationOptionsProvider);

    // A dropdown asserts if its value is not among its items, and the
    // catalogue can arrive after this form was opened. Falling back to null
    // keeps the field valid; the validator then asks for a fresh selection.
    final ProductModel? selectedProduct =
        catalogue.contains(_selectedProduct) ? _selectedProduct : null;
    final String? selectedDuration =
        durations.contains(_selectedDuration) ? _selectedDuration : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Savings')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: <Widget>[
              Text(
                'Set up a new plan and we will handle the rest.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),

              AppTextField(
                label: 'Savings Name',
                controller: _nameController,
                hintText: 'e.g. Emergency Fund',
                prefixIcon: AppIcons.wallet,
                textInputAction: TextInputAction.next,
                enabled: !_isSubmitting,
                validator: (String? value) => Validators.requiredField(
                  value,
                  label: 'Savings name',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              AppDropdownField<ProductModel>(
                label: 'Product Type',
                hintText: 'Select a savings product',
                prefixIcon: AppIcons.products,
                value: selectedProduct,
                items: catalogue,
                itemLabel: (ProductModel product) =>
                    '${product.name} (${Formatters.percent(product.interestRate)})',
                onChanged: _isSubmitting
                    ? (ProductModel? _) {}
                    : (ProductModel? value) =>
                        setState(() => _selectedProduct = value),
                validator: (ProductModel? value) => Validators.selection(
                  value,
                  label: 'product type',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                label: 'Target Amount',
                controller: _targetController,
                hintText: '500000',
                prefixIcon: AppIcons.deposit,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                enabled: !_isSubmitting,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (String? value) => Validators.amount(
                  value,
                  label: 'Target amount',
                  minimum: _selectedProduct?.minimumDeposit ?? 1000,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                label: 'Monthly Contribution',
                controller: _contributionController,
                hintText: '25000',
                prefixIcon: AppIcons.interest,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                enabled: !_isSubmitting,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (String? value) => Validators.amount(
                  value,
                  label: 'Monthly contribution',
                  minimum: 1000,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              AppDropdownField<String>(
                label: 'Duration',
                hintText: 'Select a duration',
                prefixIcon: AppIcons.duration,
                value: selectedDuration,
                items: durations,
                itemLabel: (String duration) => duration,
                onChanged: _isSubmitting
                    ? (String? _) {}
                    : (String? value) =>
                        setState(() => _selectedDuration = value),
                validator: (String? value) =>
                    Validators.selection(value, label: 'duration'),
              ),

              if (selectedProduct != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: AppRadius.field,
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        AppIcons.interest,
                        size: 20,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Earns ${Formatters.percent(selectedProduct.interestRate)} '
                          'a year. Minimum deposit '
                          '${Formatters.currency(selectedProduct.minimumDeposit)}.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: 'Create',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
