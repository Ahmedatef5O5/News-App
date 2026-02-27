import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:news_app/core/router/app_routes.dart';
import 'package:news_app/core/utilities/constants/app_images.dart';
import 'package:news_app/core/utilities/theme/app_colors.dart';
import 'package:news_app/features/Home/Home_Cubit/home_cubit.dart';
import 'package:news_app/core/widgets/custom_app_drawer.dart';
import '../widgets/custom_container_icon.dart';
import '../widgets/recommendation_news_list_view.dart';
import '../widgets/title_headline_widget.dart';
import '../widgets/top_headlines_news_section.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final homecubit = HomeCubit();
        homecubit.getTopHeadlines();
        homecubit.getRecommendationNews();
        return homecubit;
      }, // method Cascading
      child: Scaffold(
        // key: _scaffoldKey,
        drawer: CustomAppDrawer(),
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.08,
          elevation: 0,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          // toolbarHeight: 75,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Builder(
              builder: (innercontext) {
                return CustomContainerIcon(
                  widgetIcon: Icon(Icons.menu, color: AppColors.blackColor),
                  onTap: () => Scaffold.of(innercontext).openDrawer(),
                );
              },
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  CustomContainerIcon(
                    widgetIcon: Image.asset(
                      AppImages.search,
                      width: 26,
                      height: 26,
                    ),
                    // widgetIcon: Icon(Icons.search, color: AppColors.blackColor),
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.searchView),
                  ),
                  Gap(8),
                  CustomContainerIcon(
                    widgetIcon: Image.asset(
                      AppImages.notification,
                      width: 25,
                      height: 25,
                    ),
                    // widgetIcon: Icon(
                    //   Icons.notification_add,
                    //   color: AppColors.blackColor,
                    // ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TitleHeadlineWidget(
                title: 'Breaking News',
                txtBtn: 'View all',
                wordSpacing: -2,
                onTap: () {},
              ),
              Gap(10),
              TopHeadlinesNewsSection(),
              Gap(18),
              TitleHeadlineWidget(
                title: 'Recommendation',
                txtBtn: 'View all',
                wordSpacing: -2,
                onTap: () {},
              ),
              Gap(4),
              RecommendationNewsListView(),
            ],
          ),
        ),
      ),
    );
  }
}
