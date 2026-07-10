import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/farm_provider.dart';
import '../providers/language_provider.dart';
import 'animals_screen.dart';
import 'history_screen.dart';
import 'personal_money_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().accessToken;
    if (token == null) return;
    final farm = context.read<FarmProvider>();
    await farm.loadAll(token);
    if (!mounted) return;
    if (farm.sessionExpired) {
      await context.read<AuthProvider>().logout();
    }
  }

  void _openProfile() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();
    final auth = context.watch<AuthProvider>();
    final wide = MediaQuery.sizeOf(context).width >= 980;

    return Scaffold(
      appBar: wide
          ? null
          : AppBar(
              title: const Text('DairyOps'),
              actions: [
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: farm.isLoading ? null : _load,
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  tooltip: 'Profile',
                  onPressed: _openProfile,
                  icon: const Icon(Icons.manage_accounts_outlined),
                ),
                IconButton(
                  tooltip: 'Logout',
                  onPressed: auth.logout,
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
      body: Row(
        children: [
          if (wide)
            _SideNav(
              selectedIndex: _selectedIndex,
              onSelect: (index) => setState(() => _selectedIndex = index),
              onProfile: _openProfile,
              onLogout: auth.logout,
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      wide ? 28 : 16,
                      20,
                      wide ? 28 : 16,
                      wide ? 32 : 96,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _Header(
                          isLoading: farm.isLoading,
                          onRefresh: _load,
                          onAddRecord: () => _showQuickRecord(context),
                          onBackup: () => _showBackupSheet(context),
                        ),
                        if (farm.error != null) ...[
                          const SizedBox(height: 12),
                          _ErrorBanner(message: farm.error!, onRetry: _load),
                        ],
                        const SizedBox(height: 18),
                        _KpiGrid(farm: farm),
                        const SizedBox(height: 18),
                        _DashboardBody(farm: farm),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                if (index == 1) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AnimalsScreen()),
                  );
                } else if (index == 2) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PersonalMoneyScreen(),
                    ),
                  );
                } else if (index == 3) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReportsScreen()),
                  );
                } else if (index == 4) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                } else {
                  setState(() => _selectedIndex = index);
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.pets_outlined),
                  label: 'Animals',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  label: 'Personal',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assessment_outlined),
                  label: 'Summary',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  label: 'History',
                ),
              ],
            ),
      floatingActionButton: wide
          ? FloatingActionButton.extended(
              onPressed: () => _showQuickRecord(context),
              icon: const Icon(Icons.add),
              label: const Text('Record'),
            )
          : null,
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.selectedIndex,
    required this.onSelect,
    required this.onProfile,
    required this.onLogout,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onProfile;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 244,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8EA))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.agriculture, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                'DairyOps',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 28),
          NavigationRail(
            selectedIndex: selectedIndex,
            extended: true,
            minExtendedWidth: 212,
            onDestinationSelected: (index) {
              if (index == 1) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AnimalsScreen()),
                );
              } else if (index == 2) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PersonalMoneyScreen(),
                  ),
                );
              } else if (index == 3) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReportsScreen()),
                );
              } else if (index == 4) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              } else {
                onSelect(index);
              }
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.pets_outlined),
                label: Text('Animals'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                label: Text('Personal'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assessment_outlined),
                label: Text('Summary'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.insights_outlined),
                label: Text('History'),
              ),
            ],
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: onProfile,
            icon: const Icon(Icons.manage_accounts_outlined),
            label: const Text('Profile'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.isLoading,
    required this.onRefresh,
    required this.onAddRecord,
    required this.onBackup,
  });

  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onAddRecord;
  final VoidCallback onBackup;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final compactActions = MediaQuery.sizeOf(context).width < 560;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang.text('Farm Dashboard', 'খামার ড্যাশবোর্ড'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lang.text(
                  'Today and month-to-date operating snapshot',
                  'আজ এবং চলতি মাসের খামারের হিসাব',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF526166),
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Refresh',
          onPressed: isLoading ? null : onRefresh,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
        ),
        const SizedBox(width: 10),
        if (compactActions)
          OutlinedButton.icon(
            onPressed: lang.toggle,
            icon: const Icon(Icons.translate, size: 18),
            label: Text(lang.isBangla ? 'English' : 'বাংলা'),
          )
        else
          OutlinedButton.icon(
            onPressed: lang.toggle,
            icon: const Icon(Icons.translate),
            label: Text(lang.isBangla ? 'English' : 'বাংলা'),
          ),
        const SizedBox(width: 10),
        IconButton.outlined(
          tooltip: 'Backup',
          onPressed: onBackup,
          icon: const Icon(Icons.backup_outlined),
        ),
        const SizedBox(width: 10),
        if (compactActions)
          IconButton.filled(
            tooltip: 'Add record',
            onPressed: onAddRecord,
            icon: const Icon(Icons.add),
          )
        else
          FilledButton.icon(
            onPressed: onAddRecord,
            icon: const Icon(Icons.add),
            label: Text(lang.text('Add record', 'রেকর্ড যোগ')),
          ),
      ],
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.farm});

  final FarmProvider farm;

  @override
  Widget build(BuildContext context) {
    final dashboard = farm.dashboard;
    final monthly = farm.monthly;
    final cash = farm.cashFlow;
    final cards = [
      _KpiData(
        'Today profit',
        _money(readNum(dashboard, ['profit'])),
        Icons.trending_up,
        const Color(0xFF147D64),
      ),
      _KpiData(
        'Today milk',
        '${readNum(dashboard, ['milk_production', 'total_liters']).toStringAsFixed(1)} L',
        Icons.water_drop_outlined,
        const Color(0xFF1F6FEB),
      ),
      _KpiData(
        'Farm cash',
        _money(readNum(monthly, ['business_cash'])),
        Icons.account_balance_wallet_outlined,
        const Color(0xFF7C3AED),
      ),
      _KpiData(
        'Available cash',
        _money(readNum(cash, ['available_cash'])),
        Icons.payments_outlined,
        const Color(0xFFB45309),
      ),
      _KpiData(
        'Animals',
        '${farm.totalAnimals}',
        Icons.pets_outlined,
        const Color(0xFF0F766E),
      ),
      _KpiData(
        'Needs attention',
        '${farm.attentionAnimals}',
        Icons.health_and_safety_outlined,
        const Color(0xFFDC2626),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width > 1120
            ? 3
            : width > 680
            ? 2
            : 1;
        return GridView.builder(
          itemCount: cards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: width < 560 ? 92 : 112,
          ),
          itemBuilder: (context, index) => _KpiCard(data: cards[index]),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});

  final _KpiData data;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 560;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 16),
        child: Row(
          children: [
            Container(
              width: compact ? 42 : 48,
              height: compact ? 42 : 48,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(data.icon, color: data.color),
            ),
            SizedBox(width: compact ? 12 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.label,
                    style:
                        (compact
                                ? Theme.of(context).textTheme.bodySmall
                                : Theme.of(context).textTheme.bodyMedium)
                            ?.copyWith(color: const Color(0xFF526166)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.value,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (compact
                                ? Theme.of(context).textTheme.titleLarge
                                : Theme.of(context).textTheme.headlineSmall)
                            ?.copyWith(fontWeight: FontWeight.w900),
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

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.farm});

  final FarmProvider farm;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 980;
        final left = Column(
          children: [
            _MonthlyCalculationPanel(farm: farm),
            const SizedBox(height: 12),
            _CashChart(farm: farm),
            const SizedBox(height: 12),
            _MilkChart(farm: farm),
          ],
        );
        final right = Column(
          children: [
            _ControlPanel(onAddRecord: () => _showQuickRecord(context)),
            const SizedBox(height: 12),
            _CustomerDuePanel(farm: farm),
            const SizedBox(height: 12),
            _HealthPanel(farm: farm),
            const SizedBox(height: 12),
            _InsightsPanel(farm: farm),
            const SizedBox(height: 12),
            _LowStockPanel(farm: farm),
          ],
        );
        if (!wide) {
          return Column(
            children: [
              _ControlPanel(onAddRecord: () => _showQuickRecord(context)),
              const SizedBox(height: 12),
              _CustomerDuePanel(farm: farm),
              const SizedBox(height: 12),
              _MonthlyCalculationPanel(farm: farm),
              const SizedBox(height: 12),
              _CashChart(farm: farm),
              const SizedBox(height: 12),
              _MilkChart(farm: farm),
              const SizedBox(height: 12),
              _HealthPanel(farm: farm),
              const SizedBox(height: 12),
              _InsightsPanel(farm: farm),
              const SizedBox(height: 12),
              _LowStockPanel(farm: farm),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: left),
            const SizedBox(width: 12),
            Expanded(flex: 4, child: right),
          ],
        );
      },
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({required this.onAddRecord});

  final VoidCallback onAddRecord;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final actions = [
      _ControlAction(
        Icons.water_drop_outlined,
        lang.text('Milk', 'দুধ'),
        onAddRecord,
      ),
      _ControlAction(
        Icons.sell_outlined,
        lang.text('Sell', 'বিক্রি'),
        onAddRecord,
      ),
      _ControlAction(
        Icons.receipt_long_outlined,
        lang.text('Spend money', 'খরচ করুন'),
        onAddRecord,
      ),
      _ControlAction(
        Icons.home_work_outlined,
        lang.text('Take to pocket', 'পকেটে নিন'),
        onAddRecord,
      ),
      _ControlAction(
        Icons.savings_outlined,
        lang.text('Add farm money', 'খামারে টাকা যোগ'),
        onAddRecord,
      ),
      _ControlAction(
        Icons.inventory_2_outlined,
        lang.text('Add feed stock', 'খাদ্য যোগ'),
        onAddRecord,
      ),
    ];

    return _Panel(
      title: lang.text('What do you want to record?', 'কোনটি রেকর্ড করবেন?'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 520 ? 3 : 2;
          return GridView.builder(
            itemCount: actions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: constraints.maxWidth > 560 ? 76 : 64,
            ),
            itemBuilder: (context, index) =>
                _ControlTile(action: actions[index]),
          );
        },
      ),
    );
  }
}

