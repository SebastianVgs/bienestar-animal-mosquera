// lib/features/voluntariado/models/voluntariado_model.dart

class VoluntariadoModel {
  final String nombreCompleto;
  final String telefono;
  final String direccion;
  final String tipoVivienda;
  final bool tieneMascotas;

  const VoluntariadoModel({
    required this.nombreCompleto,
    required this.telefono,
    required this.direccion,
    required this.tipoVivienda,
    required this.tieneMascotas,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre_completo': nombreCompleto,
      'telefono': telefono,
      'direccion': direccion,
      'tipo_vivienda': tipoVivienda,
      'tiene_mascotas': tieneMascotas,
    };
  }
}