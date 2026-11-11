// lib/features/admin/presentation/pages/admin_dashboard_page.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/auth_repository.dart';
import 'admin_reportes_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    await AuthRepository.signOut();
    if (context.mounted) {
      Navigator.pop(context); // Regresa a la pantalla de Login / Home
    }
  }

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
              _buildHeader(context),
              const SizedBox(height: 24),
              const Text(
                'Panel de Control',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textSecondary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Seleccione un módulo para gestionar la información.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildAdminGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shield, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alcaldía de Mosquera',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Modo Administrador',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          tooltip: 'Cerrar Sesión',
          onPressed: () => _cerrarSesion(context),
        ),
      ],
    );
  }

  Widget _buildAdminGrid(BuildContext context) {
    // Declaración con tipado estricto
    final List<Map<String, dynamic>> modulos = [
      {
        'titulo': 'Educación y Sensibilización',
        'imagen': 'assets/icons/IconoSensibilizacion.png',
        'color': AppColors.secondary,
        'ruta': '/admin_educacion',
      },
      {
        'titulo': 'Esterilización y Desparasitación',
        'imagen': 'assets/icons/IconoEsterilizacion.png',
        'color': AppColors.secondary,
        'ruta': '/admin_campanas',
      },
      {
        'titulo': 'Adopción',
        'imagen': 'assets/icons/IconoAdopcion.png',
        'color': AppColors.secondary,
        'ruta': '/admin_adopciones',
      },
      {
        'titulo': 'Reportes de Maltrato',
        'imagen': 'assets/icons/IconoReportes.png',
        'color': AppColors.secondary,
        'ruta': '/admin_reportes', 
      },
      {
        'titulo': 'Censo de Mascotas',
        'imagen': 'assets/icons/IconoCenso.png',
        'color': AppColors.secondary,
        'ruta': '/admin_censo',
      },
      {
        'titulo': 'Clínicas Veterinarias',
        'imagen': 'assets/icons/IconoVeterinarias.png',
        'color': AppColors.secondary,
        'ruta': '/admin_veterinarias',
      },
      {
        'titulo': 'Voluntariado',
        'imagen': 'assets/icons/IconoVoluntariado.png',
        'color': AppColors.secondary,
        'ruta': '/admin_voluntariado',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15, // Ajustado para coincidir con home_page
      ),
      itemCount: modulos.length,
      itemBuilder: (context, index) {
        final modulo = modulos[index];

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (modulo['titulo'] == 'Reportes de Maltrato') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminReportesPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Módulo ${modulo['titulo']} en desarrollo')),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0), // Ajustado para coincidir con home_page
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    modulo['imagen'] as String,
                    width: 70, 
                    height: 70,
                    color: AppColors.textPrimary, // Aplicando el mismo color que en home_page
                  ),
                  const SizedBox(height: 8),
                  Text(
                    modulo['titulo'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15, // Ajustado para coincidir con home_page
                      fontWeight: FontWeight.w700, // Ajustado para coincidir con home_page
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2, // Ajustado para coincidir con home_page
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}