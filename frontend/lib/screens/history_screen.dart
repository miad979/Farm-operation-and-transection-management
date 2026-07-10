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
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final query = _searchController.text.trim().toLowerCase();
    final milkRecords = _filteredRecords(farm.milkRecords, query);
    final sales = _filteredRecords(farm.sales, query);
    final expenses = _filteredRecords(farm.expenses, query);
    final withdrawals = _filteredRecords(farm.withdrawals, query);
    final capital = _filteredRecords(farm.capitalContributions, query);
    final inventory = _filteredRecords(farm.inventory, query);

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(lang.text('History', 'ইতিহাস')),
          actions: [
            TextButton.icon(
              onPressed: lang.toggle,
              icon: const Icon(Icons.translate),
              label: Text(lang.isBangla ? 'English' : 'বাংলা'),
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
              const Tab(text: 'Ledger'),
              Tab(text: lang.text('Milk', 'দুধ')),
              Tab(text: lang.text('Sales', 'বিক্রি')),
              Tab(text: lang.text('Farm Cost', 'খামার খরচ')),
              Tab(text: lang.text('Taken Money', 'নেওয়া টাকা')),
              Tab(text: lang.text('Investment', 'বিনিয়োগ')),
              Tab(text: lang.text('Feed/Stock', 'খাদ্য/স্টক')),
            ],
          ),
        ),
        body: Column(
          children: [
            _HistorySearchBar(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              onClear: () {
                _searchController.clear();
                setState(() {});
              },
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _LedgerTab(farm: farm),
                  _RecordList(
                    records: milkRecords,
                    emptyText: lang.text(
                      'No milk records yet.',
                      'এখনও দুধের রেকর্ড নেই।',
                    ),
                    actionLabel: lang.text('Add milk', 'দুধ যোগ করুন'),
                    onAdd: () => _showMilkSheet(context),
                    builder: (record) => _RecordTile(
                      icon: Icons.water_drop_outlined,
                      title:
                          '${record['animal_name'] ?? lang.text('Animal', 'পশু')}',
                      subtitle:
                          '${record['production_date'] ?? ''} • ${record['quality_grade'] ?? ''}',
                      trailing: '${record['total_milk'] ?? 0} L',
                      onEdit: () => _showMilkSheet(context, record: record),
                      extraActions: [
                        IconButton(
                          tooltip: 'Delete with reason',
                          onPressed: () =>
                              _showDeleteMilkReasonSheet(context, record),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                  _RecordList(
                    records: sales,
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
                    records: expenses,
                    emptyText: lang.text(
                      'No farm costs yet.',
                      'এখনও ব্যবসার খরচ নেই।',
                    ),
                    actionLabel: lang.text(
                      'Add farm cost',
                      'খামার খরচ যোগ করুন',
                    ),
                    onAdd: () => _showExpenseSheet(context),
                    builder: (record) => _RecordTile(
                      icon: Icons.receipt_long_outlined,
                      title:
                          '${record['category'] ?? lang.text('Expense', 'খরচ')}',
                      subtitle:
                          '${record['expense_date'] ?? ''} • ${record['description'] ?? ''}',
                      trailing: _money(record['amount']),
                      onEdit: () => _showExpenseSheet(context, record: record),
                    ),
                  ),
                  _RecordList(
                    records: withdrawals,
                    emptyText: lang.text(
                      'No money taken from farm yet.',
                      'এখনও খামার থেকে পকেটে টাকার রেকর্ড নেই।',
                    ),
                    actionLabel: lang.text('Take money', 'টাকা নিন'),
                    onAdd: () => _showTakenMoneySheet(context),
                    builder: (record) => _RecordTile(
                      icon: Icons.home_work_outlined,
                      title:
                          '${record['reason'] ?? lang.text('Pocket', 'পকেট')}',
                      subtitle:
                          '${record['withdrawal_date'] ?? ''} • ${record['description'] ?? ''}',
                      trailing: _money(record['amount']),
                      onEdit: () =>
                          _showTakenMoneySheet(context, record: record),
                    ),
                  ),
                  _RecordList(
                    records: capital,
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
                      onEdit: () =>
                          _showInvestmentSheet(context, record: record),
                    ),
                  ),
                  _RecordList(
                    records: inventory,
                    emptyText: lang.text(
                      'No stock records yet.',
                      'এখনও স্টক রেকর্ড নেই।',
                    ),
                    actionLabel: lang.text('Add feed/stock', 'খাদ্য/স্টক যোগ'),
                    onAdd: () => _showStockSheet(context),
                    builder: (record) => _RecordTile(
                      icon: Icons.inventory_2_outlined,
                      title:
                          '${record['item_name'] ?? lang.text('Item', 'আইটেম')}',
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
                          icon: const Icon(
                            Icons.indeterminate_check_box_outlined,
                          ),
                        ),
                      ],
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

class _HistorySearchBar extends StatelessWidget {
  const _HistorySearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasQuery = controller.text.trim().isNotEmpty;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: 'Search records',
            hintText: 'Name, date, amount, note',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: hasQuery
                ? IconButton(
                    tooltip: 'Clear search',
                    onPressed: onClear,
                    icon: const Icon(Icons.close),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _LedgerTab extends StatefulWidget {
  const _LedgerTab({required this.farm});

  final FarmProvider farm;

  @override
  State<_LedgerTab> createState() => _LedgerTabState();
}

class _LedgerTabState extends State<_LedgerTab> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final days = DateUtils.getDaysInMonth(_month.year, _month.month);
    final monthSummary = _summaryForMonth(
      widget.farm,
      _month.year,
      _month.month,
    );
    final carryForward = _carryForwardBefore(
      widget.farm,
      _month.year,
      _month.month,
    );
    final monthEndCash = carryForward + monthSummary.farmCash;
    final yearSummary = _summaryForYear(widget.farm, _month.year);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: () => setState(
                () => _month = DateTime(_month.year, _month.month - 1),
              ),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Center(
                child: Text(
                  _monthName(_month),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => setState(
                () => _month = DateTime(_month.year, _month.month + 1),
              ),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _LedgerSummaryGrid(
          items: [
            _LedgerItem('Carry forward', _money(carryForward), Icons.input),
            _LedgerItem(
              'Month cash',
              _money(monthSummary.farmCash),
              Icons.account_balance_wallet_outlined,
            ),
            _LedgerItem(
              'End cash',
              _money(monthEndCash),
              Icons.savings_outlined,
            ),
            _LedgerItem(
              'Milk',
              '${monthSummary.milk.toStringAsFixed(1)} L',
              Icons.water_drop_outlined,
            ),
            _LedgerItem(
              'Personal cash',
              _money(monthSummary.personalCash),
              Icons.person_outline,
            ),
            _LedgerItem(
              'Loan left',
              _money(monthSummary.loanOutstanding),
              Icons.account_balance_outlined,
            ),
          ],
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () =>
              _showCsvSheet(context, widget.farm, _month.year, _month.month),
          icon: const Icon(Icons.download_outlined),
          label: const Text('Export month CSV'),
        ),
        const SizedBox(height: 14),
        Text(
          'Monthly calendar',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            mainAxisExtent: 54,
          ),
          itemBuilder: (context, index) {
            final day = DateTime(_month.year, _month.month, index + 1);
            final summary = _summaryForDay(widget.farm, day);
            final hasProduction = summary.milk > 0;
            final hasMoney =
                summary.income > 0 ||
                summary.expense > 0 ||
                summary.capital > 0 ||
                summary.withdrawal > 0;
            final color = hasProduction
                ? const Color(0xFFE0F2FE)
                : hasMoney
                ? const Color(0xFFEAF7F1)
                : Colors.white;
            return InkWell(
              onTap: () => _showDaySummary(context, day, summary),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD9E1E3)),
                ),
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const Spacer(),
                    Text(
                      '${summary.milk.toStringAsFixed(0)} L',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        Text(
          '${_month.year} month list',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        ...List.generate(12, (index) {
          final month = DateTime(_month.year, index + 1);
          final summary = _summaryForMonth(
            widget.farm,
            month.year,
            month.month,
          );
          return Card(
            child: ListTile(
              title: Text(_monthName(month)),
              subtitle: Text(
                'Milk ${summary.milk.toStringAsFixed(1)} L • Income ${_money(summary.income)} • Cost ${_money(summary.expense)}',
              ),
              trailing: Text(
                _money(
                  _carryForwardBefore(widget.farm, month.year, month.month) +
                      summary.farmCash,
                ),
              ),
              onTap: () => setState(() => _month = month),
            ),
          );
        }),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.calendar_today_outlined),
            ),
            title: Text('${_month.year} yearly overall'),
            subtitle: Text(
              'Milk ${yearSummary.milk.toStringAsFixed(1)} L • Farm cash ${_money(yearSummary.farmCash)} • Personal ${_money(yearSummary.personalCash)}',
            ),
            trailing: Text(_money(yearSummary.income - yearSummary.expense)),
          ),
        ),
      ],
    );
  }
}

class _LedgerSummaryGrid extends StatelessWidget {
  const _LedgerSummaryGrid({required this.items});

  final List<_LedgerItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 88,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(item.icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.value,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LedgerItem {
  const _LedgerItem(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _LedgerSummary {
  const _LedgerSummary({
    this.milk = 0,
    this.income = 0,
    this.expense = 0,
    this.withdrawal = 0,
    this.capital = 0,
    this.personalIncome = 0,
    this.personalExpense = 0,
    this.loanOutstanding = 0,
  });

  final double milk;
  final double income;
  final double expense;
  final double withdrawal;
  final double capital;
  final double personalIncome;
  final double personalExpense;
  final double loanOutstanding;

  double get farmCash => income - expense - withdrawal + capital;
  double get personalCash => withdrawal + personalIncome - personalExpense;
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
  late final TextEditingController _customerName;
  late final TextEditingController _customerPhone;
  late final TextEditingController _paidAmount;
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
    _customerName = TextEditingController(
      text: '${record?['customer_name'] ?? ''}',
    );
    _customerPhone = TextEditingController(
      text: '${record?['customer_phone'] ?? ''}',
    );
    _paidAmount = TextEditingController(
      text: record == null ? '' : '${record['paid_amount'] ?? ''}',
    );
  }

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    _customerName.dispose();
    _customerPhone.dispose();
    _paidAmount.dispose();
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
          decoration: const InputDecoration(labelText: 'What did you sell?'),
          items: const ['milk', 'cattle', 'other']
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(_choiceLabel(item)),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _saleType = value ?? _saleType),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _customerName,
          decoration: const InputDecoration(labelText: 'Customer name'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _customerPhone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Customer phone'),
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
          decoration: const InputDecoration(labelText: 'Bill amount'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _paidAmount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Paid amount',
            helperText: 'Due is bill amount minus paid amount.',
          ),
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
    final paidAmount = double.tryParse(_paidAmount.text.trim()) ?? amount;
    final provider = context.read<FarmProvider>();
    final id = _recordId(widget.record);
    if (id == null) {
      await provider.addSale(
        token: token,
        saleType: _saleType,
        description: _description.text.trim(),
        amount: amount,
        customerName: _customerName.text.trim(),
        customerPhone: _customerPhone.text.trim(),
        paidAmount: paidAmount,
      );
    } else {
      await provider.updateSale(
        token: token,
        saleId: id,
        saleType: _saleType,
        description: _description.text.trim(),
        amount: amount,
        customerName: _customerName.text.trim(),
        customerPhone: _customerPhone.text.trim(),
        paidAmount: paidAmount,
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
          decoration: const InputDecoration(
            labelText: 'What was the cost for?',
          ),
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
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(_choiceLabel(item)),
                    ),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _category = value ?? _category),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _description,
          decoration: const InputDecoration(labelText: 'Short note'),
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
    final rawTotalMilk = record?['total_milk'];
    final totalMilk = rawTotalMilk is num
        ? rawTotalMilk.toDouble()
        : double.tryParse('$rawTotalMilk') ?? 0;
    _morning = TextEditingController(
      text: record == null ? '' : totalMilk.toStringAsFixed(1),
    );
    _evening = TextEditingController(text: '');
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

Future<void> _showDeleteMilkReasonSheet(
  BuildContext context,
  Map<String, dynamic> record,
) async {
  final reason = TextEditingController();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
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
              'Delete milk record',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              '${record['production_date'] ?? ''} • ${record['animal_name'] ?? 'Animal'} • ${record['total_milk'] ?? 0} L',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reason,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason',
                helperText: 'Required so the correction remains recorded.',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                final token = context.read<AuthProvider>().accessToken;
                final recordId = _recordId(record);
                final text = reason.text.trim();
                if (token == null || recordId == null || text.isEmpty) return;
                await context.read<FarmProvider>().deleteMilkRecord(
                  token: token,
                  recordId: recordId,
                  reason: text,
                );
                if (context.mounted) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete and record reason'),
            ),
          ],
        ),
      ),
    ),
  );
  reason.dispose();
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
          decoration: const InputDecoration(labelText: 'Why did you take it?'),
          items:
              const ['household', 'medical', 'education', 'personal', 'other']
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(_choiceLabel(item)),
                    ),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _reason = value ?? _reason),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _description,
          decoration: const InputDecoration(labelText: 'Short note'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'How much went to pocket?',
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
          decoration: const InputDecoration(labelText: 'Who added the money?'),
          items: const ['owner', 'investor', 'partner', 'other']
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(_choiceLabel(item)),
                ),
              )
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
          decoration: const InputDecoration(labelText: 'Why was it added?'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'How much was added?'),
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
          decoration: const InputDecoration(labelText: 'What kind of item?'),
          items: const ['feed', 'medicine', 'equipment', 'other']
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(_choiceLabel(item)),
                ),
              )
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
          decoration: const InputDecoration(labelText: 'Warn me below this'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _dailyUsage,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Used per day',
            helperText: 'The app can reduce this automatically each day.',
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

List<dynamic> _filteredRecords(List<dynamic> records, String query) {
  if (query.isEmpty) return records;
  return records.where((record) {
    if (record is! Map<String, dynamic>) return false;
    return record.values.any((value) => '$value'.toLowerCase().contains(query));
  }).toList();
}

_LedgerSummary _summaryForDay(FarmProvider farm, DateTime day) {
  final date = _dateText(day);
  return _summaryFromRecords(
    milk: farm.milkRecords.where(
      (item) => _field(item, 'production_date') == date,
    ),
    sales: farm.sales.where((item) => _field(item, 'sale_date') == date),
    expenses: farm.expenses.where(
      (item) => _field(item, 'expense_date') == date,
    ),
    withdrawals: farm.withdrawals.where(
      (item) => _field(item, 'withdrawal_date') == date,
    ),
    capital: farm.capitalContributions.where(
      (item) => _field(item, 'contribution_date') == date,
    ),
    personal: farm.personalTransactions.where(
      (item) => _field(item, 'transaction_date') == date,
    ),
    loans: farm.loans,
  );
}

_LedgerSummary _summaryForMonth(FarmProvider farm, int year, int month) {
  return _summaryFromRecords(
    milk: farm.milkRecords.where(
      (item) => _sameMonth(_field(item, 'production_date'), year, month),
    ),
    sales: farm.sales.where(
      (item) => _sameMonth(_field(item, 'sale_date'), year, month),
    ),
    expenses: farm.expenses.where(
      (item) => _sameMonth(_field(item, 'expense_date'), year, month),
    ),
    withdrawals: farm.withdrawals.where(
      (item) => _sameMonth(_field(item, 'withdrawal_date'), year, month),
    ),
    capital: farm.capitalContributions.where(
      (item) => _sameMonth(_field(item, 'contribution_date'), year, month),
    ),
    personal: farm.personalTransactions.where(
      (item) => _sameMonth(_field(item, 'transaction_date'), year, month),
    ),
    loans: farm.loans,
  );
}

_LedgerSummary _summaryForYear(FarmProvider farm, int year) {
  return _summaryFromRecords(
    milk: farm.milkRecords.where(
      (item) => _dateOf(_field(item, 'production_date'))?.year == year,
    ),
    sales: farm.sales.where(
      (item) => _dateOf(_field(item, 'sale_date'))?.year == year,
    ),
    expenses: farm.expenses.where(
      (item) => _dateOf(_field(item, 'expense_date'))?.year == year,
    ),
    withdrawals: farm.withdrawals.where(
      (item) => _dateOf(_field(item, 'withdrawal_date'))?.year == year,
    ),
    capital: farm.capitalContributions.where(
      (item) => _dateOf(_field(item, 'contribution_date'))?.year == year,
    ),
    personal: farm.personalTransactions.where(
      (item) => _dateOf(_field(item, 'transaction_date'))?.year == year,
    ),
    loans: farm.loans,
  );
}

_LedgerSummary _summaryFromRecords({
  required Iterable<dynamic> milk,
  required Iterable<dynamic> sales,
  required Iterable<dynamic> expenses,
  required Iterable<dynamic> withdrawals,
  required Iterable<dynamic> capital,
  required Iterable<dynamic> personal,
  required Iterable<dynamic> loans,
}) {
  final personalIncome = personal.where(
    (item) => _field(item, 'transaction_type') == 'income',
  );
  final personalExpense = personal.where(
    (item) => _field(item, 'transaction_type') == 'expense',
  );
  return _LedgerSummary(
    milk: _sumRecords(milk, 'total_milk'),
    income: _sumRecords(sales, 'total_amount'),
    expense: _sumRecords(expenses, 'amount'),
    withdrawal: _sumRecords(withdrawals, 'amount'),
    capital: _sumRecords(capital, 'amount'),
    personalIncome: _sumRecords(personalIncome, 'amount'),
    personalExpense: _sumRecords(personalExpense, 'amount'),
    loanOutstanding: _sumRecords(loans, 'outstanding_amount'),
  );
}

double _carryForwardBefore(FarmProvider farm, int year, int month) {
  final start = DateTime(year, month);
  final sales = farm.sales.where(
    (item) => (_dateOf(_field(item, 'sale_date')) ?? start).isBefore(start),
  );
  final expenses = farm.expenses.where(
    (item) => (_dateOf(_field(item, 'expense_date')) ?? start).isBefore(start),
  );
  final withdrawals = farm.withdrawals.where(
    (item) =>
        (_dateOf(_field(item, 'withdrawal_date')) ?? start).isBefore(start),
  );
  final capital = farm.capitalContributions.where(
    (item) =>
        (_dateOf(_field(item, 'contribution_date')) ?? start).isBefore(start),
  );
  return _sumRecords(sales, 'total_amount') -
      _sumRecords(expenses, 'amount') -
      _sumRecords(withdrawals, 'amount') +
      _sumRecords(capital, 'amount');
}

void _showDaySummary(
  BuildContext context,
  DateTime day,
  _LedgerSummary summary,
) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _dateText(day),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          _summaryLine(
            'Milk production',
            '${summary.milk.toStringAsFixed(1)} L',
          ),
          _summaryLine('Sales income', _money(summary.income)),
          _summaryLine('Farm cost', _money(summary.expense)),
          _summaryLine('Taken from farm', _money(summary.withdrawal)),
          _summaryLine('Investment', _money(summary.capital)),
          _summaryLine('Personal income', _money(summary.personalIncome)),
          _summaryLine('Personal expense', _money(summary.personalExpense)),
          const Divider(),
          _summaryLine('Farm day cash', _money(summary.farmCash)),
          _summaryLine('Personal day cash', _money(summary.personalCash)),
        ],
      ),
    ),
  );
}

