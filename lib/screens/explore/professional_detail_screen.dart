import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/professional_provider.dart';
import '../../theme/app_colors.dart';

class ProfessionalDetailScreen extends StatefulWidget {
  final String id;
  const ProfessionalDetailScreen({super.key, required this.id});

  @override
  State<ProfessionalDetailScreen> createState() =>
      _ProfessionalDetailScreenState();
}

class _ProfessionalDetailScreenState
    extends State<ProfessionalDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Toujours recharger pour éviter d'afficher des services obsolètes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfessionalProvider>().selectProfessional(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfessionalProvider>();
    if (provider.loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    final pro = provider.selected;
    if (pro == null) {
      return const Scaffold(body: Center(child: Text('Introuvable')));
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(pro.fullName),
              background: Container(
                color: AppColors.primary.withValues(alpha: 0.1),
                child: Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(pro.initials,
                        style: const TextStyle(
                            fontSize: 32,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (pro.bio != null) ...[
                  Text('À propos',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(pro.bio!,
                      style: const TextStyle(
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                ],
                Text('Services',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...provider.services.map((s) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(s.formattedDuration,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(s.formattedPrice,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary)),
                                const SizedBox(height: 6),
                                ElevatedButton(
                                  onPressed: () => context.push(
                                    '/booking/${pro.id}/slots?serviceId=${s.id}',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap),
                                  child: const Text('Réserver',
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
