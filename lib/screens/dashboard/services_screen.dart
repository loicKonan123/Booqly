import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/professional_provider.dart';
import '../../theme/app_colors.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    final proId = context.read<AuthProvider>().user?.professionalId ?? '';
    context.read<ProfessionalProvider>().loadMyServices(proId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfessionalProvider>();
    final authProvider = context.watch<AuthProvider>();
    final proId = authProvider.user?.professionalId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes services'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showServiceDialog(context, proId, null),
          ),
        ],
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.services.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.design_services_outlined,
                          size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      const Text('Aucun service',
                          style:
                              TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            _showServiceDialog(context, proId, null),
                        child: const Text('Ajouter un service'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.services.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ServiceCard(
                    service: provider.services[i],
                    onEdit: () => _showServiceDialog(
                        context, proId, provider.services[i]),
                    onDelete: () =>
                        _confirmDelete(context, proId, provider.services[i].id),
                  ),
                ),
    );
  }

  Future<void> _showServiceDialog(
      BuildContext context, String proId, Service? existing) async {
    final nameCtrl =
        TextEditingController(text: existing?.name ?? '');
    final descCtrl =
        TextEditingController(text: existing?.description ?? '');
    final priceCtrl = TextEditingController(
        text: existing != null ? existing.price.toString() : '');
    final durationCtrl = TextEditingController(
        text: existing != null ? existing.durationMinutes.toString() : '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            existing == null ? 'Nouveau service' : 'Modifier le service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration:
                    const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceCtrl,
                decoration:
                    const InputDecoration(labelText: 'Prix (€)', prefixText: '€ '),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: durationCtrl,
                decoration: const InputDecoration(
                    labelText: 'Durée (minutes)', suffixText: 'min'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final body = {
                'name': nameCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'price': double.tryParse(priceCtrl.text) ?? 0,
                'durationMinutes': int.tryParse(durationCtrl.text) ?? 30,
              };
              Navigator.pop(ctx);
              final provider =
                  context.read<ProfessionalProvider>();
              if (existing == null) {
                await provider.createService(proId, body);
              } else {
                await provider.updateService(proId, existing.id, body);
              }
            },
            child: Text(existing == null ? 'Créer' : 'Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, String proId, String serviceId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le service ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context
          .read<ProfessionalProvider>()
          .deleteService(proId, serviceId);
    }
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ServiceCard(
      {required this.service,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final s = service;
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(s.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (s.description != null && s.description!.isNotEmpty)
              Text(s.description!,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 4),
            Row(
              children: [
                _Tag(label: s.formattedPrice, icon: Icons.euro),
                const SizedBox(width: 8),
                _Tag(
                    label: s.formattedDuration,
                    icon: Icons.timer_outlined),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit),
            IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: AppColors.error),
                onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Tag({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
