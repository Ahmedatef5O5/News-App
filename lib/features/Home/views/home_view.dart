import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:news_app/core/utilities/theme/app_colors.dart';
import 'package:news_app/features/Home/cubit/home_cubit.dart';
import '../widgets/custom_container_icon.dart';
import '../widgets/title_headline_widget.dart';
import '../widgets/top_headlines_news_section.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..getTopHeadlines(), // method Cascading
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.098,
          // toolbarHeight: 75,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: CustomContainerIcon(
              widgetIcon: Icon(Icons.menu, color: AppColors.blackColor),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  CustomContainerIcon(
                    widgetIcon: Icon(Icons.search, color: AppColors.blackColor),
                  ),
                  Gap(8),
                  CustomContainerIcon(
                    widgetIcon: Icon(
                      Icons.notification_add,
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TitleHeadlineWidget(
              title: 'Breaking News',
              txtBtn: 'View all',
              wordSpacing: -2,
              onTap: () {},
            ),
            Gap(16),
            TopHeadlinesNewsSection(),
            Gap(22),
            TitleHeadlineWidget(
              title: 'Recommendation',
              txtBtn: 'View all',
              wordSpacing: -2,
              onTap: () {},
            ),
            Gap(16),
          ],
        ),
      ),
    );
  }
}
