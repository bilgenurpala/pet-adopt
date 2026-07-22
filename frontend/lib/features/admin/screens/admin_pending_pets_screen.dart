import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../pets/models/pet.dart';
import '../models/admin_category.dart';
import '../providers/admin_pending_pets_provider.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_network_image.dart';
import '../widgets/admin_panel_components.dart';

const List<String> _petFilters = [
  'all',
  'approval',
  'available',
  'pending',
  'adopted',
];

class AdminPendingPetsScreen extends StatefulWidget {
  const AdminPendingPetsScreen({super.key});

  @override
  State<AdminPendingPetsScreen> createState() => _AdminPendingPetsScreenState();
}

class _AdminPendingPetsScreenState extends State<AdminPendingPetsScreen> {
  String _query = '';
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPendingPetsProvider>().load();
    });
  }

  List<Pet> _visiblePets(List<Pet> pets) {
    final query = _query.trim().toLowerCase();

    return pets.where((pet) {
      final matchesQuery =
          query.isEmpty ||
          pet.name.toLowerCase().contains(query) ||
          pet.breed.toLowerCase().contains(query) ||
          pet.species.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        'approval' => !pet.isApproved,
        'all' => true,
        _ => pet.isApproved && pet.status == _filter,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }

  Future<void> _approve(Pet pet) async {
    final message = await context.read<AdminPendingPetsProvider>().approve(
      pet.id,
    );
    _showResult(message, '${pet.name} approved.');
  }

  Future<void> _delete(Pet pet) async {
    final confirmed = await _confirm(
      title: pet.isApproved ? 'Delete pet' : 'Reject listing',
      body: 'Delete "${pet.name}"? This cannot be undone.',
    );

    if (!confirmed || !mounted) {
      return;
    }

    final message = await context.read<AdminPendingPetsProvider>().delete(
      pet.id,
    );
    _showResult(message, '${pet.name} deleted.');
  }

  Future<void> _openForm([Pet? pet]) async {
    final categories = context.read<AdminPendingPetsProvider>().categories;

    if (categories.isEmpty) {
      _showResult('No pet categories are available.', '');
      return;
    }

    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PetFormDialog(pet: pet, categories: categories),
    );

    if (data == null || !mounted) {
      return;
    }

    final message = await context.read<AdminPendingPetsProvider>().save(
      petId: pet?.id,
      data: data,
    );
    _showResult(
      message,
      pet == null ? 'Pet listing created.' : '${pet.name} updated.',
    );
  }

  void _showDetails(Pet pet) {
    showDialog<void>(
      context: context,
      builder: (context) => _PetDetailDialog(
        pet: pet,
        onEdit: () {
          Navigator.of(context).pop();
          _openForm(pet);
        },
      ),
    );
  }

  Future<bool> _confirm({required String title, required String body}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _showResult(String? errorMessage, String successMessage) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(errorMessage ?? successMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminPendingPetsProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: provider.load,
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(AdminPendingPetsProvider provider) {
    if (provider.isLoading && provider.pets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.pets.isEmpty) {
      return AdminErrorView(message: provider.error!, onRetry: provider.load);
    }

    final pets = _visiblePets(provider.pets);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 820;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(wide ? 32 : 20),
          children: [
            AdminPageHeader(
              title: 'Pets',
              subtitle: 'Manage pet listings and approval requests',
              trailing: FilledButton.icon(
                onPressed: provider.isSaving ? null : () => _openForm(),
                icon: const Icon(Icons.add),
                label: const Text('Add new pet'),
              ),
            ),
            const SizedBox(height: 24),
            AdminSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PetToolbar(
                    selectedFilter: _filter,
                    onFilterChanged: (value) {
                      setState(() => _filter = value);
                    },
                    onSearchChanged: (value) {
                      setState(() => _query = value);
                    },
                  ),
                  const SizedBox(height: 18),
                  if (pets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 56),
                      child: EmptyState(
                        title: 'No pets found',
                        subtitle: 'Try a different search or filter.',
                      ),
                    )
                  else if (wide)
                    _PetTable(
                      pets: pets,
                      provider: provider,
                      onView: _showDetails,
                      onEdit: _openForm,
                      onApprove: _approve,
                      onDelete: _delete,
                    )
                  else
                    _PetCards(
                      pets: pets,
                      provider: provider,
                      onView: _showDetails,
                      onEdit: _openForm,
                      onApprove: _approve,
                      onDelete: _delete,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PetToolbar extends StatelessWidget {
  const _PetToolbar({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
  });

  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final filter in _petFilters)
              ChoiceChip(
                label: Text(_filterLabel(filter)),
                selected: selectedFilter == filter,
                onSelected: (_) => onFilterChanged(filter),
              ),
          ],
        ),
        AdminSearchField(
          hintText: 'Search pets...',
          onChanged: onSearchChanged,
        ),
      ],
    );
  }

  String _filterLabel(String filter) {
    return switch (filter) {
      'approval' => 'Awaiting approval',
      'all' => 'All',
      _ => '${filter[0].toUpperCase()}${filter.substring(1)}',
    };
  }
}

