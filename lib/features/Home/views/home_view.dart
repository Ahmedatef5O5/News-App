import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:news_app/features/Home/cubit/home_cubit.dart';
import '../widgets/title_headline_widget.dart';
import '../widgets/top_headlines_news_section.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..getTopHeadlines(), // method Cascading
      child: Scaffold(
        appBar: AppBar(),
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
