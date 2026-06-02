import 'package:flutter/material.dart';

import '../../ui/theme/app_colors.dart';

/// A selectable life domain shown on the home screen.
class DomainItem {
  final String id;
  final String label;
  final String tagline;
  final IconData icon;
  final Color color;

  const DomainItem({
    required this.id,
    required this.label,
    required this.tagline,
    required this.icon,
    required this.color,
  });
}

/// The curated catalogue of domains the user can pick from.
const List<DomainItem> kDomains = [
  DomainItem(
    id: 'psychologie',
    label: 'Psychologie',
    tagline: 'Mieux te comprendre',
    icon: Icons.psychology_rounded,
    color: AppColors.lavender,
  ),
  DomainItem(
    id: 'anxiete',
    label: 'Anxiété',
    tagline: 'Apaiser ton mental',
    icon: Icons.spa_rounded,
    color: AppColors.sky,
  ),
  DomainItem(
    id: 'productivite',
    label: 'Productivité',
    tagline: 'Avancer sans t\'épuiser',
    icon: Icons.bolt_rounded,
    color: AppColors.sun,
  ),
  DomainItem(
    id: 'sport',
    label: 'Sport',
    tagline: 'Bouger avec plaisir',
    icon: Icons.fitness_center_rounded,
    color: AppColors.mint,
  ),
  DomainItem(
    id: 'nutrition',
    label: 'Nutrition',
    tagline: 'Manger en conscience',
    icon: Icons.restaurant_rounded,
    color: AppColors.peach,
  ),
  DomainItem(
    id: 'relations',
    label: 'Relations',
    tagline: 'Des liens plus sains',
    icon: Icons.favorite_rounded,
    color: AppColors.rose,
  ),
  DomainItem(
    id: 'sommeil',
    label: 'Sommeil',
    tagline: 'Des nuits réparatrices',
    icon: Icons.nightlight_round,
    color: AppColors.lavender,
  ),
  DomainItem(
    id: 'confiance',
    label: 'Confiance',
    tagline: 'Oser être toi',
    icon: Icons.auto_awesome_rounded,
    color: AppColors.sun,
  ),
];
