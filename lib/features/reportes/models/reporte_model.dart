class ReporteModel {
  final String? id;
  final String descripcion;
  final String direccion;
  final String? evidenciaUrl;
  final String estado;
  final String fecha;
  
  // 1. NUEVOS CAMPOS DE LA IA (Opcionales, por si los reportes viejos no los tienen)
  final String? iaGravedad;
  final String? iaResumen;

  ReporteModel({
    this.id,
    required this.descripcion,
    required this.direccion,
    this.evidenciaUrl,
    required this.estado,
    required this.fecha,
    this.iaGravedad,
    this.iaResumen,
  });

  factory ReporteModel.fromJson(Map<String, dynamic> json) {
    try {
      // Obtenemos el valor crudo de la evidencia
      final rawEvidencia = json['evidencia_url'];
      String? finalUrl;

      // Validamos que sea un texto y que realmente parezca un enlace HTTP
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
        
        // 2. MAPEO DE LOS NUEVOS CAMPOS DE LA IA
        iaGravedad: json['ia_gravedad']?.toString(),
        iaResumen: json['ia_resumen']?.toString(),
      );
    } catch (e) {
      print('🔥 Error Mapeando JSON en ReporteModel: $e');
      print('Datos que causaron el error: $json');
      return ReporteModel(
        id: 'ERROR',
        descripcion: 'Error al leer este reporte de la base de datos.',
        direccion: '',
        estado: 'ERROR',
        fecha: '',
      );
    }
  }
}