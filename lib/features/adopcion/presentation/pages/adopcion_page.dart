// lib/features/adopcion/presentation/pages/adopcion_page.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/adopcion_model.dart';
import '../../data/adopcion_repository.dart';
import 'detalle_adopcion_page.dart';

class AdopcionPage extends StatefulWidget {
  const AdopcionPage({super.key});

  @override
  State<AdopcionPage> createState() => _AdopcionPageState();
}

class _AdopcionPageState extends State<AdopcionPage> {
  // Inicializamos el Future de forma segura
  late Future<List<AdopcionModel>> _mascotasFuture;

  @override
  void initState() {
    super.initState();
    _mascotasFuture = AdopcionRepository.getMascotasDisponibles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // Utilizamos Column como contenedor principal para distribuir el espacio
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildHeader(context),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Mascotas en busca de un hogar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Expanded toma todo el espacio vertical restante para la lista
            Expanded(
              child: FutureBuilder<List<AdopcionModel>>(
                future: _mascotasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Error al cargar la lista de adopción.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final mascotas = snapshot.data ?? [];

                  if (mascotas.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay mascotas disponibles en este momento.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return _buildMascotasList(context, mascotas);
                },
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
        const Expanded(
          child: Text(
            'ADOPCIÓN RESPONSABLE',
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

  Widget _buildMascotasList(BuildContext context, List<AdopcionModel> mascotas) {
    // La lista ahora maneja su propio scroll internamente
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: mascotas.length,
      itemBuilder: (context, index) {
        final mascota = mascotas[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mascota.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mascota.breed,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${mascota.type}  •  ${mascota.age}  •  ${mascota.gender}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleAdopcionPage(mascota: mascota),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}