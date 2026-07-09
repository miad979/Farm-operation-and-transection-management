import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _acceptedTerms = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _farmNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      if (_isRegistering) {
        if (!_acceptedTerms) {
          setState(() {
            _error =
                'Please accept the Terms & Conditions to create an account.';
          });
          return;
        }
        await authProvider.register(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          farmName: _farmNameController.text.trim(),
        );
      } else {
        await authProvider.login(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _startOfflineMode() async {
    setState(() {
      _error = null;
    });
    try {
      await context.read<AuthProvider>().startOfflineMode();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  void _showTermsSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const _TermsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final pagePadding = screenWidth < 600 ? 16.0 : 24.0;
    final maxContentWidth = (screenWidth - (pagePadding * 2)).clamp(
      0.0,
      1040.0,
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(pagePadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 860;
                  final loginCard = _LoginCard(
                    isRegistering: _isRegistering,
                    isLoading: authProvider.isLoading,
                    error: _error,
                    usernameController: _usernameController,
                    emailController: _emailController,
                    farmNameController: _farmNameController,
                    passwordController: _passwordController,
                    acceptedTerms: _acceptedTerms,
                    onSubmit: _submit,
                    onAcceptedTermsChanged: (value) => setState(() {
                      _acceptedTerms = value;
                      if (value &&
                          _error?.contains('Terms & Conditions') == true) {
                        _error = null;
                      }
                    }),
                    onShowTerms: _showTermsSheet,
                    onStartOfflineMode: _startOfflineMode,
                    onToggleMode: () => setState(() {
                      _isRegistering = !_isRegistering;
                      if (!_isRegistering) {
                        _acceptedTerms = false;
                      }
                      _error = null;
                    }),
                  );

                  if (!wide) {
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _BrandPanel(compact: true),
                          const SizedBox(height: 22),
                          loginCard,
                        ],
                      ),
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(flex: 5, child: _BrandPanel()),
                      const SizedBox(width: 32),
                      Expanded(flex: 4, child: loginCard),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.agriculture, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              'DairyOps',
              style:
                  (compact
                          ? Theme.of(context).textTheme.headlineSmall
                          : Theme.of(context).textTheme.headlineMedium)
                      ?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        SizedBox(height: compact ? 20 : 28),
        Text(
          'Farm control room for milk, herd health, cash flow, and stock.',
          style:
              (compact
                      ? Theme.of(context).textTheme.headlineMedium
                      : Theme.of(context).textTheme.displaySmall)
                  ?.copyWith(fontWeight: FontWeight.w900, height: 1.08),
        ),
        SizedBox(height: compact ? 12 : 16),
        Text(
          'Built for daily decisions: record production, watch profit, spot low stock, and manage animals from one clean workspace.',
          style:
              (compact
                      ? Theme.of(context).textTheme.bodyLarge
                      : Theme.of(context).textTheme.titleMedium)
                  ?.copyWith(color: const Color(0xFF526166), height: 1.35),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _FeatureChip(
              icon: Icons.water_drop_outlined,
              label: 'Milk tracking',
            ),
            _FeatureChip(
              icon: Icons.monitor_heart_outlined,
              label: 'Health alerts',
            ),
            _FeatureChip(icon: Icons.payments_outlined, label: 'Cash flow'),
            _FeatureChip(icon: Icons.inventory_2_outlined, label: 'Feed/stock'),
          ],
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.isRegistering,
    required this.isLoading,
    required this.error,
    required this.usernameController,
    required this.emailController,
    required this.farmNameController,
    required this.passwordController,
    required this.acceptedTerms,
    required this.onSubmit,
    required this.onAcceptedTermsChanged,
    required this.onShowTerms,
    required this.onStartOfflineMode,
    required this.onToggleMode,
  });

  final bool isRegistering;
  final bool isLoading;
  final String? error;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController farmNameController;
  final TextEditingController passwordController;
  final bool acceptedTerms;
  final VoidCallback onSubmit;
  final ValueChanged<bool> onAcceptedTermsChanged;
  final VoidCallback onShowTerms;
  final VoidCallback onStartOfflineMode;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isRegistering ? 'Create Farm Workspace' : 'Sign in to DairyOps',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            if (isRegistering) ...[
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: farmNameController,
                decoration: const InputDecoration(
                  labelText: 'Farm name',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              onSubmitted: (_) => onSubmit(),
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            if (isRegistering) ...[
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8F6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDCE7E2)),
                ),
                child: CheckboxListTile(
                  value: acceptedTerms,
                  onChanged: isLoading
                      ? null
                      : (value) => onAcceptedTermsChanged(value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('I agree to the '),
                      TextButton(
                        onPressed: isLoading ? null : onShowTerms,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Terms & Conditions'),
                      ),
                    ],
                  ),
                  subtitle: const Text(
                    'Required before creating a farm workspace.',
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            if (error != null) const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isLoading ? null : onSubmit,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(isRegistering ? Icons.add_business : Icons.login),
              label: Text(isRegistering ? 'Create account' : 'Login'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: isLoading ? null : onToggleMode,
              child: Text(
                isRegistering
                    ? 'Already have an account? Sign in'
                    : 'New farm? Create an account',
              ),
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: isLoading ? null : onStartOfflineMode,
              icon: const Icon(Icons.phone_android_outlined),
              label: const Text('Use offline on this phone'),
            ),
            const SizedBox(height: 8),
            Text(
              'No internet or account needed. Records stay on this device.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF526166)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsSheet extends StatelessWidget {
  const _TermsSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 620),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.gavel_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Terms & Conditions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'By creating a workspace, you agree to use DairyOps as a farm record and money management tool.',
                ),
                const SizedBox(height: 14),
                const _TermPoint(
                  icon: Icons.edit_note_outlined,
                  title: 'Keep records correct',
                  text:
                      'Milk, sales, expenses, personal money, animals, loans, and stock should be entered honestly and checked regularly.',
                ),
                const _TermPoint(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Separate farm and personal money',
                  text:
                      'Farm cash and personal pocket money are tracked separately. Transfers between them should match real cash movement.',
                ),
                const _TermPoint(
                  icon: Icons.notifications_active_outlined,
                  title: 'Notifications are reminders',
                  text:
                      'Warnings for health, vaccination, loans, and low stock help you notice issues, but final farm decisions are yours.',
                ),
                const _TermPoint(
                  icon: Icons.lock_outline,
                  title: 'Protect your account',
                  text:
                      'Use a strong password and do not share your login. Anyone with access can view or change farm records.',
                ),
                const _TermPoint(
                  icon: Icons.wifi_tethering_outlined,
                  title: 'Server and internet needed',
                  text:
                      'The app needs a working backend server and internet or local network connection to save and load records.',
                ),
                const _TermPoint(
                  icon: Icons.info_outline,
                  title: 'No legal or financial guarantee',
                  text:
                      'Reports are based on your entries and are for management help, not official accounting, tax, medical, or legal advice.',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('I understand'),
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

class _TermPoint extends StatelessWidget {
  const _TermPoint({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF526166),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      side: const BorderSide(color: Color(0xFFD9E1E3)),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
