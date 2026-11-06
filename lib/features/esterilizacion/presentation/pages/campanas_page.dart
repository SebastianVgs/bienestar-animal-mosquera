import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:bienestar_animal_app/features/esterilizacion/models/campana_model.dart';
import 'package:bienestar_animal_app/features/esterilizacion/data/esterilizacion_repository.dart';

class CampanasPage extends StatefulWidget {
  const CampanasPage({super.key});

  @override
  State<CampanasPage> createState() => _CampanasPageState();
}

class _CampanasPageState extends State<CampanasPage> {
  // Estado para controlar la pestaña
  bool _isEsterilizacionSelected = true;
  
  // Future que contendrá los datos de Supabase
  late Future<List<CampanaModel>> _campanasFuture;

  @override
  void initState() {
    super.initState();
    _cargarCampanas(); // Cargamos la pestaña por defecto al iniciar
  }

  void _cargarCampanas() {
    final tipo = _isEsterilizacionSelected ? 'esterilizacion' : 'desparasitacion';
    _campanasFuture = EsterilizacionRepository.getCampanas(tipo);
  }

  // (Mantenemos tu método build() y _buildHeader() exactamente igual)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildFilterButtons(),
              const SizedBox(height: 20),
              _buildCampaignCards(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Encabezado con botón de volver y título
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
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
          Expanded(
            child: Text(
              'CAMPAÑAS DE BIENESTAR ANIMAL',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 42), // Espaciador simétrico
        ],
      ),
    );
  }

  // 2. Botones de filtro superiores (Esterilización / Desparasitación)
  Widget _buildFilterButtons() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // BOTÓN 1: ESTERILIZACIÓN
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isEsterilizacionSelected = true;
                  _cargarCampanas(); // Volvemos a consultar a Supabase al tocar
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isEsterilizacionSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isEsterilizacionSelected
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Esterilización',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _isEsterilizacionSelected ? AppColors.textPrimary : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),

          // BOTÓN 2: DESPARASITACIÓN
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isEsterilizacionSelected = false;
                  _cargarCampanas(); // Volvemos a consultar a Supabase al tocar
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isEsterilizacionSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_isEsterilizacionSelected
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Desparasitación',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: !_isEsterilizacionSelected ? AppColors.textPrimary : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Tarjetas con las campañas según el filtro seleccionado usando CampanaModel tipado
  Widget _buildCampaignCards() {
    return FutureBuilder<List<CampanaModel>>(
      future: _campanasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Error al cargar las campañas.', style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        final currentList = snapshot.data ?? [];

        if (currentList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                _isEsterilizacionSelected 
                    ? 'No hay jornadas de esterilización agendadas.'
                    : 'No hay jornadas de desparasitación agendadas.',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: currentList.length,
          itemBuilder: (context, index) {
            final CampanaModel campaign = currentList[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Imagen de red segura
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      campaign.image,
                      height: 190,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 190,
                        color: Colors.grey.withValues(alpha: 0.2),
                        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 190,
                          color: Colors.grey.withValues(alpha: 0.2),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    campaign.date,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    campaign.location,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    campaign.schedule,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}