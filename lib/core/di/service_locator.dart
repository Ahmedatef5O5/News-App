import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app/core/locale/locale_cubit.dart';
import 'package:news_app/core/translation/article_translation_repository.dart';
import 'package:news_app/features/auth/cubit/auth_listener_cubit.dart';
import 'package:news_app/features/home/domain/repositories/home_repository_contract.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:news_app/core/constants/app_constants.dart';
import 'package:news_app/core/cubits/category_cubit.dart';
import 'package:news_app/core/network/network_info.dart';
import 'package:news_app/core/services/local_database_hive.dart';
import 'package:news_app/core/supabase/auth_local_data_source.dart';
import 'package:news_app/core/supabase/auth_remote_data_source.dart';
import 'package:news_app/core/theme/model/theme_model.dart';
import 'package:news_app/features/auth/cubit/auth_cubit.dart';
import 'package:news_app/features/favorites/cubit/favorite_cubit.dart';
import 'package:news_app/features/Headlines/cubit/headlines_cubit.dart';
import 'package:news_app/features/home/cubit/home_cubit.dart';
import 'package:news_app/features/home/services/home_services.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/favorites/services/favorite_services.dart';
import '../../features/search/cubit/search_cubit.dart';
import '../../features/search/services/search_services.dart';
import '../cache/news_cache_manager.dart';
import '../network/connectivity_cubit.dart';
import '../repositories/home_repository.dart';
import '../translation/libre_translation_service.dart';
import '../translation/translation_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  sl.registerLazySingleton<Dio>(
    () => _buildDio(),
  );

  sl.registerLazySingleton<LocalDatabaseHive>(
    () => LocalDatabaseHive.instance,
  );

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      timeout: const Duration(seconds: 5),
      hosts: const ['google.com', 'cloudflare.com', 'dns.google'],
    ),
  );

  sl.registerLazySingleton<ConnectivityCubit>(
    () => ConnectivityCubit(
      sl<NetworkInfo>(),
    ),
  );

  sl.registerLazySingleton<AuthListenerCubit>(() => AuthListenerCubit());

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource.instance,
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      client: sl<SupabaseClient>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      dataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerLazySingleton<HomeRepositoryContract>(
    () => HomeServices(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<NewsCacheManager>(
    () => NewsCacheManager(db: sl<LocalDatabaseHive>()),
  );

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepository(
      services: sl<HomeRepositoryContract>(),
      cache: sl<NewsCacheManager>(),
      networkInfo: sl<NetworkInfo>(),
      translationRepo: sl<ArticleTranslationRepository>(),
    ),
  );

  sl.registerLazySingleton<TranslationService>(
    () => LibreTranslationService(),
    dispose: (service) => service.close(),
  );

  sl.registerLazySingleton<ArticleTranslationRepository>(
    () => ArticleTranslationRepository(
      translationService: sl<TranslationService>(),
      db: sl<LocalDatabaseHive>(),
    ),
  );

  sl.registerLazySingleton<FavoritesService>(
    () => FavoritesService(db: sl<LocalDatabaseHive>()),
  );

  sl.registerLazySingleton<SearchService>(
    () => SearchService(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(),
  );

  sl.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(
      translationRepo: sl<ArticleTranslationRepository>(),
    ),
  );

  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(repository: sl<AuthRepository>()),
  );

  sl.registerLazySingleton<CategoryCubit>(
    () => CategoryCubit(),
  );

  sl.registerLazySingleton<FavoritesCubit>(
    () => FavoritesCubit(
      service: sl<FavoritesService>(),
      translationRepo: sl<ArticleTranslationRepository>(),
      localeCubit: sl<LocaleCubit>(),
    ),
  );

  sl.registerFactory<HomeCubit>(
    () => HomeCubit(
      categoryCubit: sl<CategoryCubit>(),
      repository: sl<HomeRepository>(),
      localeCubit: sl<LocaleCubit>(),
    ),
  );

  sl.registerFactory<HeadlinesCubit>(
    () => HeadlinesCubit(
      categoryCubit: sl<CategoryCubit>(),
      repository: sl<HomeRepository>(),
      localeCubit: sl<LocaleCubit>(),
    ),
  );

  sl.registerFactory<SearchCubit>(
    () => SearchCubit(
      service: sl<SearchService>(),
      localeCubit: sl<LocaleCubit>(),
    ),
  );
}

Dio _buildDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Authorization': 'Bearer ${AppConstants.apiKey}',
        'Content-Type': 'application/json',
      },
    ),
  );

  assert(() {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => _dioPrint(obj.toString()),
      ),
    );
    return true;
  }());

  return dio;
}

void _dioPrint(String message) {
  // ignore: avoid_print
  print('[DioClient] $message');
}
