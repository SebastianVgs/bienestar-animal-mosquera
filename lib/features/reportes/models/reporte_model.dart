class ReporteModel {
  final String? id;
  final String descripcion;
  final String direccion;
  final String? evidenciaUrl;
  final String estado;
  final String fecha;

  ReporteModel({
    this.id,
    required this.descripcion,
    required this.direccion,
    this.evidenciaUrl,
    required this.estado,
    required this.fecha,
  });

  factory ReporteModel.fromJson(Map<String, dynamic> json) {
    try {
      // 1. Obtenemos el valor crudo de la evidencia
      final rawEvidencia = json['evidencia_url'];
      String? finalUrl;

      // 2. Validamos que sea un texto y que realmente parezca un enlace HTTP
      if (rawEvidencia != null) {
        final stringValue = rawEvidencia.toString();
        if (stringValue.startsWith('http')) {
          finalUrl = stringValue;
        }
      }

      return ReporteModel(
        id: json['id']?.toString() ?? 'ID_NO_DISPONIBLE', // Protegido contra nulos
        descripcion: json['descripcion']?.toString() ?? 'Sin descripción', // Protegido
        direccion: json['direccion']?.toString() ?? 'Sin dirección', // Protegido
        evidenciaUrl: finalUrl, 
        estado: json['estado']?.toString() ?? 'RECIBIDO', // Protegido
        fecha: json['creado_en']?.toString() ?? 'Fecha no disponible', // Protegido
      );
    } catch (e) {
      // Si falla algo durante la conversión, imprimimos el error pero no rompemos la app
      print('🔥 Error Mapeando JSON en ReporteModel: $e');
      print('Datos que causaron el error: $json');
      // Devolvemos un reporte de "error" por defecto para que la lista siga funcionando
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