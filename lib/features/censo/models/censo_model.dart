// lib/features/censo/models/censo_model.dart

class CensoModel {
  final String id;
  final String especie; // 'Perro' o 'Gato'
  final String nombreMascota;
  final String raza;
  final int edad;
  final String unidadEdad; // 'Años' o 'Meses'
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
    this.unidadEdad = 'Años',
    required this.sexo,
    required this.nombrePropietario,
    required this.documentoPropietario,
    required this.telefono,
    required this.direccion,
    required this.fechaRegistro,
  });

  factory CensoModel.fromJson(Map<String, dynamic> json) {
    return CensoModel(
      id: json['id']?.toString() ?? '',
      especie: json['especie']?.toString() ?? 'Perro',
      nombreMascota: json['nombre_mascota']?.toString() ?? 'Sin nombre',
      raza: json['raza']?.toString() ?? 'Criollo',
      edad: (json['edad'] is num)
          ? (json['edad'] as num).toInt()
          : int.tryParse(json['edad']?.toString() ?? '0') ?? 0,
      unidadEdad: json['unidad_edad']?.toString() ?? 'Años',
      sexo: json['sexo']?.toString() ?? 'Macho',
      nombrePropietario: json['nombre_propietario']?.toString() ?? '',
      documentoPropietario: json['documento_propietario']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.tryParse(json['fecha_registro'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'especie': especie,
      'nombre_mascota': nombreMascota,
      'raza': raza,
      'edad': edad,
      'unidad_edad': unidadEdad,
      'sexo': sexo,
      'nombre_propietario': nombrePropietario,
      'documento_propietario': documentoPropietario,
      'telefono': telefono,
      'direccion': direccion,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }
}