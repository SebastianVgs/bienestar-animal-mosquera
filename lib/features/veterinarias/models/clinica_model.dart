// lib/features/clinicas/models/clinica_model.dart

class ClinicaModel {
  final String id;
  final String nombre;
  final String direccion;
  final String horarios;
  final String imagenUrl;
  final double latitud;
  final double longitud;

  const ClinicaModel({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.horarios,
    required this.imagenUrl,
    required this.latitud,
    required this.longitud,
  });

  factory ClinicaModel.fromMap(Map<String, dynamic> map) {
    return ClinicaModel(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre'] ?? '',
      direccion: map['direccion'] ?? '',
      horarios: map['horarios'] ?? '',
      imagenUrl: map['imagen_url'] ?? '',
      // Se usa num.parse para evitar errores si Supabase envía un entero (ej: 4 en lugar de 4.0)
      latitud: (map['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (map['longitud'] as num?)?.toDouble() ?? 0.0,
    );
  }
}