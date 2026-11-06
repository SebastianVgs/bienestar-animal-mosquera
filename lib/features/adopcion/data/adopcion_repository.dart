// lib/features/adopcion/data/adopcion_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/adopcion_model.dart';
import 'dart:isolate';
import 'dart:io'; // Importante para la decodificación pesada si fuera necesaria

class AdopcionRepository {
  static final _supabase = Supabase.instance.client;

  // Obtiene la lista desde la tabla animales_adopcion
  static Future<List<AdopcionModel>> getMascotasDisponibles() async {
    try {
      // 1. Obtenemos la respuesta de la red
      final response = await _supabase
          .from('animales_adopcion')
          .select()
          .eq('estado', 'Disponible');

      // 2. Le damos un micro-respiro al hilo principal para que dibuje el ProgressIndicator
      await Future.delayed(const Duration(milliseconds: 100));

      // 3. Verificamos que la respuesta no sea nula y sea una lista
      if (response == null) return [];

      final List<dynamic> dataList = response as List<dynamic>;

      // 4. Mapeamos la lista de forma segura
      final List<AdopcionModel> mascotas = dataList.map((e) {
         try {
           return AdopcionModel.fromMap(e as Map<String, dynamic>);
         } catch(error){
           print("Error mapeando un registro de adopcion: $error");
           // Si un registro falla, no rompemos toda la lista, retornamos un modelo vacío (o lo filtramos luego)
           // Por ahora, para evitar fallos, devolvemos null y filtramos.
           return null;
         }
      })
      .where((element) => element != null) // Quitamos los que fallaron
      .cast<AdopcionModel>()
      .toList();

      return mascotas;
    } catch (e) {
      print('⚠️ Error al obtener mascotas: $e');
      return []; // Si falla, devuelve una lista vacía para no romper la app
    }
  }

  // Función actualizada para subir la foto
  static Future<void> enviarSolicitudAdopcion(
      String idAnimal, 
      String nombreAnimal, 
      String telefono, 
      String correo, 
      String direccion,
      List<String> localImagePaths
  ) async {
    try {
      List<String> imageUrls = [];
      
      // 1. Subir cada imagen al Storage
      if (localImagePaths.isNotEmpty) {
        for (String path in localImagePaths) {
          final file = File(path);
          final fileName = 'vivienda_${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';
          
          await _supabase.storage.from('imagenes_adopcion').upload(fileName, file);
          final url = _supabase.storage.from('imagenes_adopcion').getPublicUrl(fileName);
          imageUrls.add(url);
        }
      }

      // 2. Insertar en la tabla con la lista de URLs generada
      await _supabase.from('solicitudes_adopcion').insert({
        'id_animal': idAnimal,
        'nombre_animal': nombreAnimal,
        'telefono_contacto': telefono,
        'correo_electronico': correo,
        'direccion_residencia': direccion,
        'fotos_vivienda_urls': imageUrls, // <--- NUEVA COLUMNA TIPO ARRAY
      });
      print('✅ Solicitud de adopción guardada con éxito');
    } catch (e) {
      print('⚠️ Error al guardar solicitud: $e');
      throw Exception('Error al conectar con BD o Storage');
    }
  }
}