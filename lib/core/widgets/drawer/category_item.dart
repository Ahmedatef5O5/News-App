import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/cubits/category_cubit.dart';
import 'package:news_app/core/widgets/drawer/drawer_item.dart';
import '../../constants/app_constants.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({super.key, required this.category});
  final NewsCategory category;

  @override
  Widget build(BuildContext context) {
    return DrawerItem(
      icon: Icons.article_outlined,
      label: category.label,
      onTap: () {
        context.read<CategoryCubit>().selectCategory(category);
        Navigator.of(context).pop();
      },
    );
  }
}
