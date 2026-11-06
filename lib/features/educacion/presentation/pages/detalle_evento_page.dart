import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DetalleEventoPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final String location;
  final String date;

  const DetalleEventoPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.location,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Encabezado con Botón de Regresar y Título
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
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
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.circularButtonIcon,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    'ACERCA DE ESTE EVENTO',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Imagen dinámica del evento
             Container(
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(20),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withValues(alpha: 0.2),
                     blurRadius: 8,
                     offset: const Offset(0, 4),
                   ),
                 ],
               ),
               child: ClipRRect(
                 borderRadius: BorderRadius.circular(20),
                 child: imagePath.isEmpty
                     // 1. Si no hay imagen (texto vacío), mostramos un contenedor gris con un ícono
                     ? Container(
                         height: 220,
                         width: double.infinity,
                         color: Colors.grey.withValues(alpha: 0.2),
                         child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                       )
                     // 2. Si la ruta empieza con 'http', es de Supabase, usamos Image.network
                     : (imagePath.startsWith('http') 
                         ? Image.network(
                             imagePath,
                             height: 220,
                             width: double.infinity,
                             fit: BoxFit.cover,
                             // Si el link falla por alguna razón, no se rompe, muestra este error
                             errorBuilder: (context, error, stackTrace) => Container(
                               height: 220,
                               color: Colors.grey.withValues(alpha: 0.2),
                               child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                             ),
                           )
                         // 3. Si no es web, asume que es local (assets)
                         : Image.asset(
                             imagePath,
                             height: 220,
                             width: double.infinity,
                             fit: BoxFit.cover,
                             errorBuilder: (context, error, stackTrace) => Container(
                               height: 220,
                               color: Colors.grey.withValues(alpha: 0.2),
                               child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                             ),
                           )),
               ),
             ),
              const SizedBox(height: 24),

              // 3. Título dinámico
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),

              // 4. Ubicación y Fecha con protección anti-desbordamiento (Wrap)
              Wrap(
                spacing: 16.0,
                runSpacing: 8.0,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.error),
                      const SizedBox(width: 6),
                      Text(
                        location,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month, size: 16, color: AppColors.error),
                      const SizedBox(width: 6),
                      Text(
                        date,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Descripción del evento
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}