import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/farm_provider.dart';
import '../providers/language_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(lang.text('Summary', 'সারাংশ')),
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
            tabs: [
              Tab(text: lang.text('Farm', 'খামার')),
              Tab(text: lang.text('Borrowed', 'ঋণ')),
              Tab(text: lang.text('Warnings', 'সতর্কতা')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _FarmReportTab(farm: farm),
            _LoanTab(farm: farm),
            _AlertsTab(farm: farm),
          ],
        ),
      ),
    );
  }
}

class _FarmReportTab extends StatelessWidget {
  const _FarmReportTab({required this.farm});

  final FarmProvider farm;

  @override
  Widget build(BuildContext context) {
    final report = farm.monthlyReport;
    final lang = context.watch<LanguageProvider>();
    return RefreshIndicator(
      onRefresh: () async {
        final token = context.read<AuthProvider>().accessToken;
        if (token != null) await context.read<FarmProvider>().loadAll(token);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _WideStat(
            title: lang.text('Profit this month', 'এই মাসের লাভ'),
            value: _money(report['profit']),
            icon: Icons.trending_up,
            color: const Color(0xFF147D64),
          ),
          const SizedBox(height: 10),
          _ReportGrid(
            items: [
              _ReportItem(
                lang.text('Milk', 'দুধ'),
                '${_num(report['milk_liters']).toStringAsFixed(1)} L',
                Icons.water_drop_outlined,
                const Color(0xFF1F6FEB),
              ),
              _ReportItem(
                lang.text('Income', 'আয়'),
                _money(report['income']),
                Icons.payments_outlined,
                const Color(0xFF0F766E),
              ),
              _ReportItem(
                lang.text('Farm cost', 'খামার খরচ'),
                _money(report['business_expenses']),
                Icons.receipt_long_outlined,
                const Color(0xFFDC2626),
              ),
              _ReportItem(
                lang.text('Cash left', 'বাকি নগদ'),
                _money(report['farm_cash']),
                Icons.account_balance_wallet_outlined,
                const Color(0xFF7C3AED),
              ),
              _ReportItem(
                lang.text('Taken money', 'নেওয়া টাকা'),
                _money(report['farm_to_pocket']),
                Icons.swap_horiz_outlined,
                const Color(0xFFB45309),
              ),
              _ReportItem(
                lang.text('Animals', 'পশু'),
                _num(report['animal_count']).toStringAsFixed(0),
                Icons.pets_outlined,
                const Color(0xFF0F766E),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoanTab extends StatelessWidget {
  const _LoanTab({required this.farm});

  final FarmProvider farm;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final summary = farm.loanSummary;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _WideStat(
          title: lang.text('Loan left to pay', 'পরিশোধ বাকি'),
          value: _money(summary['total_outstanding']),
          icon: Icons.account_balance_outlined,
          color: const Color(0xFFB45309),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () => _showLoanSheet(context),
          icon: const Icon(Icons.add),
          label: Text(lang.text('Add borrowed money', 'ঋণ যোগ করুন')),
        ),
        const SizedBox(height: 14),
        if (farm.loans.isEmpty)
          Center(child: Text(lang.text('No loans yet.', 'এখনও ঋণ নেই।')))
        else
          ...farm.loans.map((record) {
            final loan = record as Map<String, dynamic>;
            final loanId = loan['id'] is int
                ? loan['id'] as int
                : int.tryParse('${loan['id']}');
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.account_balance_outlined),
                ),
                title: Text(loan['loan_source']?.toString() ?? 'Loan'),
                subtitle: Text(
                  'Left to pay ${_money(loan['outstanding_amount'])}',
                ),
                trailing: TextButton(
                  onPressed: loanId == null
                      ? null
                      : () => _showLoanPaymentSheet(context, loanId),
                  child: Text(lang.text('Pay', 'পরিশোধ')),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _AlertsTab extends StatelessWidget {
  const _AlertsTab({required this.farm});

  final FarmProvider farm;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    if (farm.notifications.isEmpty) {
      return Center(
        child: Text(
          lang.text('No urgent alerts right now.', 'এখন জরুরি সতর্কতা নেই।'),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: farm.notifications.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final alert = farm.notifications[index] as Map<String, dynamic>;
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFE2E2),
              child: Icon(
                Icons.notifications_active_outlined,
                color: Color(0xFFDC2626),
              ),
            ),
            title: Text('${alert['title'] ?? ''}'),
            subtitle: Text('${alert['message'] ?? ''}'),
          ),
        );
      },
    );
  }
}

class _ReportGrid extends StatelessWidget {
  const _ReportGrid({required this.items});

  final List<_ReportItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 680 ? 3 : 2;
        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 106,
          ),
          itemBuilder: (context, index) => _MiniReportCard(item: items[index]),
        );
      },
    );
  }
}

