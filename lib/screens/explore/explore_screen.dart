import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _searchCtrl = TextEditingController();

  final _categories = [
    ('Coiffure', Icons.content_cut_outlined),
    ('Beauté', Icons.spa_outlined),
    ('Santé', Icons.favorite_outline),
    ('Sport', Icons.fitness_center_outlined),
    ('Médecine', Icons.local_hospital_outlined),
    ('Conseil', Icons.lightbulb_outline),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfessionalProvider>().loadProfessionals();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _selectCategory(String cat) {
    final newVal = _selectedCategory == cat ? null : cat;
    setState(() => _selectedCategory = newVal);
    context.read<ProfessionalProvider>().loadProfessionals(
          category: newVal,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfessionalProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Header gradient ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ExploreHeader(
              searchCtrl: _searchCtrl,
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategoryTap: _selectCategory,
            ),
          ),

          // ── Corps ────────────────────────────────────────────────────────
          if (provider.loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.error != null)
            SliverToBoxAdapter(
              child: _ErrorState(message: provider.error!),
            )
          else if (provider.professionals.isEmpty)
            const SliverToBoxAdapter(
              child: _EmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _ProfessionalCard(
                    pro: provider.professionals[i],
                    isDark: isDark,
                  ),
                  childCount: provider.professionals.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Header avec gradient + recherche + catégories ─────────────────────────────

class _ExploreHeader extends StatelessWidget {
  final TextEditingController searchCtrl;
  final List<(String, IconData)> categories;
  final String? selectedCategory;
  final ValueChanged<String> onCategoryTap;

  const _ExploreHeader({
    required this.searchCtrl,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.headerTitle;
    final subtitleColor =
        isDark ? Colors.white.withValues(alpha: 0.72) : AppColors.headerSubtitle;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.softHeaderGradientDark
            : AppColors.softHeaderGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                'Explorer',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Trouvez le professionnel idéal',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: subtitleColor,
                ),
              ),

              const SizedBox(height: 20),

              // Barre de recherche
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.18)
                        : AppColors.primary.withValues(alpha: 0.15),
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: TextField(
                  controller: searchCtrl,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : AppColors.headerTitle,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un professionnel…',
                    hintStyle: GoogleFonts.poppins(
                      color: isDark
                          ? Colors.white54
                          : AppColors.textHint,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? Colors.white60 : AppColors.primary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Catégories
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final (cat, icon) = categories[i];
                    final selected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => onCategoryTap(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : isDark
                                  ? Colors.white.withValues(alpha: 0.10)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : isDark
                                    ? Colors.white.withValues(alpha: 0.20)
                                    : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 14,
                              color: selected
                                  ? Colors.white
                                  : isDark
                                      ? Colors.white70
                                      : AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected
                                    ? Colors.white
                                    : isDark
                                        ? Colors.white70
                                        : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Carte professionnel ────────────────────────────────────────────────────────

class _ProfessionalCard extends StatelessWidget {
  final Professional pro;
  final bool isDark;

  const _ProfessionalCard({required this.pro, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final initial =
        pro.fullName.isNotEmpty ? pro.fullName[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: () => context.push('/professional/${pro.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.primary)
                  .withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar avec gradient ou photo
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: pro.avatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          pro.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              initial,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),

              const SizedBox(width: 14),

              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pro.fullName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (pro.category != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        pro.category!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (pro.rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            pro.rating!.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Flèche
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── États vide / erreur ────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun professionnel trouvé',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Essayez une autre catégorie',
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
