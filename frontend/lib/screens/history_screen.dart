import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/farm_provider.dart';
import '../providers/language_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Text(lang.text('History', 'ইতিহাস')),
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
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: lang.text('Milk', 'দুধ')),
              Tab(text: lang.text('Sales', 'বিক্রি')),
              Tab(text: lang.text('Farm Cost', 'খামার খরচ')),
              Tab(text: lang.text('Taken Money', 'নেওয়া টাকা')),
              Tab(text: lang.text('Investment', 'বিনিয়োগ')),
              Tab(text: lang.text('Feed/Stock', 'খাদ্য/স্টক')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _RecordList(
              records: farm.milkRecords,
              emptyText: lang.text(
                'No milk records yet.',
                'এখনও দুধের রেকর্ড নেই।',
              ),
              actionLabel: lang.text('Add milk', 'দুধ যোগ করুন'),
              onAdd: () => _showMilkSheet(context),
              builder: (record) => _RecordTile(
                icon: Icons.water_drop_outlined,
                title: '${record['animal_name'] ?? lang.text('Animal', 'পশু')}',
                subtitle:
                    '${record['production_date'] ?? ''} • ${record['quality_grade'] ?? ''}',
                trailing: '${record['total_milk'] ?? 0} L',
                onEdit: () => _showMilkSheet(context, record: record),
              ),
            ),
            _RecordList(
              records: farm.sales,
              emptyText: lang.text('No sales yet.', 'এখনও বিক্রি নেই।'),
              actionLabel: lang.text('Add sale', 'বিক্রি যোগ করুন'),
              onAdd: () => _showSaleSheet(context),
              builder: (record) => _RecordTile(
                icon: record['sale_type'] == 'cattle'
                    ? Icons.pets_outlined
                    : Icons.trending_up,
                title:
                    '${record['sale_type'] ?? ''} ${lang.text('sale', 'বিক্রি')}',
                subtitle:
                    '${record['sale_date'] ?? ''} • ${record['description'] ?? ''}',
                trailing: _money(record['total_amount']),
                onEdit: () => _showSaleSheet(context, record: record),
              ),
            ),
            _RecordList(
              records: farm.expenses,
              emptyText: lang.text(
                'No farm costs yet.',
                'এখনও ব্যবসার খরচ নেই।',
              ),
              actionLabel: lang.text('Add farm cost', 'খামার খরচ যোগ করুন'),
              onAdd: () => _showExpenseSheet(context),
              builder: (record) => _RecordTile(
                icon: Icons.receipt_long_outlined,
                title: '${record['category'] ?? lang.text('Expense', 'খরচ')}',
                subtitle:
                    '${record['expense_date'] ?? ''} • ${record['description'] ?? ''}',
                trailing: _money(record['amount']),
                onEdit: () => _showExpenseSheet(context, record: record),
              ),
            ),
            _RecordList(
              records: farm.withdrawals,
              emptyText: lang.text(
                'No money taken from farm yet.',
                'এখনও খামার থেকে পকেটে টাকার রেকর্ড নেই।',
              ),
              actionLabel: lang.text('Take money', 'টাকা নিন'),
              onAdd: () => _showTakenMoneySheet(context),
              builder: (record) => _RecordTile(
                icon: Icons.home_work_outlined,
                title: '${record['reason'] ?? lang.text('Pocket', 'পকেট')}',
                subtitle:
                    '${record['withdrawal_date'] ?? ''} • ${record['description'] ?? ''}',
                trailing: _money(record['amount']),
                onEdit: () => _showTakenMoneySheet(context, record: record),
              ),
            ),
            _RecordList(
              records: farm.capitalContributions,
              emptyText: lang.text(
                'No investment records yet.',
                'এখনও মূলধনের রেকর্ড নেই।',
              ),
              actionLabel: lang.text('Add investment', 'বিনিয়োগ যোগ'),
              onAdd: () => _showInvestmentSheet(context),
              builder: (record) => _RecordTile(
                icon: Icons.savings_outlined,
                title:
                    '${record['source_type'] ?? ''} • ${record['contributor_name'] ?? ''}',
                subtitle:
                    '${record['contribution_date'] ?? ''} • ${record['description'] ?? ''}',
                trailing: _money(record['amount']),
                onEdit: () => _showInvestmentSheet(context, record: record),
              ),
            ),
            _RecordList(
              records: farm.inventory,
              emptyText: lang.text(
                'No stock records yet.',
                'এখনও স্টক রেকর্ড নেই।',
              ),
              actionLabel: lang.text('Add feed/stock', 'খাদ্য/স্টক যোগ'),
              onAdd: () => _showStockSheet(context),
              builder: (record) => _RecordTile(
                icon: Icons.inventory_2_outlined,
                title: '${record['item_name'] ?? lang.text('Item', 'আইটেম')}',
                subtitle:
                    '${record['item_type'] ?? ''} • ${record['quantity'] ?? 0} ${record['unit'] ?? ''} • Daily ${record['daily_usage_quantity'] ?? 0}',
                trailing: 'Warn ${record['reorder_level'] ?? 0}',
                onEdit: () => _showStockSheet(context, record: record),
                extraActions: [
                  IconButton(
                    tooltip: lang.text('Add amount', 'পরিমাণ যোগ'),
                    onPressed: () => _showStockMoveSheet(
                      context,
                      record: record,
                      stockIn: true,
                    ),
                    icon: const Icon(Icons.add_box_outlined),
                  ),
                  IconButton(
                    tooltip: lang.text('Use/remove', 'ব্যবহার/কমাও'),
                    onPressed: () => _showStockMoveSheet(
                      context,
                      record: record,
                      stockIn: false,
                    ),
                    icon: const Icon(Icons.indeterminate_check_box_outlined),
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

class _RecordList extends StatelessWidget {
  const _RecordList({
    required this.records,
    required this.emptyText,
    required this.builder,
    this.actionLabel,
    this.onAdd,
  });

  final List<dynamic> records;
  final String emptyText;
  final Widget Function(Map<String, dynamic> record) builder;
  final String? actionLabel;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emptyText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (actionLabel != null && onAdd != null) ...[
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final token = context.read<AuthProvider>().accessToken;
        if (token != null) {
          await context.read<FarmProvider>().loadAll(token);
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount:
            records.length + (actionLabel != null && onAdd != null ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (actionLabel != null && onAdd != null && index == 0) {
            return FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(actionLabel!),
            );
          }
          final recordIndex =
              index - (actionLabel != null && onAdd != null ? 1 : 0);
          return builder(records[recordIndex] as Map<String, dynamic>);
        },
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onEdit,
    this.extraActions = const [],
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback? onEdit;
  final List<Widget> extraActions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(trailing, style: const TextStyle(fontWeight: FontWeight.w900)),
            if (onEdit != null) ...[
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Edit',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
            ...extraActions,
          ],
        ),
      ),
    );
  }
}

class _SaleSheet extends StatefulWidget {
  const _SaleSheet({this.record});

  final Map<String, dynamic>? record;

  @override
  State<_SaleSheet> createState() => _SaleSheetState();
}

class _SaleSheetState extends State<_SaleSheet> {
  late final TextEditingController _description;
  late final TextEditingController _amount;
  late String _saleType;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _saleType = '${record?['sale_type'] ?? 'milk'}';
    _description = TextEditingController(
      text: '${record?['description'] ?? ''}',
    );
    _amount = TextEditingController(
      text: record == null ? '' : '${record['total_amount'] ?? ''}',
    );
  }

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final editing = widget.record != null;
    return _SheetFrame(
      title: editing
          ? lang.text('Edit sale', 'বিক্রি বদলান')
          : lang.text('Add sale', 'বিক্রি যোগ করুন'),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _saleType,
          decoration: InputDecoration(
            labelText: lang.text('Sale type', 'বিক্রির ধরন'),
          ),
          items: const ['milk', 'cattle', 'other']
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) => setState(() => _saleType = value ?? _saleType),
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
          decoration: InputDecoration(labelText: lang.text('Amount', 'টাকা')),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.check),
          label: Text(lang.text('Save sale', 'বিক্রি সংরক্ষণ')),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().accessToken;
    final amount = double.tryParse(_amount.text.trim());
    if (token == null || amount == null || amount <= 0) return;
    final provider = context.read<FarmProvider>();
    final id = _recordId(widget.record);
    if (id == null) {
      await provider.addSale(
        token: token,
        saleType: _saleType,
        description: _description.text.trim(),
        amount: amount,
      );
    } else {
      await provider.updateSale(
        token: token,
        saleId: id,
        saleType: _saleType,
        description: _description.text.trim(),
        amount: amount,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}

class _ExpenseSheet extends StatefulWidget {
  const _ExpenseSheet({this.record});

  final Map<String, dynamic>? record;

  @override
  State<_ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends State<_ExpenseSheet> {
  late final TextEditingController _description;
  late final TextEditingController _amount;
  late String _category;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _category = '${record?['category'] ?? 'feed'}';
    _description = TextEditingController(
      text: '${record?['description'] ?? ''}',
    );
    _amount = TextEditingController(
      text: record == null ? '' : '${record['amount'] ?? ''}',
    );
  }

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final editing = widget.record != null;
    return _SheetFrame(
      title: editing
          ? lang.text('Edit farm cost', 'খামার খরচ বদলান')
          : lang.text('Add farm cost', 'খামার খরচ যোগ করুন'),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: InputDecoration(labelText: lang.text('Category', 'ধরন')),
          items:
              const [
                    'feed',
                    'medicine',
                    'veterinary',
                    'salary',
                    'transport',
                    'electricity',
                    'maintenance',
                    'miscellaneous',
                  ]
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _category = value ?? _category),
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
          decoration: InputDecoration(labelText: lang.text('Amount', 'টাকা')),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.check),
          label: Text(lang.text('Save expense', 'খরচ সংরক্ষণ')),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().accessToken;
    final amount = double.tryParse(_amount.text.trim());
    if (token == null || amount == null || amount <= 0) return;
    final provider = context.read<FarmProvider>();
    final id = _recordId(widget.record);
    if (id == null) {
      await provider.addExpense(
        token: token,
        category: _category,
        description: _description.text.trim(),
        amount: amount,
      );
    } else {
      await provider.updateExpense(
        token: token,
        expenseId: id,
        category: _category,
        description: _description.text.trim(),
        amount: amount,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}

class _MilkRecordSheet extends StatefulWidget {
  const _MilkRecordSheet({this.record});

  final Map<String, dynamic>? record;

  @override
  State<_MilkRecordSheet> createState() => _MilkRecordSheetState();
}

class _MilkRecordSheetState extends State<_MilkRecordSheet> {
  late final TextEditingController _morning;
  late final TextEditingController _evening;
  int? _animalId;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _animalId = _recordId({'id': record?['animal']});
    _morning = TextEditingController(
      text: record == null ? '' : '${record['morning_milk'] ?? ''}',
    );
    _evening = TextEditingController(
      text: record == null ? '' : '${record['evening_milk'] ?? ''}',
    );
  }

  @override
  void dispose() {
    _morning.dispose();
    _evening.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();
    final lang = context.watch<LanguageProvider>();
    final editing = widget.record != null;
    final animals = farm.animals;
    _animalId ??= animals.isNotEmpty ? animals.first.id : null;

    return _SheetFrame(
      title: editing
          ? lang.text('Edit milk', 'দুধ বদলান')
          : lang.text('Add milk', 'দুধ যোগ করুন'),
      children: [
        if (animals.isEmpty)
          Text(lang.text('Add an animal first.', 'আগে পশু যোগ করুন।'))
        else
          DropdownButtonFormField<int>(
            initialValue: _animalId,
            decoration: InputDecoration(labelText: lang.text('Animal', 'পশু')),
            items: animals
                .map(
                  (animal) => DropdownMenuItem<int>(
                    value: animal.id,
                    child: Text('${animal.name} (${animal.animalIdNumber})'),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _animalId = value),
          ),
        const SizedBox(height: 10),
        TextField(
          controller: _morning,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: lang.text('Morning milk', 'সকালের দুধ'),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _evening,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: lang.text('Evening milk', 'সন্ধ্যার দুধ'),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.check),
          label: Text(lang.text('Save milk', 'দুধ সংরক্ষণ')),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().accessToken;
    final animalId = _animalId;
    final morning = double.tryParse(_morning.text.trim()) ?? 0;
    final evening = double.tryParse(_evening.text.trim()) ?? 0;
    if (token == null || animalId == null || morning + evening <= 0) return;
    final provider = context.read<FarmProvider>();
    final id = _recordId(widget.record);
    if (id == null) {
      await provider.addMilkRecord(
        token: token,
        animalId: animalId,
        morningMilk: morning,
        eveningMilk: evening,
      );
    } else {
      await provider.updateMilkRecord(
        token: token,
        recordId: id,
        animalId: animalId,
        morningMilk: morning,
        eveningMilk: evening,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}

class _TakenMoneySheet extends StatefulWidget {
  const _TakenMoneySheet({this.record});

  final Map<String, dynamic>? record;

  @override
  State<_TakenMoneySheet> createState() => _TakenMoneySheetState();
}

class _TakenMoneySheetState extends State<_TakenMoneySheet> {
  late final TextEditingController _description;
  late final TextEditingController _amount;
  late String _reason;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _reason = '${record?['reason'] ?? 'household'}';
    _description = TextEditingController(
      text: '${record?['description'] ?? ''}',
    );
    _amount = TextEditingController(
      text: record == null ? '' : '${record['amount'] ?? ''}',
    );
  }

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final editing = widget.record != null;
    return _SheetFrame(
      title: editing
          ? lang.text('Edit taken money', 'নেওয়া টাকা বদলান')
          : lang.text('Take money', 'টাকা নিন'),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _reason,
          decoration: InputDecoration(labelText: lang.text('Reason', 'কারণ')),
          items:
              const ['household', 'medical', 'education', 'personal', 'other']
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _reason = value ?? _reason),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _description,
          decoration: InputDecoration(labelText: lang.text('Note', 'নোট')),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: lang.text('Amount', 'টাকা')),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.check),
          label: Text(lang.text('Save', 'সংরক্ষণ')),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().accessToken;
    final amount = double.tryParse(_amount.text.trim());
    if (token == null || amount == null || amount <= 0) return;
    final provider = context.read<FarmProvider>();
    final id = _recordId(widget.record);
    if (id == null) {
      await provider.addFamilyWithdrawal(
        token: token,
        reason: _reason,
        description: _description.text.trim(),
        amount: amount,
      );
    } else {
      await provider.updateFamilyWithdrawal(
        token: token,
        withdrawalId: id,
        reason: _reason,
        description: _description.text.trim(),
        amount: amount,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}

class _InvestmentSheet extends StatefulWidget {
  const _InvestmentSheet({this.record});

  final Map<String, dynamic>? record;

  @override
  State<_InvestmentSheet> createState() => _InvestmentSheetState();
}

class _InvestmentSheetState extends State<_InvestmentSheet> {
  late final TextEditingController _contributor;
  late final TextEditingController _description;
  late final TextEditingController _amount;
  late String _sourceType;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _sourceType = '${record?['source_type'] ?? 'owner'}';
    _contributor = TextEditingController(
      text: '${record?['contributor_name'] ?? ''}',
    );
    _description = TextEditingController(
      text: '${record?['description'] ?? ''}',
    );
    _amount = TextEditingController(
      text: record == null ? '' : '${record['amount'] ?? ''}',
    );
  }

  @override
  void dispose() {
    _contributor.dispose();
    _description.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final editing = widget.record != null;
    return _SheetFrame(
      title: editing
          ? lang.text('Edit investment', 'বিনিয়োগ বদলান')
          : lang.text('Add investment', 'বিনিয়োগ যোগ'),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _sourceType,
          decoration: InputDecoration(
            labelText: lang.text('Money source', 'টাকার উৎস'),
          ),
          items: const ['owner', 'investor', 'partner', 'other']
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) =>
              setState(() => _sourceType = value ?? _sourceType),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _contributor,
          decoration: InputDecoration(labelText: lang.text('Name', 'নাম')),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _description,
          decoration: InputDecoration(labelText: lang.text('Note', 'নোট')),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: lang.text('Amount', 'টাকা')),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.check),
          label: Text(lang.text('Save investment', 'বিনিয়োগ সংরক্ষণ')),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().accessToken;
    final amount = double.tryParse(_amount.text.trim());
    if (token == null || amount == null || amount <= 0) return;
    final provider = context.read<FarmProvider>();
    final id = _recordId(widget.record);
    if (id == null) {
      await provider.addCapitalContribution(
        token: token,
        sourceType: _sourceType,
        contributorName: _contributor.text.trim(),
        description: _description.text.trim(),
        amount: amount,
      );
    } else {
      await provider.updateCapitalContribution(
        token: token,
        contributionId: id,
        sourceType: _sourceType,
        contributorName: _contributor.text.trim(),
        description: _description.text.trim(),
        amount: amount,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}

class _StockSheet extends StatefulWidget {
  const _StockSheet({this.record});

  final Map<String, dynamic>? record;

  @override
  State<_StockSheet> createState() => _StockSheetState();
}

class _StockSheetState extends State<_StockSheet> {
  late final TextEditingController _name;
  late final TextEditingController _quantity;
  late final TextEditingController _unit;
  late final TextEditingController _reorderLevel;
  late final TextEditingController _dailyUsage;
  late String _type;
  late bool _autoDeduct;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _type = '${record?['item_type'] ?? 'feed'}';
    _name = TextEditingController(text: '${record?['item_name'] ?? ''}');
    _quantity = TextEditingController(
      text: record == null ? '' : '${record['quantity'] ?? ''}',
    );
    _unit = TextEditingController(text: '${record?['unit'] ?? 'kg'}');
    _reorderLevel = TextEditingController(
      text: record == null ? '' : '${record['reorder_level'] ?? ''}',
    );
    _dailyUsage = TextEditingController(
      text: record == null ? '' : '${record['daily_usage_quantity'] ?? ''}',
    );
    _autoDeduct = (record?['auto_deduct_enabled'] as bool?) ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _unit.dispose();
    _reorderLevel.dispose();
    _dailyUsage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final editing = widget.record != null;
    return _SheetFrame(
      title: editing
          ? lang.text('Edit feed/stock', 'খাদ্য/স্টক বদলান')
          : lang.text('Add feed/stock', 'খাদ্য/স্টক যোগ'),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _type,
          decoration: InputDecoration(labelText: lang.text('Type', 'ধরন')),
          items: const ['feed', 'medicine', 'equipment', 'other']
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) => setState(() => _type = value ?? _type),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _name,
          decoration: InputDecoration(
            labelText: lang.text('Item name', 'আইটেমের নাম'),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _quantity,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: lang.text('Quantity', 'পরিমাণ'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _unit,
                decoration: InputDecoration(
                  labelText: lang.text('Unit', 'ইউনিট'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _reorderLevel,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: lang.text('Warn when below', 'এর নিচে হলে সতর্ক'),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _dailyUsage,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: lang.text('Used each day', 'প্রতিদিন ব্যবহার'),
          ),
        ),
        SwitchListTile(
          value: _autoDeduct,
          onChanged: (value) => setState(() => _autoDeduct = value),
          title: Text(lang.text('Reduce automatically', 'নিজে নিজে কমবে')),
          subtitle: Text(
            lang.text(
              'The app subtracts the used amount each day.',
              'অ্যাপ প্রতিদিন ব্যবহারের পরিমাণ কমাবে।',
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.check),
          label: Text(lang.text('Save feed/stock', 'খাদ্য/স্টক সংরক্ষণ')),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().accessToken;
    final quantity = double.tryParse(_quantity.text.trim());
    final reorderLevel = double.tryParse(_reorderLevel.text.trim()) ?? 0;
    final dailyUsage = double.tryParse(_dailyUsage.text.trim()) ?? 0;
    if (token == null || quantity == null || _name.text.trim().isEmpty) return;
    final provider = context.read<FarmProvider>();
    final id = _recordId(widget.record);
    if (id == null) {
      await provider.addInventoryItem(
        token: token,
        itemType: _type,
        itemName: _name.text.trim(),
        quantity: quantity,
        unit: _unit.text.trim(),
        reorderLevel: reorderLevel,
        dailyUsageQuantity: dailyUsage,
        autoDeductEnabled: _autoDeduct && dailyUsage > 0,
      );
    } else {
      await provider.updateInventoryItem(
        token: token,
        itemId: id,
        itemType: _type,
        itemName: _name.text.trim(),
        quantity: quantity,
        unit: _unit.text.trim(),
        reorderLevel: reorderLevel,
        dailyUsageQuantity: dailyUsage,
        autoDeductEnabled: _autoDeduct && dailyUsage > 0,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}

class _StockMoveSheet extends StatefulWidget {
  const _StockMoveSheet({required this.record, required this.stockIn});

  final Map<String, dynamic> record;
  final bool stockIn;

  @override
  State<_StockMoveSheet> createState() => _StockMoveSheetState();
}

class _StockMoveSheetState extends State<_StockMoveSheet> {
  final _quantity = TextEditingController();

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return _SheetFrame(
      title: widget.stockIn
          ? lang.text('Add amount', 'পরিমাণ যোগ')
          : lang.text('Use/remove amount', 'ব্যবহার/কমাও'),
      children: [
        Text(
          '${widget.record['item_name'] ?? ''} • ${widget.record['quantity'] ?? 0} ${widget.record['unit'] ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _quantity,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: lang.text('Quantity', 'পরিমাণ'),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.check),
          label: Text(lang.text('Save', 'সংরক্ষণ')),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().accessToken;
    final id = _recordId(widget.record);
    final quantity = double.tryParse(_quantity.text.trim());
    if (token == null || id == null || quantity == null || quantity <= 0) {
      return;
    }
    await context.read<FarmProvider>().moveInventoryStock(
      token: token,
      itemId: id,
      quantity: quantity,
      stockIn: widget.stockIn,
    );
    if (mounted) Navigator.of(context).pop();
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showSaleSheet(
  BuildContext context, {
  Map<String, dynamic>? record,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _SaleSheet(record: record),
  );
}

Future<void> _showExpenseSheet(
  BuildContext context, {
  Map<String, dynamic>? record,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ExpenseSheet(record: record),
  );
}

Future<void> _showMilkSheet(
  BuildContext context, {
  Map<String, dynamic>? record,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _MilkRecordSheet(record: record),
  );
}

Future<void> _showTakenMoneySheet(
  BuildContext context, {
  Map<String, dynamic>? record,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _TakenMoneySheet(record: record),
  );
}

Future<void> _showInvestmentSheet(
  BuildContext context, {
  Map<String, dynamic>? record,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _InvestmentSheet(record: record),
  );
}

Future<void> _showStockSheet(
  BuildContext context, {
  Map<String, dynamic>? record,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _StockSheet(record: record),
  );
}

Future<void> _showStockMoveSheet(
  BuildContext context, {
  required Map<String, dynamic> record,
  required bool stockIn,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _StockMoveSheet(record: record, stockIn: stockIn),
  );
}

int? _recordId(Map<String, dynamic>? record) {
  final value = record?['id'];
  if (value is int) return value;
  return int.tryParse('$value');
}

String _money(dynamic value) {
  final number = value is num ? value : num.tryParse('$value') ?? 0;
  return '৳${number.toStringAsFixed(0)}';
}
