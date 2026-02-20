import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/professional_provider.dart';
import '../../theme/app_colors.dart';

class ServiceSelectScreen extends StatefulWidget {
  final String proId;
  const ServiceSelectScreen({super.key, required this.proId});

  @override
  State<ServiceSelectScreen> createState() => _ServiceSelectScreenState();
}

class _ServiceSelectScreenState extends State<ServiceSelectScreen> {
  @override
  void initState() {
    super.initState();
    final p = context.read<ProfessionalProvider>();
    if (p.selected?.id != widget.proId) {
      p.selectProfessional(widget.proId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfessionalProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir un service')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.services.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final s = provider.services[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(s.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(s.formattedDuration),
                    trailing: Text(s.formattedPrice,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    onTap: () => context.push(
                      '/booking/${widget.proId}/slots?serviceId=${s.id}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