class _PetTable extends StatelessWidget {
  const _PetTable({
    required this.pets,
    required this.provider,
    required this.onView,
    required this.onEdit,
    required this.onApprove,
    required this.onDelete,
  });

  final List<Pet> pets;
  final AdminPendingPetsProvider provider;
  final ValueChanged<Pet> onView;
  final ValueChanged<Pet> onEdit;
  final ValueChanged<Pet> onApprove;
  final ValueChanged<Pet> onDelete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(
          AppColors.background.withValues(alpha: 0.8),
        ),
        columns: const [
          DataColumn(label: Text('Pet')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Breed')),
          DataColumn(label: Text('Age')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final pet in pets)
            DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 190,
                    child: Row(
                      children: [
                        AdminNetworkImage(url: pet.photoUrl, size: 42),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            pet.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(Text(_capitalize(pet.species))),
                DataCell(SizedBox(width: 130, child: Text(pet.breed))),
                DataCell(Text('${_formatAge(pet.age)} years')),
                DataCell(
                  AdminStatusBadge(
                    status: pet.isApproved ? pet.status : 'pending approval',
                  ),
                ),
                DataCell(
                  _PetActions(
                    pet: pet,
                    isBusy: provider.isBusy(pet.id),
                    onView: () => onView(pet),
                    onEdit: () => onEdit(pet),
                    onApprove: () => onApprove(pet),
                    onDelete: () => onDelete(pet),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PetCards extends StatelessWidget {
  const _PetCards({
    required this.pets,
    required this.provider,
    required this.onView,
    required this.onEdit,
    required this.onApprove,
    required this.onDelete,
  });

  final List<Pet> pets;
  final AdminPendingPetsProvider provider;
  final ValueChanged<Pet> onView;
  final ValueChanged<Pet> onEdit;
  final ValueChanged<Pet> onApprove;
  final ValueChanged<Pet> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < pets.length; index++) ...[
          _PetCard(
            pet: pets[index],
            isBusy: provider.isBusy(pets[index].id),
            onView: () => onView(pets[index]),
            onEdit: () => onEdit(pets[index]),
            onApprove: () => onApprove(pets[index]),
            onDelete: () => onDelete(pets[index]),
          ),
          if (index != pets.length - 1) const Divider(height: 24),
        ],
      ],
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({
    required this.pet,
    required this.isBusy,
    required this.onView,
    required this.onEdit,
    required this.onApprove,
    required this.onDelete,
  });

  final Pet pet;
  final bool isBusy;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onApprove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminNetworkImage(url: pet.photoUrl, size: 64),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      pet.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AdminStatusBadge(
                    status: pet.isApproved ? pet.status : 'pending approval',
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text('${_capitalize(pet.species)} · ${pet.breed}'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 4,
                children: [
                  AdminIconAction(
                    icon: Icons.visibility_outlined,
                    tooltip: 'View pet',
                    onPressed: onView,
                  ),
                  AdminIconAction(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit pet',
                    onPressed: isBusy ? null : onEdit,
                  ),
                  if (!pet.isApproved)
                    FilledButton.icon(
                      onPressed: isBusy ? null : onApprove,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                    ),
                  AdminIconAction(
                    icon: Icons.delete_outline,
                    tooltip: 'Delete pet',
                    color: AppColors.error,
                    onPressed: isBusy ? null : onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PetActions extends StatelessWidget {
  const _PetActions({
    required this.pet,
    required this.isBusy,
    required this.onView,
    required this.onEdit,
    required this.onApprove,
    required this.onDelete,
  });

  final Pet pet;
  final bool isBusy;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onApprove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AdminIconAction(
          icon: Icons.visibility_outlined,
          tooltip: 'View pet',
          onPressed: onView,
        ),
        AdminIconAction(
          icon: Icons.edit_outlined,
          tooltip: 'Edit pet',
          onPressed: isBusy ? null : onEdit,
        ),
        if (!pet.isApproved)
          AdminIconAction(
            icon: Icons.check_circle_outline,
            tooltip: 'Approve pet',
            color: AppColors.success,
            onPressed: isBusy ? null : onApprove,
          ),
        AdminIconAction(
          icon: Icons.delete_outline,
          tooltip: 'Delete pet',
          color: AppColors.error,
          onPressed: isBusy ? null : onDelete,
        ),
      ],
    );
  }
}

class _PetDetailDialog extends StatelessWidget {
  const _PetDetailDialog({required this.pet, required this.onEdit});

  final Pet pet;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 680),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pet details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, constraints) {
                  final photo = AdminNetworkImage(
                    url: pet.photoUrl,
                    size: constraints.maxWidth >= 620 ? 240 : 160,
                  );
                  final details = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pet.name,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          AdminStatusBadge(
                            status: pet.isApproved
                                ? pet.status
                                : 'pending approval',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AdminDetailRow(
                        label: 'Type',
                        value: _capitalize(pet.species),
                      ),
                      AdminDetailRow(label: 'Breed', value: pet.breed),
                      AdminDetailRow(
                        label: 'Age',
                        value: '${_formatAge(pet.age)} years',
                      ),
                      AdminDetailRow(
                        label: 'Gender',
                        value: _capitalize(pet.gender),
                      ),
                      AdminDetailRow(
                        label: 'Size',
                        value: _capitalize(pet.size),
                      ),
                      AdminDetailRow(
                        label: 'Energy level',
                        value: _capitalize(pet.energyLevel),
                      ),
                      AdminDetailRow(
                        label: 'Adoption fee',
                        value: pet.adoptionFee == null
                            ? 'Not provided'
                            : pet.adoptionFee!.toStringAsFixed(2),
                      ),
                    ],
                  );

                  if (constraints.maxWidth < 620) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(child: photo),
                        const SizedBox(height: 20),
                        details,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      photo,
                      const SizedBox(width: 24),
                      Expanded(child: details),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'About ${pet.name}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                pet.description.isEmpty
                    ? 'No description provided.'
                    : pet.description,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetFormDialog extends StatefulWidget {
  const _PetFormDialog({required this.categories, this.pet});

  final Pet? pet;
  final List<AdminCategory> categories;

  @override
  State<_PetFormDialog> createState() => _PetFormDialogState();
}

class _PetFormDialogState extends State<_PetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _breed;
  late final TextEditingController _age;
  late final TextEditingController _description;
  late final TextEditingController _photoUrl;
  late final TextEditingController _adoptionFee;
  late String _species;
  late String _gender;
  late String _size;
  late String _energyLevel;
  late int _categoryId;

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;
    _name = TextEditingController(text: pet?.name ?? '');
    _breed = TextEditingController(text: pet?.breed ?? '');
    _age = TextEditingController(text: pet == null ? '' : _formatAge(pet.age));
    _description = TextEditingController(text: pet?.description ?? '');
    _photoUrl = TextEditingController(text: pet?.photoUrl ?? '');
    _adoptionFee = TextEditingController(
      text: pet?.adoptionFee?.toString() ?? '',
    );
    _species = pet?.species ?? 'dog';
    _gender = pet?.gender ?? 'female';
    _size = pet?.size ?? 'medium';
    _energyLevel = pet?.energyLevel ?? 'medium';
    _categoryId = pet?.categoryId ?? widget.categories.first.id;
  }

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _age.dispose();
    _description.dispose();
    _photoUrl.dispose();
    _adoptionFee.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(<String, dynamic>{
      'name': _name.text.trim(),
      'species': _species,
      'breed': _breed.text.trim(),
      'age': double.parse(_age.text.trim()),
      'gender': _gender,
      'size': _size,
      'energy_level': _energyLevel,
      'description': _nullable(_description.text),
      'photo_url': _nullable(_photoUrl.text),
      'adoption_fee': _nullableNumber(_adoptionFee.text),
      'category_id': _categoryId,
    });
  }

  String? _nullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  double? _nullableNumber(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : double.parse(trimmed);
  }

  String? _requiredText(String? value) {
    return value == null || value.trim().isEmpty ? 'Required' : null;
  }

  String? _positiveNumber(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
    return number == null || number < 0 ? 'Enter a valid number' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 16, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.pet == null ? 'Add new pet' : 'Edit pet',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Use the fields supported by the current pet contract',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final twoColumns = constraints.maxWidth >= 580;
                      final fields = <Widget>[
                        TextFormField(
                          controller: _name,
                          validator: _requiredText,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        _DropdownField(
                          label: 'Type',
                          value: _species,
                          values: const ['cat', 'dog', 'bird', 'fish', 'other'],
                          onChanged: (value) {
                            setState(() => _species = value);
                          },
                        ),
                        TextFormField(
                          controller: _breed,
                          validator: _requiredText,
                          decoration: const InputDecoration(labelText: 'Breed'),
                        ),
                        TextFormField(
                          controller: _age,
                          validator: _positiveNumber,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: 'Age'),
                        ),
                        _DropdownField(
                          label: 'Gender',
                          value: _gender,
                          values: const ['female', 'male'],
                          onChanged: (value) {
                            setState(() => _gender = value);
                          },
                        ),
                        _DropdownField(
                          label: 'Size',
                          value: _size,
                          values: const ['small', 'medium', 'large'],
                          onChanged: (value) {
                            setState(() => _size = value);
                          },
                        ),
                        _DropdownField(
                          label: 'Energy level',
                          value: _energyLevel,
                          values: const ['low', 'medium', 'high'],
                          onChanged: (value) {
                            setState(() => _energyLevel = value);
                          },
                        ),
                        DropdownButtonFormField<int>(
                          initialValue: _categoryId,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items: [
                            for (final category in widget.categories)
                              DropdownMenuItem(
                                value: category.id,
                                child: Text(category.name),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _categoryId = value);
                            }
                          },
                        ),
                        TextFormField(
                          controller: _adoptionFee,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            }
                            return _positiveNumber(value);
                          },
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Adoption fee',
                          ),
                        ),
                        TextFormField(
                          controller: _photoUrl,
                          decoration: const InputDecoration(
                            labelText: 'Photo URL',
                          ),
                        ),
                      ];

                      return Column(
                        children: [
                          if (twoColumns)
                            for (
                              var index = 0;
                              index < fields.length;
                              index += 2
                            ) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: fields[index]),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: index + 1 < fields.length
                                        ? fields[index + 1]
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                            ]
                          else
                            for (final field in fields) ...[
                              field,
                              const SizedBox(height: 14),
                            ],
                          TextFormField(
                            controller: _description,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              alignLabelWithHint: true,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _submit,
                      child: Text(
                        widget.pet == null ? 'Save pet' : 'Save changes',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in values)
          DropdownMenuItem(value: item, child: Text(_capitalize(item))),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

String _capitalize(String value) {
  if (value.isEmpty) {
    return value;
  }

  return '${value[0].toUpperCase()}${value.substring(1)}';
}

String _formatAge(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
}
