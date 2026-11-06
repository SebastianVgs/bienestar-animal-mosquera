// lib/features/adopcion/models/adopcion_model.dart

class AdopcionModel {
  final String id;
  final String name;
  final String type;
  final String breed;
  final String age;
  final String gender;
  final String status;
  final String description;
  final String image;

  const AdopcionModel({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.age,
    required this.gender,
    required this.status,
    required this.description,
    required this.image,
  });

  // Mapeo desde Supabase (en español) hacia Flutter (en inglés/tu formato)
  factory AdopcionModel.fromMap(Map<String, dynamic> map) {
    return AdopcionModel(
      id: map['id']?.toString() ?? '',
      name: map['nombre'] ?? '',        
      type: map['especie'] ?? 'Perro', 
      breed: map['raza'] ?? '',       
      age: map['edad'] ?? '',         
      gender: map['sexo'] ?? '',        
      status: map['estado'] ?? 'Disponible',
      description: map['descripcion'] ?? '', 
      image: map['imagen_url'] ?? '',       
    );
  }
}