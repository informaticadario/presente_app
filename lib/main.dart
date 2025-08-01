import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // ← para inicializar es_MX
import 'screens/splashscreen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← necesario en apps con async init
  await initializeDateFormatting(
    'es_MX',
    null,
  ); // ← inicializa formato regional
  runApp(AppDocente());
}

class AppDocente extends StatelessWidget {
  const AppDocente({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Docente',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: SplashScreen(),
    );
  }
}