class _MiniReportCard extends StatelessWidget {
  const _MiniReportCard({required this.item});

  final _ReportItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, color: item.color),
            const Spacer(),
            Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text(
              item.value,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideStat extends StatelessWidget {
  const _WideStat({
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
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
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

class _ReportItem {
  const _ReportItem(this.title, this.value, this.icon, this.color);

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

class _LoanSheet extends StatefulWidget {
  const _LoanSheet();

  @override
  State<_LoanSheet> createState() => _LoanSheetState();
}

class _LoanSheetState extends State<_LoanSheet> {
  final _source = TextEditingController();
  final _amount = TextEditingController();
  final _interest = TextEditingController(text: '0');
  final _months = TextEditingController(text: '12');
  final _installment = TextEditingController(text: '0');

  @override
  void dispose() {
    _source.dispose();
    _amount.dispose();
    _interest.dispose();
    _months.dispose();
    _installment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return _SheetFrame(
      title: lang.text('Add borrowed money', 'ঋণ যোগ করুন'),
      children: [
        _field(_source, lang.text('Who gave money', 'কে টাকা দিয়েছে')),
        _field(_amount, lang.text('Amount borrowed', 'ঋণের টাকা')),
        _field(_interest, lang.text('Interest %', 'সুদের হার')),
        _field(_months, lang.text('Months', 'মাস')),
        _field(_installment, lang.text('Monthly payment', 'মাসিক কিস্তি')),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.check),
          label: Text(lang.text('Save', 'সংরক্ষণ')),
        ),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: label.toLowerCase().contains('source')
            ? TextInputType.text
            : TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().accessToken;
    final amount = double.tryParse(_amount.text.trim());
    if (token == null || amount == null || amount <= 0) return;
    await context.read<FarmProvider>().addLoan(
      token: token,
      loanSource: _source.text.trim(),
      loanAmount: amount,
      interestRate: double.tryParse(_interest.text.trim()) ?? 0,
      tenureMonths: int.tryParse(_months.text.trim()) ?? 12,
      monthlyInstallment: double.tryParse(_installment.text.trim()) ?? 0,
    );
    if (mounted) Navigator.of(context).pop();
  }
}

class _LoanPaymentSheet extends StatefulWidget {
  const _LoanPaymentSheet({required this.loanId});

  final int loanId;

  @override
  State<_LoanPaymentSheet> createState() => _LoanPaymentSheetState();
}

class _LoanPaymentSheetState extends State<_LoanPaymentSheet> {
  final _principal = TextEditingController();
  final _interest = TextEditingController(text: '0');

  @override
  void dispose() {
    _principal.dispose();
    _interest.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return _SheetFrame(
      title: lang.text('Pay borrowed money', 'ঋণ পরিশোধ'),
      children: [
        TextField(
          controller: _principal,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: lang.text('Principal amount', 'মূল টাকা'),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _interest,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: lang.text('Interest amount', 'সুদের টাকা'),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.check),
          label: Text(lang.text('Save payment', 'পেমেন্ট সংরক্ষণ')),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().accessToken;
    final principal = double.tryParse(_principal.text.trim());
    if (token == null || principal == null || principal <= 0) return;
    await context.read<FarmProvider>().payLoan(
      token: token,
      loanId: widget.loanId,
      principalAmount: principal,
      interestAmount: double.tryParse(_interest.text.trim()) ?? 0,
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

Future<void> _showLoanSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _LoanSheet(),
  );
}

Future<void> _showLoanPaymentSheet(BuildContext context, int loanId) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _LoanPaymentSheet(loanId: loanId),
  );
}

num _num(dynamic value) => value is num ? value : num.tryParse('$value') ?? 0;

String _money(dynamic value) => '৳${_num(value).toStringAsFixed(0)}';
