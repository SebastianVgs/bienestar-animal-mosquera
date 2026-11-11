// lib/features/reportes/presentation/pages/reportes_page.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:bienestar_animal_app/features/reportes/models/reporte_model.dart';
import 'package:bienestar_animal_app/features/reportes/data/reporte_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'detalle_reporte_page.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  int _selectedTabIndex = 0; // 0: Formulario, 1: Historial

  // Clave del formulario y controladores
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isSubmitting = false;
  bool _useGpsLocation = false;
  double? _currentLat;
  double? _currentLng;

  // Lista simulada de archivos adjuntos localmente
  final List<String> _attachedImages = [];

  late Future<List<ReporteModel>> _misReportesFuture;

  @override
  void initState() {
    super.initState();
    _loadMisReportes();
  }

  void _loadMisReportes() {
    _misReportesFuture = ReporteRepository.getMisReportes();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Implementación de captura de GPS
  Future<void> _toggleGps() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Revisar si el GPS del celular está encendido
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, enciende el GPS del celular.')),
      );
      return;
    }

    // 2. Pedir permisos al usuario
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return; // El usuario dijo que no
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return; // Permisos denegados permanentemente
    }

    // 3. ¡Capturar la ubicación real!
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLat = position.latitude;
      _currentLng = position.longitude;
      _useGpsLocation = true; 
    });
  }

  // Implementación de adjunto de fotografía
  // 1. Mostrar menú de opciones (Cámara o Galería)
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera, color: AppColors.primary),
                title: const Text('Tomar foto con la cámara'),
                onTap: () {
                  Navigator.of(context).pop(); // Cierra el menú
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Elegir de la galería'),
                onTap: () {
                  Navigator.of(context).pop(); // Cierra el menú
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. Capturar la imagen según la opción elegida
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    
    final XFile? photo = await picker.pickImage(
      source: source,
      imageQuality: 70, // Mantenemos la compresión para optimizar Supabase
    );

    if (photo != null) {
      setState(() {
        _attachedImages.add(photo.path);
      });
    }
  }

  void _removeEvidence(int index) {
    setState(() {
      _attachedImages.removeAt(index);
    });
  }

  // Envío del reporte con validación estricta y debounce
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_attachedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe adjuntar al menos una fotografía como evidencia.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // --- NUEVA LÓGICA PARA LA DIRECCIÓN ---
      String direccionFinal = _addressController.text.trim();
      
      // Si el usuario usó GPS y la dirección está vacía, creamos un string con las coordenadas
      if (_useGpsLocation && direccionFinal.isEmpty && _currentLat != null && _currentLng != null) {
        // Formateamos las coordenadas a 5 decimales para mayor legibilidad
        direccionFinal = 'Ubicación GPS: ${_currentLat!.toStringAsFixed(5)}, ${_currentLng!.toStringAsFixed(5)}';
      } else if (direccionFinal.isEmpty) {
         // Por si acaso se cuela una validación, le damos un valor por defecto
         direccionFinal = 'Ubicación no proporcionada';
      }
      // --------------------------------------

      await ReporteRepository.crearReporte(
        description: _descriptionController.text.trim(),
        address: direccionFinal, 
        telefono: _phoneController.text.trim(), // <--- AÑADE ESTO
        latitude: _currentLat,
        longitude: _currentLng,
        localEvidencePaths: _attachedImages,
      );

      if (!mounted) return;

      // Limpieza de formulario
      _descriptionController.clear();
      _phoneController.clear();
      _addressController.clear();
      setState(() {
        _attachedImages.clear();
        _useGpsLocation = false;
        _currentLat = null; // Es buena práctica limpiar también las coordenadas
        _currentLng = null;
        _selectedTabIndex = 1; // Cambiar a la vista de historial
      });

      _loadMisReportes(); // Recargar historial

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte radicado con éxito. La Secretaría analizará el caso.'),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar el reporte. Intente nuevamente.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column( // QUITA el SingleChildScrollView de aquí arriba
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildHeader(context),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildTabSelector(),
            ),
            const SizedBox(height: 16),
            // AQUÍ ESTÁ EL TRUCO: Expanded le da a la pestaña el espacio restante
            Expanded(
              child: _selectedTabIndex == 0
                  ? SingleChildScrollView( // El scroll lo pasamos SOLO al formulario
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildFormSection(),
                    )
                  : _buildMisReportesTab(), // La lista manejará su propio scroll internamente
            ),
          ],
        ),
      ),
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
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Expanded(
            child: Text(
              'REPORTES DE MALTRATO',
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
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedTabIndex == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  'Radicar Denuncia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _selectedTabIndex == 0 ? AppColors.textPrimary : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedTabIndex == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  'Mis Reportes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _selectedTabIndex == 1 ? AppColors.textPrimary : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
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
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del Incidente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Describa de manera detallada los hechos presenciados para la evaluación del caso.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 18),

            // Campo 1: Descripción
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 500,
              keyboardType: TextInputType.multiline,
              decoration: _buildInputDecoration(
                label: 'Descripción de los hechos',
                icon: Icons.description_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Debe ingresar la descripción del incidente.';
                }
                if (value.trim().length < 15) {
                  return 'La descripción debe tener al menos 15 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Campo 2: Teléfono
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _buildInputDecoration(
                label: 'Teléfono de contacto',
                icon: Icons.phone_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingrese un número de contacto.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Campo 3: Ubicación / Dirección
            TextFormField(
              controller: _addressController,
              readOnly: _useGpsLocation,
              decoration: _buildInputDecoration(
                label: 'Dirección o punto de referencia',
                icon: Icons.location_on_outlined,
              ),
              validator: (value) {
              if (_useGpsLocation) {
                return null; 
              }

              if (value == null || value.trim().isEmpty) {
                return 'Debe indicar la ubicación exacta o usar GPS.';
              }
              return null;
            },
            ),
            const SizedBox(height: 8),

            // Selector GPS
            Row(
              children: [
                Checkbox(
                value: _useGpsLocation,
                activeColor: AppColors.primary,
                onChanged: (bool? value) {
                  if (value == true) {
                    _toggleGps(); // Si marca la casilla, prendemos GPS
                  } else {
                    setState(() {
                      _useGpsLocation = false; // Si la desmarca, lo apagamos
                      _currentLat = null;
                      _currentLng = null;
                    });
                  }
                },
              ),
                const Expanded(
                  child: Text(
                    'Usar ubicación GPS actual',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Campo 3: Adjunto de Fotografías
            const Text(
              'Evidencia Fotográfica',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),

            // Galería preview
            if (_attachedImages.isNotEmpty)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(_attachedImages.length, (index) {
                  return Stack(
                    children: [
                      ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_attachedImages[index]), // Llama al archivo real de la memoria
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover, // Para que la foto se recorte cuadradita perfecta
                      ),
                    ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _removeEvidence(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            if (_attachedImages.isNotEmpty) const SizedBox(height: 12),

            // Botón de adjuntar
            InkWell(
              onTap: () => _showImageSourceActionSheet(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Adjuntar Fotografía de Evidencia',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón Emitir Reporte
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitReport,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Emitir Reporte Ciudadano',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMisReportesTab() {
    return FutureBuilder<List<ReporteModel>>(
      future: _misReportesFuture, // ¡USAR LA VARIABLE!
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error cargando datos: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No registra reportes radicados previamente.'),
          );
        }

        final reportes = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reportes.length,
          itemBuilder: (context, index) {
            final reporte = reportes[index];
            
            // Verificación segura de la URL
            final bool hasUrl = reporte.evidenciaUrl != null && 
                              reporte.evidenciaUrl!.isNotEmpty &&
                              reporte.evidenciaUrl!.startsWith('http');

            return Card(
            margin: const EdgeInsets.only(bottom: 12),
            clipBehavior: Clip.antiAlias, // Esto asegura que el efecto de clic no se salga de los bordes curvos
            child: InkWell(
              onTap: () {
                // Navegación a la página de detalles
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleReportePage(reporte: reporte),
                  ),
                );
              },
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: hasUrl
                      ? Image.network(
                          reporte.evidenciaUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, size: 30, color: Colors.grey),
                            );
                          },
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
                        ),
                ),
                title: Text(reporte.descripcion, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('Estado: ${reporte.estado}'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey), // Flecha indicadora de navegación
              ),
            ),
          );
          },
        );
      },
    );
  }

  Widget _buildUrgencyBadge(String level) {
    Color color;
    String text;

    switch (level) {
      case 'ALTA':
        color = Colors.redAccent;
        text = 'Prioridad Alta';
        break;
      case 'MEDIA':
        color = Colors.orangeAccent;
        text = 'Prioridad Media';
        break;
      case 'BAJA':
        color = Colors.blueAccent;
        text = 'Prioridad Baja';
        break;
      default:
        color = Colors.grey;
        text = 'En Evaluación';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}