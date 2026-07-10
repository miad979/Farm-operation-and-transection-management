import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/animal_model.dart';
import '../providers/auth_provider.dart';
import '../providers/farm_provider.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  final _searchController = TextEditingController();
  String _filter = 'All';

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
    if (token != null) await context.read<FarmProvider>().loadAll(token);
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();
    final animals = _filteredAnimals(farm.animals);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: farm.isLoading ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 92),
              sliver: SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _SummaryStrip(farm: farm),
                        const SizedBox(height: 14),
                        _Toolbar(
                          controller: _searchController,
                          filter: _filter,
                          onFilterChanged: (value) =>
                              setState(() => _filter = value),
                          onSearchChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                  if (animals.isEmpty)
                    const SliverToBoxAdapter(child: _EmptyState())
                  else
                    SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;
                        final columns = width > 1040
                            ? 3
                            : width > 680
                            ? 2
                            : 1;
                        return SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final animal = animals[index];
                            return _AnimalCard(
                              animal: animal,
                              onMilkRecord: () =>
                                  _showMilkSheet(context, animal),
                              onManage: () =>
                                  _showAnimalSheet(context, animal: animal),
                            );
                          }, childCount: animals.length),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 190,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAnimalSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add animal'),
      ),
    );
  }

  List<AnimalModel> _filteredAnimals(List<AnimalModel> animals) {
    final query = _searchController.text.trim().toLowerCase();
    return animals.where((animal) {
      final matchesQuery =
          query.isEmpty ||
          animal.name.toLowerCase().contains(query) ||
          animal.animalIdNumber.toLowerCase().contains(query) ||
          animal.type.toLowerCase().contains(query);
      final matchesFilter =
          _filter == 'All' ||
          animal.healthStatus == _filter ||
          animal.type == _filter;
      return matchesQuery && matchesFilter;
    }).toList();
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.farm});

  final FarmProvider farm;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 760 ? 4 : 2;
        final items = [
          ('Total', '${farm.totalAnimals}', Icons.pets_outlined),
          ('Healthy', '${farm.healthyAnimals}', Icons.check_circle_outline),
          (
            'Pregnant',
            '${farm.animalStats['pregnant'] ?? 0}',
            Icons.favorite_outline,
          ),
          (
            'Vaccinated',
            '${farm.animalStats['vaccinated'] ?? 0}',
            Icons.vaccines_outlined,
          ),
        ];
        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 92,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(item.$3, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.$1,
                            style: const TextStyle(color: Color(0xFF526166)),
                          ),
                          Text(
                            item.$2,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
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
      },
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.controller,
    required this.filter,
    required this.onFilterChanged,
    required this.onSearchChanged,
  });

  final TextEditingController controller;
  final String filter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                controller: controller,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  labelText: 'Search animals',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: controller.text.trim().isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            controller.clear();
                            onSearchChanged('');
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                initialValue: filter,
                decoration: const InputDecoration(labelText: 'Filter'),
                items:
                    const [
                          'All',
                          'Cow',
                          'Calf',
                          'Heifer',
                          'Bull',
                          'Healthy',
                          'Sick',
                          'Treatment',
                          'Pregnant',
                        ]
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                onChanged: (value) => onFilterChanged(value ?? 'All'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({
    required this.animal,
    required this.onMilkRecord,
    required this.onManage,
  });

  final AnimalModel animal;
  final VoidCallback onMilkRecord;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final needsAttention =
        animal.healthStatus != 'Healthy' || !animal.vaccinated;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: needsAttention
                      ? const Color(0xFFFEE2E2)
                      : Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    animal.type == 'Cow'
                        ? Icons.water_drop_outlined
                        : Icons.pets_outlined,
                    color: needsAttention
                        ? const Color(0xFFB91C1C)
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        animal.name,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '${animal.animalIdNumber} • ${animal.type}',
                        style: const TextStyle(color: Color(0xFF526166)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(
                  label: animal.healthStatus,
                  good: animal.healthStatus == 'Healthy',
                ),
                _StatusChip(
                  label: animal.vaccinated ? 'Vaccinated' : 'Vaccine due',
                  good: animal.vaccinated,
                ),
                if (animal.breed != null && animal.breed!.isNotEmpty)
                  _StatusChip(label: animal.breed!, good: true),
                if (animal.defaultDailyMilk > 0)
                  _StatusChip(
                    label:
                        '${animal.defaultDailyMilk.toStringAsFixed(1)} L/day',
                    good: true,
                  ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onMilkRecord,
                    icon: const Icon(Icons.water_drop_outlined),
                    label: const Text('Milk'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Manage animal',
                  onPressed: onManage,
                  icon: const Icon(Icons.tune_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.good});

  final String label;
  final bool good;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, overflow: TextOverflow.ellipsis),
      backgroundColor: good ? const Color(0xFFE6F6EF) : const Color(0xFFFFE8E8),
      side: BorderSide(
        color: good ? const Color(0xFFBFEAD6) : const Color(0xFFFFC2C2),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.pets_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'No animals found',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add animals or adjust the search and filter controls.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showAnimalSheet(
  BuildContext context, {
  AnimalModel? animal,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AnimalFormSheet(animal: animal),
  );
}

class _AnimalFormSheet extends StatefulWidget {
  const _AnimalFormSheet({this.animal});

  final AnimalModel? animal;

  @override
  State<_AnimalFormSheet> createState() => _AnimalFormSheetState();
}

class _AnimalFormSheetState extends State<_AnimalFormSheet> {
  final _id = TextEditingController();
  final _name = TextEditingController();
  final _breed = TextEditingController();
  final _dailyMilk = TextEditingController();
  final _notes = TextEditingController();
  String _type = 'Cow';
  String _gender = 'Female';
  String _health = 'Healthy';
  String _pregnancy = 'Not Pregnant';
  bool _vaccinated = false;

  @override
  void initState() {
    super.initState();
    final animal = widget.animal;
    if (animal != null) {
      _id.text = animal.animalIdNumber;
      _name.text = animal.name;
      _breed.text = animal.breed ?? '';
      _dailyMilk.text = animal.defaultDailyMilk == 0
          ? ''
          : animal.defaultDailyMilk.toStringAsFixed(1);
      _notes.text = animal.notes ?? '';
      _type = animal.type;
      _gender = animal.gender ?? 'Female';
      _health = animal.healthStatus;
      _pregnancy = animal.pregnancyStatus;
      _vaccinated = animal.vaccinated;
    }
  }

  @override
  void dispose() {
    _id.dispose();
    _name.dispose();
    _breed.dispose();
    _dailyMilk.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 560;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.animal == null ? 'Add animal' : 'Manage animal',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _id,
                decoration: const InputDecoration(labelText: 'Animal ID'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              _fieldPair(
                compact: compact,
                first: _select('Type', _type, [
                  'Cow',
                  'Ox',
                  'Buffalo',
                  'Calf',
                  'Heifer',
                  'Bull',
                ], (v) => setState(() => _type = v)),
                second: _select('Gender', _gender, [
                  'Female',
                  'Male',
                ], (v) => setState(() => _gender = v)),
              ),
              const SizedBox(height: 12),
              _fieldPair(
                compact: compact,
                first: TextField(
                  controller: _breed,
                  decoration: const InputDecoration(labelText: 'Breed'),
                ),
                second: _select('Health', _health, [
                  'Healthy',
                  'Sick',
                  'Treatment',
                  'Pregnant',
                ], (v) => setState(() => _health = v)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dailyMilk,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Normal daily milk (L)',
                  helperText:
                      'Change this when the cow normal production changes.',
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _vaccinated,
                onChanged: (value) => setState(() => _vaccinated = value),
                title: const Text('Vaccinated'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 4),
              _select('Pregnancy', _pregnancy, [
                'Not Pregnant',
                'Pregnant',
                'Check Needed',
              ], (v) => setState(() => _pregnancy = v)),
              const SizedBox(height: 12),
              TextField(
                controller: _notes,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: Text(
                  widget.animal == null ? 'Save animal' : 'Save changes',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldPair({
    required bool compact,
    required Widget first,
    required Widget second,
  }) {
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [first, const SizedBox(height: 12), second],
      );
    }
    return Row(
      children: [
        Expanded(child: first),
        const SizedBox(width: 10),
        Expanded(child: second),
      ],
    );
  }

  Widget _select(
    String label,
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) => onChanged(value ?? items.first),
    );
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().accessToken;
    if (token == null || _id.text.trim().isEmpty || _name.text.trim().isEmpty) {
      return;
    }
    final provider = context.read<FarmProvider>();
    final animal = widget.animal;
    final defaultDailyMilk = double.tryParse(_dailyMilk.text.trim()) ?? 0;
    if (animal == null) {
      await provider.addAnimal(
        token: token,
        animalIdNumber: _id.text.trim(),
        name: _name.text.trim(),
        type: _type,
        breed: _breed.text.trim(),
        gender: _gender,
        healthStatus: _health,
        defaultDailyMilk: defaultDailyMilk,
        notes: _notes.text.trim(),
      );
    } else {
      await provider.updateAnimal(
        token: token,
        animalId: animal.id,
        animalIdNumber: _id.text.trim(),
        name: _name.text.trim(),
        type: _type,
        breed: _breed.text.trim(),
        gender: _gender,
        healthStatus: _health,
        defaultDailyMilk: defaultDailyMilk,
        vaccinated: _vaccinated,
        pregnancyStatus: _pregnancy,
        notes: _notes.text.trim(),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}

Future<void> _showMilkSheet(BuildContext context, AnimalModel animal) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _MilkSheet(animal: animal),
  );
}

class _MilkSheet extends StatefulWidget {
  const _MilkSheet({required this.animal});

  final AnimalModel animal;

  @override
  State<_MilkSheet> createState() => _MilkSheetState();
}

class _MilkSheetState extends State<_MilkSheet> {
  final _morning = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.animal.defaultDailyMilk > 0) {
      _morning.text = widget.animal.defaultDailyMilk.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _morning.dispose();
    super.dispose();
  }

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Milk record for ${widget.animal.name}',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _morning,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Actual milk today (L)',
                helperText:
                    'This replaces the normal daily milk for today only.',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Save production'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().accessToken;
    final totalMilk = double.tryParse(_morning.text.trim()) ?? 0;
    if (token == null || totalMilk <= 0) return;
    await context.read<FarmProvider>().addMilkRecord(
      token: token,
      animalId: widget.animal.id,
      morningMilk: totalMilk,
      eveningMilk: 0,
    );
    if (mounted) Navigator.of(context).pop();
  }
}
