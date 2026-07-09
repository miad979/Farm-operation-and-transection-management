import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/farm_provider.dart';
import '../providers/language_provider.dart';

class PersonalMoneyScreen extends StatefulWidget {
  const PersonalMoneyScreen({super.key});

  @override
  State<PersonalMoneyScreen> createState() => _PersonalMoneyScreenState();
}

class _PersonalMoneyScreenState extends State<PersonalMoneyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final token = context.read<AuthProvider>().accessToken;
    if (token != null) {
      await context.read<FarmProvider>().loadAll(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();
    final lang = context.watch<LanguageProvider>();
    final summary = farm.personalMoneySummary;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.text('My Money', 'আমার টাকা')),
        actions: [
          TextButton.icon(
            onPressed: lang.toggle,
            icon: const Icon(Icons.translate),
            label: Text(lang.isBangla ? 'EN' : 'বাংলা'),
          ),
          IconButton(
            tooltip: lang.text('Refresh', 'রিফ্রেশ'),
            onPressed: farm.isLoading ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _BalanceCard(
              title: lang.text('My cash', 'আমার নগদ'),
              value: _money(summary['personal_balance']),
              icon: Icons.account_balance_wallet_outlined,
              color: const Color(0xFF147D64),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 680;
                final cards = [
                  _MiniMoneyCard(
                    title: lang.text('Taken from farm', 'খামার থেকে নেওয়া'),
                    value: _money(summary['farm_to_pocket']),
                    icon: Icons.swap_horiz_outlined,
                    color: const Color(0xFF1F6FEB),
                  ),
                  _MiniMoneyCard(
                    title: lang.text('Other income', 'অন্য আয়'),
                    value: _money(summary['personal_income']),
                    icon: Icons.add_card_outlined,
                    color: const Color(0xFF0F766E),
                  ),
                  _MiniMoneyCard(
                    title: lang.text('My spending', 'আমার খরচ'),
                    value: _money(summary['personal_expenses']),
                    icon: Icons.shopping_bag_outlined,
                    color: const Color(0xFFDC2626),
                  ),
                ];
                return GridView.builder(
                  itemCount: cards.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: wide ? 3 : 1,
                    mainAxisExtent: 96,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) => cards[index],
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _showPersonalSheet(context, 'income'),
                    icon: const Icon(Icons.add),
                    label: Text(lang.text('Add my money', 'আমার টাকা যোগ')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showPersonalSheet(context, 'expense'),
                    icon: const Icon(Icons.remove),
                    label: Text(lang.text('Add spending', 'খরচ যোগ')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              lang.text('Money history', 'টাকার ইতিহাস'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            if (farm.personalTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    lang.text(
                      'No personal money records yet.',
                      'এখনও ব্যক্তিগত টাকার রেকর্ড নেই।',
                    ),
                  ),
                ),
              )
            else
              ...farm.personalTransactions.map((record) {
                final item = record as Map<String, dynamic>;
                final type = '${item['transaction_type'] ?? ''}';
                final isExpense = type == 'expense';
                final isTransfer = type == 'farm_transfer';
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isExpense
                          ? const Color(0xFFFFE2E2)
                          : const Color(0xFFE4F4EF),
                      child: Icon(
                        isTransfer
                            ? Icons.swap_horiz_outlined
                            : isExpense
                            ? Icons.remove
                            : Icons.add,
                        color: isExpense
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF147D64),
                      ),
                    ),
                    title: Text(
                      isTransfer
                          ? lang.text('Taken from farm', 'খামার থেকে নেওয়া')
                          : '${item['category'] ?? type}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${item['transaction_date'] ?? ''} • ${item['description'] ?? ''}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      '${isExpense ? '-' : '+'} ${_money(item['amount'])}',
                      style: TextStyle(
                        color: isExpense
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF147D64),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
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

class _MiniMoneyCard extends StatelessWidget {
  const _MiniMoneyCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w900),
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

class _PersonalEntrySheet extends StatefulWidget {
  const _PersonalEntrySheet({required this.type});

  final String type;

  @override
  State<_PersonalEntrySheet> createState() => _PersonalEntrySheetState();
}

class _PersonalEntrySheetState extends State<_PersonalEntrySheet> {
  final _amount = TextEditingController();
  final _description = TextEditingController();
  String _category = 'household';

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isIncome = widget.type == 'income';
    final categories = isIncome
        ? const ['salary', 'savings', 'other']
        : const [
            'household',
            'medical',
            'education',
            'food',
            'transport',
            'other',
          ];

    if (!categories.contains(_category)) {
      _category = categories.first;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isIncome
                  ? lang.text('Add my money', 'আমার টাকা যোগ')
                  : lang.text('Add my spending', 'আমার খরচ যোগ'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(
                labelText: lang.text('Category', 'ধরন'),
              ),
              items: categories
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _category = value ?? _category),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _description,
              decoration: InputDecoration(
                labelText: lang.text('Description', 'বিবরণ'),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: lang.text('Amount', 'টাকা'),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(lang.text('Save', 'সংরক্ষণ')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().accessToken;
    final amount = double.tryParse(_amount.text.trim());
    if (token == null || amount == null || amount <= 0) return;

    await context.read<FarmProvider>().addPersonalTransaction(
      token: token,
      transactionType: widget.type,
      category: _category,
      description: _description.text.trim(),
      amount: amount,
    );
    if (mounted) Navigator.of(context).pop();
  }
}

Future<void> _showPersonalSheet(BuildContext context, String type) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _PersonalEntrySheet(type: type),
  );
}

String _money(dynamic value) {
  final number = value is num ? value : num.tryParse('$value') ?? 0;
  return '৳${number.toStringAsFixed(0)}';
}
