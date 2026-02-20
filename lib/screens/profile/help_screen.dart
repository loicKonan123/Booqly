import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aide & Support')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Contact card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.headset_mic_outlined, color: AppColors.primary),
                      SizedBox(width: 10),
                      Text(
                        'Contacter le support',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Notre équipe est disponible du lundi au vendredi, 9h – 18h.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  _ContactRow(
                    icon: Icons.email_outlined,
                    label: 'support@booqly.fr',
                  ),
                  const SizedBox(height: 8),
                  _ContactRow(
                    icon: Icons.phone_outlined,
                    label: '+33 1 00 00 00 00',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'Questions fréquentes',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary),
            ),
          ),
          ..._faqs.map((faq) => _FaqTile(q: faq.$1, a: faq.$2)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ContactRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String q;
  final String a;
  const _FaqTile({required this.q, required this.a});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: const Icon(Icons.help_outline, color: AppColors.primary, size: 20),
        title: Text(q,
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 14)),
        children: [
          Text(a,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5)),
        ],
      ),
    );
  }
}

const _faqs = [
  (
    'Comment prendre un rendez-vous ?',
    'Rendez-vous dans l\'onglet "Explorer", choisissez un professionnel, sélectionnez un service puis un créneau disponible, et confirmez votre réservation.'
  ),
  (
    'Comment annuler un rendez-vous ?',
    'Accédez à votre liste de rendez-vous, appuyez sur le RDV concerné et choisissez "Annuler". L\'annulation est possible tant que le professionnel n\'a pas commencé la prestation.'
  ),
  (
    'Comment modifier mes informations personnelles ?',
    'Dans l\'onglet "Profil", appuyez sur "Informations personnelles" pour modifier votre prénom, nom et numéro de téléphone.'
  ),
  (
    'Comment changer mon mot de passe ?',
    'Dans l\'onglet "Profil", appuyez sur "Changer le mot de passe". Vous devrez saisir votre mot de passe actuel, puis le nouveau deux fois.'
  ),
  (
    'Je suis professionnel, comment gérer mes disponibilités ?',
    'Depuis votre tableau de bord, accédez à "Disponibilités" pour définir vos plages horaires hebdomadaires. Les clients pourront alors réserver sur ces créneaux.'
  ),
  (
    'Comment ajouter ou modifier mes services ?',
    'Dans le menu "Services" du tableau de bord professionnel, vous pouvez créer, modifier et activer/désactiver vos prestations avec leur durée et tarif.'
  ),
  (
    'Je n\'ai pas reçu de rappel SMS, pourquoi ?',
    'Les rappels sont envoyés automatiquement 24h avant chaque RDV. Vérifiez que votre numéro de téléphone est correct dans vos informations personnelles.'
  ),
];
