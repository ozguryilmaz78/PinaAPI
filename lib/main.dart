import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceLocator().init();
  await ServiceLocator().initializeApi();
  runApp(const PinaAidatApp());
}

class PinaAidatApp extends StatelessWidget {
  const PinaAidatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ServiceLocator().providers,
      child: MaterialApp(
        title: 'Pina Aidat',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
