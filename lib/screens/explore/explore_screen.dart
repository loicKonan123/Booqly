import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/professional.dart';
import '../../providers/professional_provider.dart';
import '../../theme/app_colors.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String? _selectedCategory;
  final _categories = [
    'Coiffure', 'Beauté', 'Santé', 'Sport', 'Médecine', 'Conseil'
  ];

  @override
  void initState() {
    super.initState();
    context.read<ProfessionalProvider>().loadProfessionals();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfessionalProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = _selectedCategory == cat;
                return FilterChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = selected ? null : cat;
                    });
                    context.read<ProfessionalProvider>().loadProfessionals(
                          category: selected ? null : cat,
                        );
                  },
                );
              },
            ),
          ),
        ),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : provider.professionals.isEmpty
                  ? const Center(child: Text('Aucun professionnel trouvé'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.professionals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) =>
                          _ProfessionalCard(pro: provider.professionals[i]),
                    ),
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  final Professional pro;
  const _ProfessionalCard({required this.pro});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/professional/${pro.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: pro.avatarUrl != null
                    ? NetworkImage(pro.avatarUrl!)
                    : null,
                child: pro.avatarUrl == null
                    ? Text(pro.initials,
                        style: const TextStyle(
                            color: AppColors.primary, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pro.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (pro.category != null)
                      Text(pro.category!,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    if (pro.rating != null)
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${pro.rating!.toStringAsFixed(1)}',
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