Widget _summaryLine(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    ),
  );
}

void _showCsvSheet(
  BuildContext context,
  FarmProvider farm,
  int year,
  int month,
) {
  final csv = _buildMonthCsv(farm, year, month);
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Month CSV'),
      content: SizedBox(width: 560, child: SelectableText(csv)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

String _buildMonthCsv(FarmProvider farm, int year, int month) {
  final buffer = StringBuffer(
    'date,milk_liters,sales_income,farm_cost,taken_from_farm,investment,personal_income,personal_expense,farm_cash,personal_cash\n',
  );
  final days = DateUtils.getDaysInMonth(year, month);
  for (var day = 1; day <= days; day++) {
    final date = DateTime(year, month, day);
    final summary = _summaryForDay(farm, date);
    buffer.writeln(
      '${_dateText(date)},${summary.milk},${summary.income},${summary.expense},${summary.withdrawal},${summary.capital},${summary.personalIncome},${summary.personalExpense},${summary.farmCash},${summary.personalCash}',
    );
  }
  return buffer.toString();
}

String _field(dynamic record, String key) {
  if (record is Map<String, dynamic>) return '${record[key] ?? ''}';
  return '';
}

double _sumRecords(Iterable<dynamic> records, String key) {
  return records.fold<double>(0, (total, item) {
    if (item is! Map<String, dynamic>) return total;
    final value = item[key];
    if (value is num) return total + value.toDouble();
    return total + (double.tryParse('$value') ?? 0);
  });
}

bool _sameMonth(String value, int year, int month) {
  final date = _dateOf(value);
  return date != null && date.year == year && date.month == month;
}

DateTime? _dateOf(String value) => DateTime.tryParse(value);

String _dateText(DateTime date) => date.toIso8601String().split('T').first;

String _monthName(DateTime date) {
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${names[date.month - 1]} ${date.year}';
}

String _money(dynamic value) {
  final number = value is num ? value : num.tryParse('$value') ?? 0;
  return '৳${number.toStringAsFixed(0)}';
}

String _choiceLabel(String value) {
  return switch (value) {
    'milk' => 'Milk',
    'cattle' => 'Cow / cattle',
    'other' => 'Other',
    'feed' => 'Feed',
    'medicine' => 'Medicine',
    'veterinary' => 'Vet doctor',
    'salary' => 'Worker salary',
    'transport' => 'Transport',
    'electricity' => 'Electricity',
    'maintenance' => 'Repair',
    'miscellaneous' => 'Other cost',
    'household' => 'Family needs',
    'medical' => 'Medical',
    'education' => 'Education',
    'personal' => 'Personal',
    'owner' => 'Owner',
    'investor' => 'Investor',
    'partner' => 'Partner',
    'equipment' => 'Tools/equipment',
    _ => value,
  };
}
