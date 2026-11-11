import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import 'package:bienestar_animal_app/features/educacion/presentation/pages/educacion_page.dart';
import 'package:bienestar_animal_app/features/esterilizacion/presentation/pages/campanas_page.dart';
import 'package:bienestar_animal_app/features/adopcion/presentation/pages/adopcion_page.dart';
import 'package:bienestar_animal_app/features/reportes/presentation/pages/reportes_page.dart';
import 'package:bienestar_animal_app/features/censo/presentation/pages/censo_page.dart';
import 'package:bienestar_animal_app/features/veterinarias/presentation/pages/clinica_mapa_page.dart';
import 'package:bienestar_animal_app/features/voluntariado/presentation/pages/voluntariado_page.dart';
import 'package:bienestar_animal_app/features/admin/presentation/pages/admin_login_page.dart';

// Lista de eventos simulados (Mock data) que luego vendrán de Supabase
final List<Map<String, dynamic>> _proximosEventosMock = [
  {
    'titulo': 'Gran Jornada de Adopción',
    'ubicacion': 'Parque Principal',
    'fecha': 'Sábado 18 de Octubre',
    'descripcion': 'Únete a nosotros en una jornada llena de amor. Muchos peluditos rescatados estarán esperando encontrar un hogar definitivo. Habrá feria de emprendimientos locales, charlas sobre tenencia responsable y actividades para toda la familia.',
    'icono': Icons.favorite,
    'color': AppColors.secondary,
  },
  {
    'titulo': 'Jornada de Vacunación Antirrábica',
    'ubicacion': 'Parque Rincón del Trébol',
    'fecha': 'Miércoles 22 de Octubre',
    'descripcion': 'Protege la salud de tu mascota y la de tu comunidad. Estaremos realizando una jornada de vacunación antirrábica totalmente gratuita para perros y gatos mayores de 3 meses que no hayan sido vacunados durante el último año.',
    'icono': Icons.medical_services,
    'color': AppColors.primary,
  },
  {
    'titulo': 'Taller Práctico: Primeros Auxilios',
    'ubicacion': 'Auditorio Municipal',
    'fecha': 'Viernes 24 de Octubre',
    'descripcion': 'Capacitación vital dirigida a cuidadores de mascotas. Aprenderás las técnicas básicas de primeros auxilios para atender emergencias comunes (atragantamiento, heridas leves, golpes de calor) mientras te trasladas a una clínica veterinaria.',
    'icono': Icons.school,
    'color': Colors.blue,
  },
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              _buildBannerUnidadesMoviles(),
              const SizedBox(height: 20),
              const Text(
                'Seleccione una opción',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildGridOpciones(context),
              const SizedBox(height: 20),
              _buildAgendaEventosCard(context),
            ],
          ),
        ),
      ),
    );
  }
  
  // Función que despliega la tira hacia arriba con los eventos detallados
 void _mostrarListaEventosDetallada(BuildContext context) {
   showModalBottomSheet(
     context: context,
     isScrollControlled: true, // Permite que el modal ocupe más espacio si la lista es larga
     backgroundColor: Colors.transparent, // Necesario para que las esquinas superiores redondeadas funcionen
     builder: (BuildContext context) {
       return Container(
         // El panel ocupará máximo el 75% de la altura de la pantalla
         height: MediaQuery.of(context).size.height * 0.75,
         decoration: const BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.only(
             topLeft: Radius.circular(20),
             topRight: Radius.circular(20),
           ),
         ),
         child: Column(
           children: [
             // Barra visual superior de "arrastre"
             Container(
               margin: const EdgeInsets.symmetric(vertical: 12),
               width: 40,
               height: 5,
               decoration: BoxDecoration(
                 color: Colors.grey.shade300,
                 borderRadius: BorderRadius.circular(10),
               ),
             ),
             // Título del modal
             const Padding(
               padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
               child: Text(
                 'Próximos Eventos y Jornadas',
                 style: TextStyle(
                   fontSize: 18,
                   fontWeight: FontWeight.bold,
                   color: AppColors.textPrimary,
                 ),
               ),
             ),
             const Divider(),
             // Lista detallada de eventos
             Expanded(
               child: ListView.builder(
                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                 itemCount: _proximosEventosMock.length,
                 itemBuilder: (context, index) {
                   final evento = _proximosEventosMock[index];
                   return Card(
                     margin: const EdgeInsets.only(bottom: 16),
                     elevation: 1,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     child: Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           // Fila 1: Icono colorido y Título
                           Row(
                             children: [
                               Container(
                                 padding: const EdgeInsets.all(8),
                                 decoration: BoxDecoration(
                                   color: (evento['color'] as Color).withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(8),
                                 ),
                                 child: Icon(evento['icono'] as IconData, color: evento['color'] as Color, size: 20),
                               ),
                               const SizedBox(width: 12),
                               Expanded(
                                 child: Text(
                                   evento['titulo'],
                                   style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 12),
                           // Fila 2: Información de Ubicación y Fecha
                           Row(
                             children: [
                               const Icon(Icons.location_on, size: 14, color: Colors.grey),
                               const SizedBox(width: 4),
                               Expanded(child: Text(evento['ubicacion'], style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
                               const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                               const SizedBox(width: 4),
                               Text(evento['fecha'], style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                             ],
                           ),
                           const SizedBox(height: 12),
                           // Fila 3: Descripción detallada (La adición solicitada)
                           Text(
                             evento['descripcion'],
                             style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                           ),
                         ],
                       ),
                     ),
                   );
                 },
               ),
             ),
           ],
         ),
       );
     },
   );
 }

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
              tooltip: AppStrings.volverSuperApp,
              onPressed: () {},
            ),
          ),
          const Text(
            'BIENESTAR ANIMAL',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
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
               Icons.admin_panel_settings_outlined, // CAMBIAMOS EL ICONO
               size: 24,
               color: AppColors.circularButtonIcon,
             ),
             tooltip: 'Acceso Funcionarios', // ACTUALIZAMOS EL TOOLTIP
             onPressed: () {
               // AÑADIMOS LA NAVEGACIÓN A LA PANTALLA DE LOGIN
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const AdminLoginPage()),
               );
             },
           ),
         ),
        ],
      ),
    );
  }

  Widget _buildBannerUnidadesMoviles() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // Tu sombra personalizada
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 220, // Tu altura personalizada
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Capa 1: La imagen de fondo
              Image.asset(
                'assets/images/imagen_pantalla_principal.jpg',
                fit: BoxFit.cover,
              ),
              
              // Capa 2: El filtro de degradado blanco
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.white.withOpacity(0.45), // Intensidad del blanco arriba
                      Colors.white.withOpacity(0.0),  // Se desvanece hacia abajo
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Rejilla de 2 columnas
  Widget _buildGridOpciones(BuildContext context) {
    final List<Map<String, dynamic>> opciones = [
      {
        'titulo': AppStrings.educacionSensibilizacion,
        'imagen': 'assets/icons/IconoSensibilizacion.png',
        'color': AppColors.secondary,
      },
      {
        'titulo': AppStrings.esterilizacionDesparasitacion,
        'imagen': 'assets/icons/IconoEsterilizacion.png',
        'color': AppColors.secondary,
      },
      {
        'titulo': AppStrings.adopcion,
        'imagen': 'assets/icons/IconoAdopcion.png',
        'color': AppColors.secondary,
      },
      {
        'titulo': AppStrings.reportesMaltrato,
        'imagen': 'assets/icons/IconoReportes.png',
        'color': AppColors.secondary,
      },
      {
        'titulo': AppStrings.censoMascotas,
        'imagen': 'assets/icons/IconoCenso.png',
        'color': AppColors.secondary,
      },
      {
        'titulo': AppStrings.clinicasVeterinarias,
        'imagen': 'assets/icons/IconoVeterinarias.png',
        'color': AppColors.secondary,
      },
      {
        'titulo': AppStrings.voluntariado,
        'imagen': 'assets/icons/IconoVoluntariado.png',
        'color': AppColors.secondary,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columnas fijas
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: opciones.length,
      itemBuilder: (context, index) {
        final item = opciones[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            // Ejemplo de cómo debería quedar el onTap en tu home_page.dart
          // En lib/features/home/presentation/pages/home_page.dart
// Dentro de _buildGridItem > InkWell > onTap:

            onTap: () {
              if (item['titulo'] == AppStrings.educacionSensibilizacion) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EducacionPage()),
                );
              } else if (item['titulo'] == AppStrings.esterilizacionDesparasitacion) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CampanasPage()),
                );
              } else if (item['titulo'] == AppStrings.adopcion) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdopcionPage()),
                );
              } else if (item['titulo'] == AppStrings.reportesMaltrato) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportesPage()),
                );
              } else if (item['titulo'] == AppStrings.censoMascotas) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CensoPage()),
                );
              } else if (item['titulo'] == AppStrings.clinicasVeterinarias) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClinicasMapaPage()),
                );
              } else if (item['titulo'] == AppStrings.voluntariado) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VoluntariadoPage()),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Image.asset(
                  item['imagen'] as String,
                  width: 70,  
                  height: 70,
                  color: AppColors.textPrimary, 
                ),
                  const SizedBox(height: 8),
                  Text(
                    item['titulo'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
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

  // Tarjeta de eventos sin línea divisora y en tonos verde menta
  // Tarjeta de eventos con funcionalidad interactiva "Ver Más"
 Widget _buildAgendaEventosCard(BuildContext context) { // Añadido el context aquí
   return Card(
     elevation: 2,
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(16),
     ),
     child: Padding(
       padding: const EdgeInsets.all(16.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               const Text(
                 AppStrings.proximosEventos,
                 style: TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.bold,
                   color: AppColors.textPrimary,
                   letterSpacing: -0.2,
                 ),
               ),
               // Aquí envolvemos "Ver Más" para hacerlo clickeable
               GestureDetector(
                 onTap: () => _mostrarListaEventosDetallada(context),
                 child: const Text(
                   AppStrings.verMas,
                   style: TextStyle(
                     fontSize: 13,
                     color: AppColors.secondary,
                     fontWeight: FontWeight.w800,
                     letterSpacing: -0.1,
                   ),
                 ),
               ),
             ],
           ),
           const SizedBox(height: 12),
           // Mostramos el primer evento de la lista como vista previa
           ListTile(
             contentPadding: EdgeInsets.zero,
             leading: Container(
               padding: const EdgeInsets.all(10),
               decoration: BoxDecoration(
                 color: AppColors.secondary.withOpacity(0.12),
                 borderRadius: BorderRadius.circular(10),
               ),
               child: const Icon(
                 Icons.calendar_month,
                 color: AppColors.secondary,
               ),
             ),
             title: Text(
               _proximosEventosMock[0]['titulo'],
               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: -0.1),
             ),
             subtitle: Text(
               '${_proximosEventosMock[0]['ubicacion']} • ${_proximosEventosMock[0]['fecha']}',
               style: const TextStyle(fontSize: 12, letterSpacing: -0.2),
             ),
           ),
         ],
       ),
     ),
   );
 }
}