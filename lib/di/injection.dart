import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/wearable/wearable_service.dart';
import '../presentation/providers/wearable_provider.dart';
import '../presentation/providers/settings_provider.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // Initialize SharedPreferences first
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs, instanceName: 'sharedPreferences');
  
  // Register WearableService as a singleton
  getIt.registerLazySingleton<WearableService>(() => WearableService());
  
  // Register providers
  getIt.registerLazySingleton<WearableProvider>(() => WearableProvider());
  getIt.registerLazySingleton<SettingsProvider>(() => SettingsProvider(prefs));
  
  // Initialize other dependencies
  getIt.init();
}

// Empty module for other dependencies
@module
abstract class RegisterModule {} 