import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/reporte_model.dart';

class DetalleReportePage extends StatelessWidget {
  final ReporteModel reporte;

  const DetalleReportePage({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
    // Verificación segura de la URL (misma lógica que en la lista)
    final bool hasUrl = reporte.evidenciaUrl != null &&
        reporte.evidenciaUrl!.isNotEmpty &&
        reporte.evidenciaUrl!.startsWith('http');

    // Extraer solo la fecha de la marca de tiempo (YYYY-MM-DD)
    final String fechaFormateada = reporte.fecha.isNotEmpty && reporte.fecha.length >= 10
        ? reporte.fecha.substring(0, 10)
        : 'Fecha no disponible';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. ENCABEZADO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildHeader(context),
            ),
            
            // 2. CONTENIDO SCROLLABLE
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. Imagen grande
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: hasUrl
                          ? Image.network(
                              reporte.evidenciaUrl!,
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                            )
                          : _buildErrorImage(),
                    ),
                    const SizedBox(height: 24),
                    
                    // B. Estado y Fecha
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getColorForEstado(reporte.estado).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Estado: ${reporte.estado}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getColorForEstado(reporte.estado),
                            ),
                          ),
                        ),
                        Text(
                          fechaFormateada,
                          style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // C. Descripción del usuario
                    const Text('Descripción del Incidente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        reporte.descripcion,
                        style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // D. Dirección
                    const Text('Ubicación Reportada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reporte.direccion,
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),

                    // E. Teléfono de contacto (Solo si existe)
                    if (reporte.telefonoContacto != null && reporte.telefonoContacto!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text('Contacto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: AppColors.primary, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            reporte.telefonoContacto!,
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.circularButtonBackground,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.circularButtonIcon),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const Expanded(
          child: Text(
            'DETALLE DEL REPORTE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
        ),
        const SizedBox(width: 42),
      ],
    );
  }

  Widget _buildErrorImage() {
    return Container(
      width: double.infinity,
      height: 250,
      color: Colors.grey.shade200,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text('Imagen no disponible', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getColorForEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'RECIBIDO':
        return Colors.blue;
      case 'EN EVALUACIÓN':
      case 'EN_EVALUACION':
        return Colors.orange;
      case 'ATENDIDO':
      case 'CERRADO':
        return Colors.green;
      case 'RECHAZADO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}