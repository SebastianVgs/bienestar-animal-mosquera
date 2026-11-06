import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // 1. Asegurarnos de que Flutter esté listo antes de arrancar la BD
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializar la conexión con tu proyecto en la nube
  await Supabase.initialize(
    url: 'https://dygoihumliloeizwplvo.supabase.co',
    publishableKey: 'sb_publishable_F6QHSikjeO0UrQmriyF8Tw_afvpu8Gp',
  );

  // 3. Arrancar la aplicación (asegúrate de que MyApp sea el nombre de tu clase principal)
  runApp(const BienestarAnimalApp());
}

class BienestarAnimalApp extends StatelessWidget {
  const BienestarAnimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bienestar Animal - Mosquera',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}