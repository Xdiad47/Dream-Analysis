import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/database/hive_service.dart';
import 'core/utils/device_id_generator.dart';
import 'features/main_scaffold.dart';  // ← Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await HiveService.init();

  // Initialize device ID
  final deviceId = DeviceIdGenerator.getDeviceId();
  print('Device ID: $deviceId');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainScaffold(),  // ← Changed this line
    );
  }
}











