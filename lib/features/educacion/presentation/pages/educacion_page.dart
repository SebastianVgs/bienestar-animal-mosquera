// lib/features/educacion/presentation/pages/educacion_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/evento_model.dart';
import '../../data/educacion_repository.dart';
import 'detalle_evento_page.dart';

class EducacionPage extends StatefulWidget {
  const EducacionPage({super.key});

  @override
  State<EducacionPage> createState() => _EducacionPageState();
}

class _EducacionPageState extends State<EducacionPage> {
  bool _isFinalizadasSelected = false;
  late Future<List<EventoModel>> _eventosFuture;

  // Variables del Carrusel
  final PageController _pageController = PageController();
  Timer? _timer;
  
  int _currentPage = 0;
  
  List<String> _carruselImages = []; // Ahora nace vacía
  bool _isLoadingCarrusel = true; // Bandera para saber si Supabase está cargando

  @override
  void initState() {
    super.initState();
    _cargarEventos();
    _cargarCarruselDesdeSupabase();
  }

  Future<void> _cargarCarruselDesdeSupabase() async {
    final imagenes = await EducacionRepository.getImagenesCarrusel();
    
    if (mounted) {
      setState(() {
        _carruselImages = imagenes;
        _isLoadingCarrusel = false;
      });
      
      // Solo iniciamos el temporizador si llegaron imágenes
      if (_carruselImages.isNotEmpty) {
        _iniciarCarrusel();
      }
    }
  }

  void _cargarEventos() {
    _eventosFuture = EducacionRepository.getEventos(_isFinalizadasSelected);
  }

  void _iniciarCarrusel() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      int nextPage = _currentPage + 1;
      if (nextPage >= _carruselImages.length) {
        nextPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildHeader(context),
            ),
            _buildCarousel(),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Jornadas de Educación y Sensibilización',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildFilterButtons(),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: FutureBuilder<List<EventoModel>>(
                future: _eventosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error al cargar los eventos', style: TextStyle(color: Colors.grey)),
                    );
                  }

                  final eventos = snapshot.data ?? [];

                  if (eventos.isEmpty) {
                    return Center(
                      child: Text(
                        _isFinalizadasSelected 
                            ? 'No hay eventos finalizados registrados.'
                            : 'No hay eventos próximos programados.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return _buildEventosList(eventos);
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
            'EDUCACIÓN Y SENSIBILIZACIÓN',
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

  Widget _buildCarousel() {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _isLoadingCarrusel 
              // 1. Mientras carga, mostramos un recuadro gris sutil
              ? Container(color: Colors.grey.withValues(alpha: 0.2)) 
              : _carruselImages.isEmpty
                  // 2. Si cargó pero no hay fotos en la BD, mostramos un icono
                  ? Container(
                      color: Colors.grey.withValues(alpha: 0.2),
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    )
                  // 3. Si hay fotos, usamos Image.network a prueba de fallos
                  : PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemCount: _carruselImages.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          _carruselImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.withValues(alpha: 0.2),
                            child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          ),
                        );
                      },
                    ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _carruselImages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  // Si es la imagen actual, ancho de 22 (píldora), sino 8 (círculo)
                  width: _currentPage == index ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    // Usamos withValues para corregir la línea azul
                    color: _currentPage == index 
                        ? Colors.white 
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Fondo unificado del switch
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isFinalizadasSelected = false; 
                  _cargarEventos(); 
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  // Fondo blanco y sombra solo si está seleccionado
                  color: !_isFinalizadasSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_isFinalizadasSelected 
                      ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] 
                      : [],
                ),
                child: Center(
                  child: Text(
                    'Próximas',
                    style: TextStyle(
                      color: !_isFinalizadasSelected ? Colors.black87 : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isFinalizadasSelected = true; 
                  _cargarEventos(); 
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  // Fondo blanco y sombra solo si está seleccionado
                  color: _isFinalizadasSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isFinalizadasSelected 
                      ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] 
                      : [],
                ),
                child: Center(
                  child: Text(
                    'Finalizadas',
                    style: TextStyle(
                      color: _isFinalizadasSelected ? Colors.black87 : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventosList(List<EventoModel> eventos) {
    final accentColor = _isFinalizadasSelected ? AppColors.error : AppColors.secondary;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: eventos.length,
      itemBuilder: (context, index) {
        final evento = eventos[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        evento.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (_isFinalizadasSelected)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalleEventoPage(
                                  title: evento.title,
                                  location: evento.location,
                                  date: evento.date,
                                  description: evento.description ?? '',
                                  imagePath: evento.image ?? '',
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Ver Detalles',
                            style: TextStyle(
                              fontSize: 13,
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.location_on, size: 16, color: accentColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        evento.location,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, letterSpacing: -0.1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.calendar_month, size: 16, color: accentColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        evento.date,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, letterSpacing: -0.1),
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
  }
}