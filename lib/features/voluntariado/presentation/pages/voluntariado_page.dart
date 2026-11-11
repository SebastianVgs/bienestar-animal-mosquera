import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/voluntariado_model.dart';
import '../../data/voluntariado_repository.dart';

class VoluntariadoPage extends StatefulWidget {
  const VoluntariadoPage({super.key});

  @override
  State<VoluntariadoPage> createState() => _VoluntariadoPageState();
}

class _VoluntariadoPageState extends State<VoluntariadoPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores principales
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  String? _tipoVivienda;
  bool _tieneMascotas = false;

  // NUEVOS Controladores condicionales
  final _cantidadMascotasController = TextEditingController();
  final _tipoMascotasController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _cantidadMascotasController.dispose();
    _tipoMascotasController.dispose();
    super.dispose();
  }

  Future<void> _enviarPostulacion() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final postulacion = VoluntariadoModel(
          nombreCompleto: _nombreController.text.trim(),
          telefono: _telefonoController.text.trim(),
          direccion: _direccionController.text.trim(),
          tipoVivienda: _tipoVivienda ?? 'No especificado',
          tieneMascotas: _tieneMascotas,
          // Guardamos los campos extra solo si el switch está encendido
          cantidadMascotas: _tieneMascotas ? int.tryParse(_cantidadMascotasController.text) : null,
          tipoMascotas: _tieneMascotas ? _tipoMascotasController.text.trim() : null,
        );

        await VoluntariadoRepository.enviarPostulacion(postulacion);

        if (mounted) {
          _mostrarDialogoExito();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al enviar la postulación. Intenta nuevamente.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _mostrarDialogoExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¡Postulación Enviada!', textAlign: TextAlign.center),
        content: const Text(
          'Gracias por postularte como hogar de paso. La Secretaría de Bienestar Animal revisará tu solicitud y se pondrá en contacto contigo pronto.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Entendido', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildHeader(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.home_work_rounded, color: AppColors.secondary, size: 40),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Actualmente nuestro refugio municipal se encuentra en su capacidad máxima. ¡Postúlate como hogar de paso y salva una vida!',
                                style: TextStyle(color: Colors.grey[800], fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text('Datos del Voluntario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre Completo',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.isEmpty ? 'Por favor ingresa tu nombre' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _telefonoController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Teléfono de Contacto',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.isEmpty ? 'Por favor ingresa tu teléfono' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _direccionController,
                        decoration: InputDecoration(
                          labelText: 'Dirección de Residencia',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.isEmpty ? 'Por favor ingresa tu dirección' : null,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Tipo de Vivienda',
                          prefixIcon: const Icon(Icons.house),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ['Casa propia', 'Casa en arriendo', 'Apartamento', 'Finca/Lote']
                            .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                            .toList(),
                        onChanged: (value) => setState(() => _tipoVivienda = value),
                        validator: (value) => value == null ? 'Selecciona el tipo de vivienda' : null,
                      ),
                      const SizedBox(height: 16),

                      SwitchListTile(
                        title: const Text('¿Tienes otras mascotas actualmente?'),
                        value: _tieneMascotas,
                        activeColor: AppColors.primary,
                        onChanged: (bool value) {
                          setState(() {
                            _tieneMascotas = value;
                            // Si lo apaga, limpiamos los campos extra
                            if (!value) {
                              _cantidadMascotasController.clear();
                              _tipoMascotasController.clear();
                            }
                          });
                        },
                      ),
                      
                      // NUEVO: CAMPOS CONDICIONALES
                      // Usamos AnimatedSize para que la expansión sea suave
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        child: _tieneMascotas
                            ? Column(
                                children: [
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _cantidadMascotasController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: '¿Cuántas mascotas tienes?',
                                      prefixIcon: const Icon(Icons.numbers),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    validator: (value) {
                                      if (_tieneMascotas && (value == null || value.isEmpty)) {
                                        return 'Por favor indica la cantidad';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _tipoMascotasController,
                                    decoration: InputDecoration(
                                      labelText: '¿Qué tipo? (Ej. 2 perros, 1 gato)',
                                      prefixIcon: const Icon(Icons.pets),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    validator: (value) {
                                      if (_tieneMascotas && (value == null || value.isEmpty)) {
                                        return 'Por favor indica el tipo de mascotas';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isLoading ? null : _enviarPostulacion,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Enviar Postulación',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
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
            'HOGARES DE PASO',
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
}