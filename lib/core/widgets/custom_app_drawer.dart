import 'package:flutter/material.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/utilities/theme/app_colors.dart';

class CustomAppDrawer extends StatelessWidget {
  const CustomAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primaryColor),
              child: Text(
                'News App',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(color: AppColors.whiteColor),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home', style: Theme.of(context).textTheme.titleMedium),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(
              'Favorite',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.favoriteView);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              'Profile',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () {
              // Navigator.of(context).pop();
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
