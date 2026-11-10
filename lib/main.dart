import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('--- INICIANDO PRUEBA DE RED QUIRÚRGICA ---');
  try {
    final response = await http.get(Uri.parse('https://www.google.com'));
    print('✅ INTERNET DART OK: Código ${response.statusCode}');
  } catch(e) {
    print('❌ SIN INTERNET EN DART: $e');
  }
  print('-------------------------------------------');

  await dotenv.load(fileName: ".env");

  // Revisa quirúrgicamente esta URL en tu código
  await Supabase.initialize(
    url: 'https://dygoihumliloeizwplvo.supabase.co',
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const BienestarAnimalApp()); // O el nombre de tu clase
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