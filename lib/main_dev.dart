import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_app/core/di/service_locator.dart';
import 'package:news_app/core/secrets/app_secrets.dart';
import 'package:news_app/core/services/local_database_hive.dart';
import 'package:news_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  await LocalDatabaseHive.initHive();

  await setupServiceLocator();

  runApp(DevicePreview(
      enabled: true,
      // enabled: !kReleaseMode,

      builder: (_) => const NewsWave()));
}
