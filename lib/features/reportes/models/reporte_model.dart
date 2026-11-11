class ReporteModel {
  final String? id;
  final String descripcion;
  final String direccion;
  final String? evidenciaUrl;
  final String estado;
  final String fecha;
  final String? iaGravedad;
  final String? iaResumen;
  final String? telefonoContacto;

  ReporteModel({
    this.id,
    required this.descripcion,
    required this.direccion,
    this.evidenciaUrl,
    required this.estado,
    required this.fecha,
    this.iaGravedad,
    this.iaResumen,
    this.telefonoContacto,
  });

  factory ReporteModel.fromJson(Map<String, dynamic> json) {
    try {
      final rawEvidencia = json['evidencia_url'];
      String? finalUrl;

      if (rawEvidencia != null) {
        final stringValue = rawEvidencia.toString();
        if (stringValue.startsWith('http')) {
          finalUrl = stringValue;
        }
      }

      return ReporteModel(
        id: json['id']?.toString() ?? 'ID_NO_DISPONIBLE',
        descripcion: json['descripcion']?.toString() ?? 'Sin descripción',
        direccion: json['direccion']?.toString() ?? 'Sin dirección',
        evidenciaUrl: finalUrl,
        estado: json['estado']?.toString() ?? 'RECIBIDO',
        fecha: json['creado_en']?.toString() ?? 'Fecha no disponible',
        iaGravedad: json['ia_gravedad']?.toString(),
        iaResumen: json['ia_resumen']?.toString(),
        // MAPEO DEL NUEVO CAMPO
        telefonoContacto: json['telefono_contacto']?.toString(),
      );
    } catch (e) {
      print('🔥 Error Mapeando JSON: $e');
      return ReporteModel(
        id: 'ERROR',
        descripcion: 'Error al leer reporte',
        direccion: '',
        estado: 'ERROR',
        fecha: '',
      );
    }
  }
}