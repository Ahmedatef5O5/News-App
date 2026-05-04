import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_constants.dart';

class CategoryCubit extends Cubit<NewsCategory> {
  CategoryCubit() : super(NewsCategory.general);

  void selectCategory(NewsCategory category) => emit(category);
}