class _ControlAction {
  const _ControlAction(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _ControlTile extends StatelessWidget {
  const _ControlTile({required this.action});

  final _ControlAction action;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 560;
    final content = compact
        ? Row(
            children: [
              Icon(action.icon, color: const Color(0xFF147D64), size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  action.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(action.icon, color: const Color(0xFF147D64), size: 21),
              const SizedBox(height: 7),
              Flexible(
                child: Text(
                  action.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          );
    return Material(
      color: const Color(0xFFF7FAF9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD8E5E1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: content,
        ),
      ),
    );
  }
}

class _CustomerDuePanel extends StatelessWidget {
  const _CustomerDuePanel({required this.farm});

  final FarmProvider farm;

  @override
  Widget build(BuildContext context) {
    final dues = <String, _CustomerDue>{};
    for (final sale in farm.sales) {
      final total = valueNum(sale['total_amount']);
      final paid = sale.containsKey('paid_amount')
          ? valueNum(sale['paid_amount'])
          : total;
      final due = sale.containsKey('due_amount')
          ? valueNum(sale['due_amount'])
          : math.max(total - paid, 0);
      if (due <= 0) continue;

      final rawName = '${sale['customer_name'] ?? ''}'.trim();
      final name = rawName.isEmpty ? 'Customer due' : rawName;
      final phone = '${sale['customer_phone'] ?? ''}'.trim();
      final row = dues.putIfAbsent(name, () => _CustomerDue(name, phone));
      row.amount += due;
      row.bills += 1;
      if (row.phone.isEmpty && phone.isNotEmpty) row.phone = phone;
    }

    final rows = dues.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final totalDue = rows.fold<num>(0, (sum, row) => sum + row.amount);

    return _Panel(
      title: 'Customer dues',
      action: Text(
        _money(totalDue),
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      child: rows.isEmpty
          ? const _EmptyPanelMessage(
              icon: Icons.verified_outlined,
              message: 'No unpaid customer bills',
            )
          : Column(
              children: [
                for (final row in rows.take(4)) ...[
                  _DueRow(row: row),
                  if (row != rows.take(4).last) const Divider(height: 14),
                ],
              ],
            ),
    );
  }
}

class _CustomerDue {
  _CustomerDue(this.name, this.phone);

  final String name;
  String phone;
  num amount = 0;
  int bills = 0;
}

class _DueRow extends StatelessWidget {
  const _DueRow({required this.row});

  final _CustomerDue row;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.person_pin_circle_outlined,
            color: Color(0xFFB45309),
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                row.phone.isEmpty
                    ? '${row.bills} unpaid bill${row.bills == 1 ? '' : 's'}'
                    : row.phone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF526166)),
              ),
            ],
          ),
        ),
        Text(
          _money(row.amount),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _EmptyPanelMessage extends StatelessWidget {
  const _EmptyPanelMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF147D64)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Color(0xFF526166),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthlyCalculationPanel extends StatelessWidget {
  const _MonthlyCalculationPanel({required this.farm});

  final FarmProvider farm;

  @override
  Widget build(BuildContext context) {
    final income = readNum(farm.monthly, ['income', 'total']);
    final businessExpense = readNum(farm.monthly, ['expenses', 'total']);
    final profit = readNum(farm.monthly, ['profit']);
    final capital = readNum(farm.monthly, ['capital_added']);
    final farmToPocket =
        readNum(farm.monthly, ['farm_to_pocket']) +
        (farm.monthly.containsKey('farm_to_pocket')
            ? 0
            : readNum(farm.monthly, ['family_withdrawals']));
    final businessCash = readNum(farm.monthly, ['business_cash']);
    final milk = readNum(farm.monthly, ['milk_production', 'total_liters']);
    final avgMilk = readNum(farm.monthly, ['milk_production', 'average_daily']);

    return _Panel(
      title: 'This month money',
      action: Text(
        '${farm.monthly['month'] ?? '-'} / ${farm.monthly['year'] ?? '-'}',
        style: const TextStyle(
          color: Color(0xFF526166),
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Column(
        children: [
          _FormulaRow(
            label: 'Sales money',
            value: _money(income),
            icon: Icons.trending_up,
            color: const Color(0xFF147D64),
          ),
          _FormulaRow(
            label: 'Farm cost',
            value: '- ${_money(businessExpense)}',
            icon: Icons.trending_down,
            color: const Color(0xFFDC2626),
          ),
          const Divider(height: 18),
          _FormulaRow(
            label: 'Farm profit',
            value: _money(profit),
            icon: Icons.functions,
            color: const Color(0xFF1F6FEB),
            emphasized: true,
          ),
          _FormulaRow(
            label: 'Taken from farm',
            value: '- ${_money(farmToPocket)}',
            icon: Icons.home_work_outlined,
            color: const Color(0xFFB45309),
          ),
          _FormulaRow(
            label: 'Added investment',
            value: '+ ${_money(capital)}',
            icon: Icons.savings_outlined,
            color: const Color(0xFF0F766E),
          ),
          const Divider(height: 18),
          _FormulaRow(
            label: 'Farm cash left',
            value: _money(businessCash),
            icon: Icons.account_balance_wallet_outlined,
            color: const Color(0xFF7C3AED),
            emphasized: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Monthly milk',
                  value: '${milk.toStringAsFixed(1)} L',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Daily average',
                  value: '${avgMilk.toStringAsFixed(1)} L',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormulaRow extends StatelessWidget {
  const _FormulaRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final textStyle = emphasized
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)
        : Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text(value, style: textStyle),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F8),
        border: Border.all(color: const Color(0xFFE2E8EA)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF526166))),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _CashChart extends StatelessWidget {
  const _CashChart({required this.farm});

  final FarmProvider farm;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 560;
    final income = readNum(farm.monthly, ['income', 'total']);
    final expenses = readNum(farm.monthly, ['expenses', 'total']);
    final withdrawals =
        readNum(farm.monthly, ['farm_to_pocket']) +
        (farm.monthly.containsKey('farm_to_pocket')
            ? 0
            : readNum(farm.monthly, ['family_withdrawals']));
    if (compact) {
      return _Panel(
        title: 'Money summary',
        action: Text(
          _money(readNum(farm.monthly, ['profit'])),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        child: Column(
          children: [
            _FormulaRow(
              label: 'Sales',
              value: _money(income),
              icon: Icons.trending_up,
              color: const Color(0xFF147D64),
            ),
            _FormulaRow(
              label: 'Costs',
              value: _money(expenses),
              icon: Icons.trending_down,
              color: const Color(0xFFDC2626),
            ),
            _FormulaRow(
              label: 'Taken',
              value: _money(withdrawals),
              icon: Icons.home_work_outlined,
              color: const Color(0xFFB45309),
            ),
          ],
        ),
      );
    }
    final maxY = math.max(
      100,
      [income, expenses, withdrawals].reduce(math.max) * 1.25,
    );
    return _Panel(
      title: 'Money chart',
      action: Text(
        _money(readNum(farm.monthly, ['profit'])),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      child: SizedBox(
        height: compact ? 180 : 260,
        child: BarChart(
          BarChartData(
            maxY: maxY.toDouble(),
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: _cashTitle,
                ),
              ),
            ),
            barGroups: [
              _bar(0, income, const Color(0xFF147D64)),
              _bar(1, expenses, const Color(0xFFDC2626)),
              _bar(2, withdrawals, const Color(0xFFB45309)),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _cashTitle(double value, TitleMeta meta) {
    const labels = ['Sales', 'Cost', 'Taken'];
    final index = value.toInt();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        index >= 0 && index < labels.length ? labels[index] : '',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  BarChartGroupData _bar(int x, num y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          color: color,
          width: 34,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }
}

class _MilkChart extends StatelessWidget {
  const _MilkChart({required this.farm});

  final FarmProvider farm;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 560;
    final today = readNum(farm.dashboard, ['milk_production', 'total_liters']);
    final average = readNum(farm.dashboard, [
      'milk_production',
      'average_per_cow',
    ]);
    final monthlyAverage = readNum(farm.monthly, [
      'milk_production',
      'average_daily',
    ]);
    final points = [
      average,
      today,
      monthlyAverage,
      math.max(today, monthlyAverage) * 1.08,
    ];
    if (compact) {
      return _Panel(
        title: 'Milk summary',
        action: Text(
          '${today.toStringAsFixed(1)} L today',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        child: Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'Per cow',
                value: '${average.toStringAsFixed(1)} L',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStat(
                label: 'Monthly avg',
                value: '${monthlyAverage.toStringAsFixed(1)} L',
              ),
            ),
          ],
        ),
      );
    }
    return _Panel(
      title: 'Production rhythm',
      action: Text(
        '${today.toStringAsFixed(1)} L today',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      child: SizedBox(
        height: compact ? 172 : 238,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: math.max(10, points.reduce(math.max)).toDouble(),
            gridData: const FlGridData(drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(0, points[0].toDouble()),
                  FlSpot(1, points[1].toDouble()),
                  FlSpot(2, points[2].toDouble()),
                  FlSpot(3, points[3].toDouble()),
                ],
                isCurved: true,
                color: const Color(0xFF1F6FEB),
                barWidth: 4,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFF1F6FEB).withValues(alpha: .12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthPanel extends StatelessWidget {
  const _HealthPanel({required this.farm});

  final FarmProvider farm;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 560;
    final healthy = farm.healthyAnimals;
    final attention = math.max(0, farm.totalAnimals - healthy);
    return _Panel(
      title: 'Herd condition',
      child: SizedBox(
        height: compact ? 174 : 224,
        child: Row(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 44,
                  sections: [
                    PieChartSectionData(
                      value: healthy.toDouble(),
                      title: '$healthy',
                      color: const Color(0xFF147D64),
                      radius: 46,
                    ),
                    PieChartSectionData(
                      value: attention.toDouble(),
                      title: '$attention',
                      color: const Color(0xFFDC2626),
                      radius: 46,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Legend(
                    color: const Color(0xFF147D64),
                    label: 'Healthy',
                    value: '$healthy',
                  ),
                  const SizedBox(height: 12),
                  _Legend(
                    color: const Color(0xFFDC2626),
                    label: 'Attention',
                    value: '$attention',
                  ),
                  const SizedBox(height: 12),
                  _Legend(
                    color: const Color(0xFF1F6FEB),
                    label: 'Vaccinated',
                    value: '${farm.animalStats['vaccinated'] ?? 0}',
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

class _InsightsPanel extends StatelessWidget {
  const _InsightsPanel({required this.farm});

  final FarmProvider farm;

  @override
  Widget build(BuildContext context) {
    final insights = farm.insights.cast<Map<String, dynamic>>();
    return _Panel(
      title: 'Helpful tips',
      child: Column(
        children: insights.isEmpty
            ? [
                _InsightTile(
                  icon: Icons.lightbulb_outline,
                  title: 'Ready for records',
                  message:
                      'Add milk, sales, expenses, and animals to unlock trend insights.',
                ),
              ]
            : insights
                  .map(
                    (insight) => _InsightTile(
                      icon: insight['status'] == 'warning'
                          ? Icons.warning_amber
                          : Icons.auto_graph,
                      title: '${insight['title'] ?? 'Insight'}',
                      message: '${insight['message'] ?? ''}',
                    ),
                  )
                  .toList(),
      ),
    );
  }
}

class _LowStockPanel extends StatelessWidget {
  const _LowStockPanel({required this.farm});

  final FarmProvider farm;

  @override
  Widget build(BuildContext context) {
    final items = farm.lowStock.cast<Map<String, dynamic>>();
    return _Panel(
      title: 'Feed/stock warning',
      child: Column(
        children: items.isEmpty
            ? [
                _InsightTile(
                  icon: Icons.inventory_2_outlined,
                  title: 'Stock is okay',
                  message: 'No feed or stock is below its warning amount.',
                ),
              ]
            : items.take(4).map((item) {
                return _InsightTile(
                  icon: Icons.warning_amber,
                  title: '${item['item_name'] ?? 'Feed/stock item'}',
                  message:
                      '${item['quantity'] ?? 0} ${item['unit'] ?? ''} left',
                );
              }).toList(),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.action});

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                ?action,
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(icon, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(message, style: const TextStyle(color: Color(0xFF526166))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _KpiData {
  const _KpiData(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

num readNum(Map<String, dynamic> source, List<String> path) {
  dynamic value = source;
  for (final key in path) {
    if (value is! Map<String, dynamic>) return 0;
    value = value[key];
  }
  return valueNum(value);
}

num valueNum(dynamic value) {
  if (value is num) return value;
  return num.tryParse('$value') ?? 0;
}

String _money(num value) => '৳${value.toStringAsFixed(0)}';

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

Future<void> _showQuickRecord(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _QuickRecordSheet(),
  );
}

Future<void> _showBackupSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _BackupSheet(),
  );
}

class _BackupSheet extends StatefulWidget {
  const _BackupSheet();

  @override
  State<_BackupSheet> createState() => _BackupSheetState();
}

class _BackupSheetState extends State<_BackupSheet> {
  final _backupText = TextEditingController();
  String? _message;

  @override
  void dispose() {
    _backupText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final offline = auth.isOfflineMode;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Backup & restore',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                offline
                    ? 'Copy your offline records and save them somewhere safe. Paste a backup here to restore on this phone.'
                    : 'Online records are saved on your backend. Phone backup is available when using offline mode.',
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: offline ? _copyBackup : null,
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Copy backup'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _backupText,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Paste backup text here',
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: offline ? _pasteFromClipboard : null,
                icon: const Icon(Icons.content_paste_outlined),
                label: const Text('Paste from clipboard'),
              ),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: offline ? _restoreBackup : null,
                icon: const Icon(Icons.restore_outlined),
                label: const Text('Restore backup'),
              ),
              if (_message != null) ...[
                const SizedBox(height: 10),
                Text(_message!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copyBackup() async {
    final token = context.read<AuthProvider>().accessToken;
    if (token == null) return;
    final backup = await context.read<FarmProvider>().exportOfflineBackup(
      token,
    );
    await Clipboard.setData(ClipboardData(text: backup));
    setState(
      () => _message =
          'Backup copied. Save it in Drive, Notes, or another safe place.',
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    _backupText.text = data?.text ?? '';
  }

  Future<void> _restoreBackup() async {
    final token = context.read<AuthProvider>().accessToken;
    if (token == null || _backupText.text.trim().isEmpty) return;
    try {
      await context.read<FarmProvider>().importOfflineBackup(
        token: token,
        backupText: _backupText.text.trim(),
      );
      if (mounted) setState(() => _message = 'Backup restored successfully.');
    } catch (e) {
      if (mounted) setState(() => _message = 'Restore failed: $e');
    }
  }
}

class _QuickRecordSheet extends StatefulWidget {
  const _QuickRecordSheet();

  @override
  State<_QuickRecordSheet> createState() => _QuickRecordSheetState();
}

class _RecordTypeGrid extends StatelessWidget {
  const _RecordTypeGrid({required this.selectedType, required this.onSelected});

  final String selectedType;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final options = [
      _RecordTypeOption(
        'milk',
        Icons.water_drop_outlined,
        lang.text('Milk', 'দুধ'),
      ),
      _RecordTypeOption(
        'sale',
        Icons.sell_outlined,
        lang.text('Sale', 'বিক্রি'),
      ),
      _RecordTypeOption(
        'expense',
        Icons.receipt_long_outlined,
        lang.text('Spend money', 'খরচ করুন'),
      ),
      _RecordTypeOption(
        'personal',
        Icons.home_work_outlined,
        lang.text('Take to pocket', 'পকেটে নিন'),
      ),
      _RecordTypeOption(
        'capital',
        Icons.savings_outlined,
        lang.text('Add farm money', 'খামারে টাকা যোগ'),
      ),
      _RecordTypeOption(
        'inventory',
        Icons.inventory_2_outlined,
        lang.text('Add feed stock', 'খাদ্য যোগ'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 460 ? 3 : 2;
        return GridView.builder(
          itemCount: options.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 70,
          ),
          itemBuilder: (context, index) {
            final option = options[index];
            return _RecordTypeTile(
              option: option,
              selected: selectedType == option.value,
              onTap: () => onSelected(option.value),
            );
          },
        );
      },
    );
  }
}

class _RecordTypeOption {
  const _RecordTypeOption(this.value, this.icon, this.label);

  final String value;
  final IconData icon;
  final String label;
}

class _RecordTypeTile extends StatelessWidget {
  const _RecordTypeTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _RecordTypeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF147D64) : const Color(0xFF536462);
    return Material(
      color: selected ? const Color(0xFFE4F4EF) : const Color(0xFFF7FAF9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected
                  ? const Color(0xFF147D64)
                  : const Color(0xFFD8E5E1),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(option.icon, color: color, size: 21),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  option.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? const Color(0xFF0F4C3D) : Colors.black87,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF147D64),
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickRecordSheetState extends State<_QuickRecordSheet> {
  final _description = TextEditingController();
  final _amount = TextEditingController();
  final _customerName = TextEditingController();
  final _customerPhone = TextEditingController();
  final _paidAmount = TextEditingController();
  final _morningMilk = TextEditingController();
  final _eveningMilk = TextEditingController();
  final _itemName = TextEditingController();
  final _quantity = TextEditingController();
  final _unit = TextEditingController(text: 'kg');
  final _reorderLevel = TextEditingController();
  final _dailyUsage = TextEditingController();
  final _contributorName = TextEditingController();
  String _type = 'milk';
  String _category = 'feed';
  String _saleType = 'milk';
  String _reason = 'household';
  String _itemType = 'feed';
  String _capitalSource = 'owner';
  int? _animalId;

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    _customerName.dispose();
    _customerPhone.dispose();
    _paidAmount.dispose();
    _morningMilk.dispose();
    _eveningMilk.dispose();
    _itemName.dispose();
    _quantity.dispose();
    _unit.dispose();
    _reorderLevel.dispose();
    _dailyUsage.dispose();
    _contributorName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _sheetTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              _RecordTypeGrid(
                selectedType: _type,
                onSelected: (value) => setState(() => _type = value),
              ),
              const SizedBox(height: 12),
              if (_type == 'milk') ..._milkFields(farm),
              if (_type == 'sale') ..._saleFields(),
              if (_type == 'expense') ..._expenseFields(),
              if (_type == 'personal') ..._personalFields(),
              if (_type == 'capital') ..._capitalFields(),
              if (_type == 'inventory') ..._inventoryFields(),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: Text(_buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _milkFields(FarmProvider farm) {
    final animals = farm.animals;
    return [
      if (animals.isEmpty)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFED7AA)),
          ),
          child: const Text(
            'Add an animal first, then record milk production.',
          ),
        )
      else
        DropdownButtonFormField<int>(
          initialValue: _animalId,
          decoration: const InputDecoration(labelText: 'Animal'),
          hint: const Text('Select animal'),
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
      const SizedBox(height: 12),
      TextField(
        controller: _morningMilk,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Actual milk today (L)',
          helperText:
              'Only enter this when today is different from the cow normal milk.',
        ),
      ),
    ];
  }

  List<Widget> _saleFields() {
    final farm = context.read<FarmProvider>();
    final activeAnimals = farm.animals
        .where((animal) => animal.isActive)
        .toList();
    return [
      _select(
        label: 'What did you sell?',
        value: _saleType,
        items: const ['milk', 'cattle', 'other'],
        onChanged: (value) => setState(() => _saleType = value),
      ),
      if (_saleType == 'cattle') ...[
        const SizedBox(height: 12),
        if (activeAnimals.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: const Text('No active animals available to sell.'),
          )
        else
          DropdownButtonFormField<int>(
            initialValue: _animalId,
            decoration: const InputDecoration(labelText: 'Animal sold'),
            hint: const Text('Select cow/animal'),
            items: activeAnimals
                .map(
                  (animal) => DropdownMenuItem<int>(
                    value: animal.id,
                    child: Text('${animal.name} (${animal.animalIdNumber})'),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _animalId = value),
          ),
      ],
      const SizedBox(height: 12),
      _descriptionField(_saleType == 'cattle' ? 'Buyer or note' : 'Short note'),
      const SizedBox(height: 12),
      TextField(
        controller: _customerName,
        decoration: const InputDecoration(labelText: 'Customer name'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _customerPhone,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: 'Customer phone'),
      ),
      const SizedBox(height: 12),
      _amountField(_saleType == 'cattle' ? 'Cow sale amount' : 'Bill amount'),
      const SizedBox(height: 12),
      TextField(
        controller: _paidAmount,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Paid now',
          helperText: 'Leave empty when the full bill is paid.',
        ),
      ),
    ];
  }

  List<Widget> _expenseFields() {
    return [
      _select(
        label: 'What was the cost for?',
        value: _category,
        items: const [
          'feed',
          'medicine',
          'veterinary',
          'salary',
          'transport',
          'electricity',
          'maintenance',
          'miscellaneous',
        ],
        onChanged: (value) => setState(() => _category = value),
      ),
      const SizedBox(height: 12),
      _descriptionField('Short note'),
      const SizedBox(height: 12),
      _amountField('How much was spent?'),
    ];
  }

  List<Widget> _personalFields() {
    return [
      _select(
        label: 'Why did you take it?',
        value: _reason,
        items: const ['household', 'medical', 'education', 'personal', 'other'],
        onChanged: (value) => setState(() => _reason = value),
      ),
      const SizedBox(height: 12),
      _descriptionField('Short note'),
      const SizedBox(height: 12),
      _amountField('How much went to pocket?'),
    ];
  }

  List<Widget> _capitalFields() {
    return [
      _select(
        label: 'Who added the money?',
        value: _capitalSource,
        items: const ['owner', 'investor', 'partner', 'other'],
        onChanged: (value) => setState(() => _capitalSource = value),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _contributorName,
        decoration: InputDecoration(
          labelText: _capitalSource == 'owner'
              ? 'Owner name'
              : 'Investor / partner name',
        ),
      ),
      const SizedBox(height: 12),
      _descriptionField('Why was it added?'),
      const SizedBox(height: 12),
      _amountField('How much was added?'),
    ];
  }

  List<Widget> _inventoryFields() {
    return [
      _select(
        label: 'What kind of item?',
        value: _itemType,
        items: const ['feed', 'medicine', 'equipment', 'other'],
        onChanged: (value) => setState(() => _itemType = value),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _itemName,
        decoration: const InputDecoration(labelText: 'Feed/item name'),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _quantity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Current amount'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _unit,
              decoration: const InputDecoration(labelText: 'Unit'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _reorderLevel,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Warn me below this'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _dailyUsage,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Used per day',
          helperText: 'The app can reduce this automatically each day.',
        ),
      ),
    ];
  }

  Widget _select({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (item) =>
                DropdownMenuItem(value: item, child: Text(_choiceLabel(item))),
          )
          .toList(),
      onChanged: (value) => onChanged(value ?? items.first),
    );
  }

  Widget _descriptionField(String label) {
    return TextField(
      controller: _description,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _amountField(String label) {
    return TextField(
      controller: _amount,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }

  String get _sheetTitle {
    return switch (_type) {
      'milk' => 'Record milk',
      'sale' => 'Record a sale',
      'personal' => 'Take money to pocket',
      'expense' => 'Record farm spending',
      'capital' => 'Add money to farm',
      'inventory' => 'Add feed or stock',
      _ => 'Add record',
    };
  }

  String get _buttonLabel {
    return switch (_type) {
      'milk' => 'Save milk',
      'personal' => 'Save pocket money',
      'expense' => 'Save spending',
      'capital' => 'Save farm money',
      'inventory' => 'Save stock',
      _ => 'Save sale',
    };
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().accessToken;
    if (token == null) return;
    final provider = context.read<FarmProvider>();

    if (_type == 'milk') {
      final animals = provider.animals;
      final animalId =
          _animalId ?? (animals.isNotEmpty ? animals.first.id : null);
      final totalMilk = double.tryParse(_morningMilk.text.trim()) ?? 0;
      if (animalId == null || totalMilk <= 0) return;
      await provider.addMilkRecord(
        token: token,
        animalId: animalId,
        morningMilk: totalMilk,
        eveningMilk: 0,
      );
    } else if (_type == 'inventory') {
      final quantity = double.tryParse(_quantity.text.trim());
      final reorderLevel = double.tryParse(_reorderLevel.text.trim()) ?? 0;
      final dailyUsage = double.tryParse(_dailyUsage.text.trim()) ?? 0;
      if (quantity == null || _itemName.text.trim().isEmpty) return;
      await provider.addInventoryItem(
        token: token,
        itemType: _itemType,
        itemName: _itemName.text.trim(),
        quantity: quantity,
        unit: _unit.text.trim(),
        reorderLevel: reorderLevel,
        dailyUsageQuantity: dailyUsage,
        autoDeductEnabled: dailyUsage > 0,
      );
    } else if (_type == 'capital') {
      final amount = double.tryParse(_amount.text.trim());
      if (amount == null) return;
      await provider.addCapitalContribution(
        token: token,
        sourceType: _capitalSource,
        contributorName: _contributorName.text.trim(),
        description: _description.text.trim(),
        amount: amount,
      );
    } else {
      final amount = double.tryParse(_amount.text.trim());
      if (amount == null) return;
      if (_type == 'sale') {
        final paidAmount = double.tryParse(_paidAmount.text.trim()) ?? amount;
        if (_saleType == 'cattle') {
          final activeAnimals = provider.animals
              .where((animal) => animal.isActive)
              .toList();
          final animalId =
              _animalId ??
              (activeAnimals.isNotEmpty ? activeAnimals.first.id : null);
          if (animalId == null) return;
          await provider.sellAnimal(
            token: token,
            animalId: animalId,
            description: _description.text.trim().isEmpty
                ? 'Cattle sale'
                : _description.text.trim(),
            amount: amount,
            customerName: _customerName.text.trim(),
            customerPhone: _customerPhone.text.trim(),
            paidAmount: paidAmount,
          );
        } else {
          await provider.addSale(
            token: token,
            saleType: _saleType,
            description: _description.text.trim(),
            amount: amount,
            customerName: _customerName.text.trim(),
            customerPhone: _customerPhone.text.trim(),
            paidAmount: paidAmount,
          );
        }
      } else if (_type == 'personal') {
        await provider.addFamilyWithdrawal(
          token: token,
          reason: _reason,
          description: _description.text.trim(),
          amount: amount,
        );
      } else {
        await provider.addExpense(
          token: token,
          category: _category,
          description: _description.text.trim(),
          amount: amount,
        );
      }
    }
    if (mounted) Navigator.of(context).pop();
  }
}
