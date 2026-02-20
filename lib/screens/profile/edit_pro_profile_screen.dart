import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/professional.dart';
import '../../providers/auth_provider.dart';
import '../../providers/professional_provider.dart';
import '../../theme/app_colors.dart';

class EditProProfileScreen extends StatefulWidget {
  const EditProProfileScreen({super.key});

  @override
  State<EditProProfileScreen> createState() => _EditProProfileScreenState();
}

class _EditProProfileScreenState extends State<EditProProfileScreen> {
  static const _categories = [
    'Coiffure',
    'Beauté',
    'Santé',
    'Sport',
    'Médecine',
    'Conseil',
    'Autre',
  ];

  final _bioCtrl = TextEditingController();
  String? _selectedCategory;
  bool _saving = false;
  bool _formInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final proId = context.read<AuthProvider>().user?.professionalId;
      if (proId == null) return;
      final prov = context.read<ProfessionalProvider>();
      if (prov.selected != null) {
        _initForm(prov.selected!);
      } else {
        prov.loadProOwnProfile(proId);
      }
    });
  }

  void _initForm(Professional pro) {
    if (_formInitialized) return;
    _bioCtrl.text = pro.bio ?? '';
    setState(() {
      _selectedCategory =
          _categories.contains(pro.category) ? pro.category : null;
      _formInitialized = true;
    });
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une catégorie')),
      );
      return;
    }
    final proId = context.read<AuthProvider>().user?.professionalId;
    if (proId == null) return;

    setState(() => _saving = true);
    final ok = await context.read<ProfessionalProvider>().updateProProfile(
          proId,
          category: _selectedCategory!,
          bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil professionnel mis à jour')),
      );
      Navigator.pop(context);
    } else {
      final err =
          context.read<ProfessionalProvider>().error ?? 'Erreur inconnue';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfessionalProvider>();

    // Initialize form once data arrives from async load
    if (!_formInitialized && !provider.loading && provider.selected != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _initForm(provider.selected!);
      });
    }

    if (provider.loading && !_formInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil professionnel')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil professionnel'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enregistrer'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Catégorie *',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final selected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: selected,
                onSelected: (_) => setState(() => _selectedCategory = cat),
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Bio / Description',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _bioCtrl,
            maxLines: 5,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText:
                  'Décrivez votre activité, votre expérience, vos spécialités…',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.info),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Les clients trouvent les professionnels en filtrant par catégorie. '
                    'Choisissez la bonne pour apparaître dans les recherches.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
