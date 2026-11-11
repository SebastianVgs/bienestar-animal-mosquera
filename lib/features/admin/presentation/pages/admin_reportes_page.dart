// lib/features/admin/presentation/pages/admin_reportes_page.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/admin_reportes_repository.dart';

class AdminReportesPage extends StatelessWidget {
  const AdminReportesPage({super.key});

  Color _getColorPorEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'RECIBIDO': return Colors.blue.shade600;
      case 'EN_EVALUACION':
      case 'EN EVALUACIÓN': return Colors.orange.shade600;
      case 'ATENDIDO': return Colors.green.shade600;
      case 'DESCARTADO':
      case 'RECHAZADO': return Colors.grey.shade600;
      default: return Colors.blue.shade600;
    }
  }

  Color _getColorPorUrgencia(String urgencia) {
    final u = urgencia.toUpperCase();
    if (u.contains('ALTA') || u.contains('CRÍTICA')) return Colors.red.shade700;
    if (u.contains('MEDIA')) return Colors.orange.shade700;
    if (u.contains('BAJA')) return Colors.blue.shade500;
    if (u.contains('RECHAZAD') || u.contains('DESCARTAD')) return Colors.grey.shade500; 
    return Colors.teal.shade500;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Fondo hueso de la app
      appBar: AppBar(
        backgroundColor: AppColors.background, // Fondo hueso del AppBar
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Gestión de Reportes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.circularButtonBackground,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.circularButtonIcon),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: AdminReportesRepository.obtenerReportesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar: ${snapshot.error}'));
          }
          
          final reportes = snapshot.data ?? [];
          
          if (reportes.isEmpty) {
            return const Center(child: Text('No hay reportes nuevos.', style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final reporte = reportes[index];
              
              String estadoActual = (reporte['estado'] ?? 'RECIBIDO').toString().toUpperCase();
              if (estadoActual == 'EN EVALUACIÓN') estadoActual = 'EN_EVALUACION';
              
              const posiblesEstados = ['RECIBIDO', 'EN_EVALUACION', 'ATENDIDO', 'DESCARTADO'];
              if (!posiblesEstados.contains(estadoActual)) {
                estadoActual = 'RECIBIDO';
              }

              final imageUrl = reporte['evidencia_url']?.toString() ?? '';
              final hasValidUrl = imageUrl.isNotEmpty && imageUrl.startsWith('http');
              
              final fecha = reporte['creado_en'] != null 
                  ? reporte['creado_en'].toString().split('T')[0] 
                  : '--/--/----';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 1.5, // Sombra más sutil
                shadowColor: Colors.black.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fila 1: ID y Etiqueta de Urgencia
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'ID: ${reporte['id'].toString().substring(0, 8)}...',
                              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade400, fontSize: 12),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getColorPorUrgencia(reporte['nivel_urgencia'] ?? '').withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flag_rounded, size: 12, color: _getColorPorUrgencia(reporte['nivel_urgencia'] ?? '')),
                                const SizedBox(width: 4),
                                Text(
                                  (reporte['nivel_urgencia'] ?? 'Desconocida').toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    color: _getColorPorUrgencia(reporte['nivel_urgencia'] ?? ''),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Fila 2: Imagen y Texto
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: hasValidUrl
                                ? Image.network(
                                    imageUrl,
                                    width: 85,
                                    height: 85,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildErrorImageMini(),
                                  )
                                : _buildErrorImageMini(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.auto_awesome, color: Colors.deepPurple.shade400, size: 14),
                                    const SizedBox(width: 4),
                                    Text('ANÁLISIS IA', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.deepPurple.shade400, fontSize: 10, letterSpacing: 0.5)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  reporte['ia_resumen'] ?? reporte['descripcion'] ?? 'Sin información proporcionada.',
                                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.3, fontWeight: FontWeight.w500),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Fila 3: Detalles operativos (Mejor contraste)
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 15, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Text(fecha, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 16),
                          Icon(Icons.phone_rounded, size: 15, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Text(reporte['telefono_contacto'] ?? 'N/A', style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_rounded, size: 15, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              reporte['direccion'] ?? 'Ubicación no especificada',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)), 
                      ),
                      
                      // Fila 4: Dropdown de Estado (Rediseñado delgado)
                      Row(
                        children: [
                          Text('Estado:', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 38, // Altura delgada
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: estadoActual,
                                  isExpanded: true,
                                  isDense: true, // Quita padding innecesario de Flutter
                                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500, size: 20),
                                  items: posiblesEstados.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _getColorPorEstado(value),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            value.replaceAll('_', ' '),
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? nuevoEstado) async {
                                    if (nuevoEstado != null && nuevoEstado != estadoActual) {
                                      try {
                                        await AdminReportesRepository.actualizarEstado(reporte['id'].toString(), nuevoEstado);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Estado actualizado', style: TextStyle(fontWeight: FontWeight.bold)),
                                              backgroundColor: Colors.green.shade700, 
                                              behavior: SnackBarBehavior.floating, // Estilo flotante
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              duration: const Duration(seconds: 2)
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: ${e.toString()}'), 
                                              backgroundColor: Colors.red.shade700,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorImageMini() {
    return Container(
      width: 85,
      height: 85,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(Icons.image_not_supported_rounded, size: 28, color: Colors.grey.shade300),
    );
  }
}