// lib/features/esterilizacion/models/campana_model.dart

class CampanaModel {
  final String date;
  final String location;
  final String schedule;
  final String image; // Ahora almacenará la URL de Supabase

  const CampanaModel({
    required this.date,
    required this.location,
    required this.schedule,
    required this.image,
  });

  factory CampanaModel.fromJson(Map<String, dynamic> json) {
    return CampanaModel(
      date: json['fecha'] ?? '',
      location: json['ubicacion'] ?? '',
      schedule: json['horario'] ?? '',
      image: json['imagen_url'] ?? '',
    );
  }
}