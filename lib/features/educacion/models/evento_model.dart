// lib/features/educacion/models/evento_model.dart

class EventoModel {
  final String id;
  final String title;
  final String location;
  final String date;
  final String? description;
  final String? image;
  final bool esPasado;

  const EventoModel({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    this.description,
    this.image,
    required this.esPasado,
  });

  factory EventoModel.fromMap(Map<String, dynamic> map) {
    return EventoModel(
      id: map['id']?.toString() ?? '',
      title: map['titulo'] ?? 'Sin título',
      location: map['ubicacion'] ?? 'Ubicación por definir',
      date: map['fecha'] ?? 'Fecha por definir',
      description: map['descripcion'],
      image: map['imagen_url'],
      esPasado: map['es_pasado'] ?? false,
    );
  }
}