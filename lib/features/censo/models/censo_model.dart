// lib/features/censo/models/censo_model.dart

class CensoModel {
  final String id;
  final String especie; // 'Perro' o 'Gato'
  final String nombreMascota;
  final String raza;
  final int edad;
  final String sexo; // 'Macho' o 'Hembra'
  final String nombrePropietario;
  final String documentoPropietario;
  final String telefono;
  final String direccion;
  final DateTime fechaRegistro;

  const CensoModel({
    required this.id,
    required this.especie,
    required this.nombreMascota,
    required this.raza,
    required this.edad,
    required this.sexo,
    required this.nombrePropietario,
    required this.documentoPropietario,
    required this.telefono,
    required this.direccion,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // OMITIMOS EL ID para que Supabase lo autogenere
      'especie': especie,
      'nombre_mascota': nombreMascota,
      'raza': raza,
      'edad': edad,
      'sexo': sexo,
      'nombre_propietario': nombrePropietario,
      'documento_propietario': documentoPropietario,
      'telefono': telefono,
      'direccion': direccion,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }
}