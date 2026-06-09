import 'package:flutter/material.dart';
import 'package:news_app/l10n/app_localizations_x.dart';
import '../constants/app_constants.dart';

extension LocalizedNewsCategory on NewsCategory {
  String localizedName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      NewsCategory.general => l10n.categoryGeneral,
      NewsCategory.business => l10n.categoryBusiness,
      NewsCategory.technology => l10n.categoryTechnology,
      NewsCategory.sports => l10n.categorySports,
      NewsCategory.health => l10n.categoryHealth,
      NewsCategory.entertainment => l10n.categoryEntertainment,
      NewsCategory.science => l10n.categoryScience,
    };
  }
}
