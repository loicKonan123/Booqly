import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand — Violet premium ─────────────────────────────────────────────────
  static const Color primary      = Color(0xFF7C3AED); // violet-600
  static const Color primaryLight = Color(0xFFA78BFA); // violet-400
  static const Color primaryDark  = Color(0xFF5B21B6); // violet-800
  static const Color primaryGlow  = Color(0xFF8B5CF6); // violet-500

  // ── Accent — Indigo ───────────────────────────────────────────────────────
  static const Color accent       = Color(0xFF6366F1); // indigo-500
  static const Color accentLight  = Color(0xFFA5B4FC); // indigo-300

  // ── Secondary — Emerald (status confirmed / success) ──────────────────────
  static const Color secondary    = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF6EE7B7);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color pending   = Color(0xFFF59E0B); // amber
  static const Color confirmed = Color(0xFF10B981); // emerald
  static const Color completed = Color(0xFF6366F1); // indigo
  static const Color cancelled = Color(0xFFEF4444); // red

  // ── Light theme neutrals ──────────────────────────────────────────────────
  static const Color background   = Color(0xFFF5F3FF); // violet-50
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color surfaceAlt   = Color(0xFFF0EFFE); // lighter violet tint
  static const Color border       = Color(0xFFE5E7EB);
  static const Color borderLight  = Color(0xFFEDE9FE); // violet-100

  static const Color textPrimary   = Color(0xFF1E1B4B); // indigo-950
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint      = Color(0xFF9CA3AF);

  // ── Dark theme neutrals ───────────────────────────────────────────────────
  static const Color backgroundDark   = Color(0xFF0F0B1E); // near-black violet
  static const Color surfaceDark      = Color(0xFF1A1535); // deep violet
  static const Color surfaceAltDark   = Color(0xFF231D47);
  static const Color borderDark       = Color(0xFF2D2760);
  static const Color borderLightDark  = Color(0xFF3D3680);

  static const Color textPrimaryDark   = Color(0xFFF5F3FF);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textHintDark      = Color(0xFF6B7280);

  // ── Utility ───────────────────────────────────────────────────────────────
  static const Color error   = Color(0xFFEF4444);
  static const Color success  = Color(0xFF10B981);
  static const Color warning  = Color(0xFFF59E0B);
  static const Color info     = Color(0xFF3B82F6);

  // ── Gradients ─────────────────────────────────────────────────────────────

  // Gradient fort — avatars, badges, éléments graphiques
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED), Color(0xFF5B21B6)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient brandGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA78BFA), Color(0xFF7C3AED), Color(0xFF4C1D95)],
    stops: [0.0, 0.5, 1.0],
  );

  // Gradient doux — headers des pages principales (light mode)
  static const LinearGradient softHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF0EAFF), Color(0xFFE4D9FF)],
  );

  // Gradient doux — headers des pages principales (dark mode)
  static const LinearGradient softHeaderGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1A40), Color(0xFF2A2360)],
  );

  // Couleurs de texte pour header doux (light mode)
  static const Color headerTitle    = Color(0xFF3B0764); // violet-950
  static const Color headerSubtitle = Color(0xFF6D28D9); // violet-700

  // Gradient splash / auth (fond sombre)
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1035), Color(0xFF0F0826), Color(0xFF180D3A)],
  );

  // ── Helpers ───────────────────────────────────────────────────────────────
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':   return pending;
      case 'confirmed': return confirmed;
      case 'completed': return completed;
      case 'cancelled': return cancelled;
      default:          return textSecondary;
    }
  }

  static Color statusBg(String status, {bool dark = false}) {
    return statusColor(status).withValues(alpha: dark ? 0.18 : 0.10);
  }
}
