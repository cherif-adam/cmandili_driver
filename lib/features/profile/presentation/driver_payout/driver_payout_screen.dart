import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../orders/providers/driver_online_provider.dart';
import '../../../orders/providers/driver_orders_provider.dart';
import '../../providers/driver_wallet_provider.dart';
import 'package:cmandili_driver/l10n/app_localizations.dart';
import 'driver_payout_controller.dart';
import 'widgets/deduction_history.dart';
import 'widgets/prepaid_balance_card.dart';

/// Earnings & status: the prepaid balance, what moved it, the online
/// switch, then the bank details. UI only: reading and saving live in
/// [DriverPayoutController].
class DriverPayoutScreen extends ConsumerStatefulWidget {
  const DriverPayoutScreen({super.key});

  @override
  ConsumerState<DriverPayoutScreen> createState() => _DriverPayoutScreenState();
}

class _DriverPayoutScreenState extends ConsumerState<DriverPayoutScreen> {
  /// This screen's own controller (see [driverPayoutControllerProvider]).
  late final _provider = driverPayoutControllerProvider(Object());

  DriverPayoutController get _controller => ref.read(_provider.notifier);

  final _formKey = GlobalKey<FormState>();
  final _bankNameCtrl = TextEditingController();
  final _ibanCtrl = TextEditingController();
  final _accountHolderCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final fields = await _controller.load();
    if (fields != null) {
      _bankNameCtrl.text = fields.bankName;
      _ibanCtrl.text = fields.iban;
      _accountHolderCtrl.text = fields.accountHolder;
    }
    if (mounted) _controller.loaded();
  }

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _ibanCtrl.dispose();
    _accountHolderCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _controller.save(
        bankName: _bankNameCtrl.text,
        iban: _ibanCtrl.text,
        accountHolder: _accountHolderCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.payoutInfoSaved), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(_provider);
    final isOnline = ref.watch(driverOnlineProvider);
    final walletAsync = ref.watch(driverWalletProvider);
    final historyAsync = ref.watch(driverDeliveryHistoryProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.earningsAndStatus, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: s.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Prepaid balance card + low-balance banner
                  walletAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (balance) => PrepaidBalanceCard(balance: balance),
                  ),
                  const SizedBox(height: 20),

                  // Deduction history — explains what's been moving the
                  // balance above, so it sits right next to it rather than
                  // after the unrelated toggle/bank-info sections below.
                  DeductionHistorySection(historyAsync: historyAsync),
                  const SizedBox(height: 20),

                  // Online/Offline toggle
                  _OnlineToggle(isOnline: isOnline, onChanged: (next) => _controller.setOnline(next)),
                  const SizedBox(height: 28),

                  const _PayoutIntro(),
                  const SizedBox(height: 20),

                  _PayoutForm(
                    formKey: _formKey,
                    accountHolder: _accountHolderCtrl,
                    bankName: _bankNameCtrl,
                    iban: _ibanCtrl,
                    saving: s.saving,
                    onSave: _save,
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Sections, in screen order ────────────────────────────────────────────────

class _OnlineToggle extends StatelessWidget {
  const _OnlineToggle({required this.isOnline, required this.onChanged});

  final bool isOnline;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOnline ? Colors.green.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? l.youAreOnline : l.youAreOffline,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isOnline ? Colors.green.shade700 : Colors.grey.shade700,
                  ),
                ),
                Text(
                  isOnline ? l.canReceiveOrders : l.turnOnToReceive,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isOnline,
            activeColor: Colors.green,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PayoutIntro extends StatelessWidget {
  const _PayoutIntro();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.bankPayoutInfo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(l.payoutsWeekly,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _PayoutForm extends StatelessWidget {
  const _PayoutForm({
    required this.formKey,
    required this.accountHolder,
    required this.bankName,
    required this.iban,
    required this.saving,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController accountHolder;
  final TextEditingController bankName;
  final TextEditingController iban;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Form(
      key: formKey,
      child: Column(
        children: [
          _PayoutField(controller: accountHolder, label: l.accountHolderName,
              icon: Icons.person_outline,
              validator: (v) => DriverPayoutController.isMissing(v) ? l.required : null),
          const SizedBox(height: 16),
          _PayoutField(controller: bankName, label: l.bankName,
              icon: Icons.account_balance_outlined,
              validator: (v) => DriverPayoutController.isMissing(v) ? l.required : null),
          const SizedBox(height: 16),
          _PayoutField(controller: iban, label: l.ibanRib,
              icon: Icons.credit_card_outlined,
              validator: (v) => DriverPayoutController.isIbanTooShort(v) ? l.enterValidIban : null),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: saving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: saving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(l.savePayoutInfo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutField extends StatelessWidget {
  const _PayoutField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
