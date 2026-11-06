// lib/features/adopcion/presentation/widgets/formulario_adopcion_modal.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/adopcion_model.dart';
import '../../data/adopcion_repository.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class FormularioAdopcionModal extends StatefulWidget {
  final AdopcionModel mascota;

  const FormularioAdopcionModal({
    super.key,
    required this.mascota,
  });

  @override
  State<FormularioAdopcionModal> createState() => _FormularioAdopcionModalState();
}

class _FormularioAdopcionModalState extends State<FormularioAdopcionModal> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Lista para manejar múltiples fotos
  final List<String> _fotosVivienda = [];
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Función para abrir la cámara y agregar a la lista
  Future<void> _tomarFoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera, // Puedes cambiar a .gallery si prefieres
      imageQuality: 70,
    );
    if (photo != null) {
      setState(() => _fotosVivienda.add(photo.path));
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_fotosVivienda.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor adjunta al menos una foto de la vivienda'),
              backgroundColor: Colors.orange),
        );
        return; // Obligamos al usuario a subir al menos una foto
      }

      setState(() => _isLoading = true);

      try {
        await AdopcionRepository.enviarSolicitudAdopcion(
          widget.mascota.id,
          widget.mascota.name,
          _phoneController.text.trim(),
          _emailController.text.trim(),
          _addressController.text.trim(),
          _fotosVivienda, // Pasamos la lista completa
        );

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud registrada correctamente.'),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hubo un error al enviar la solicitud.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: 24.0,
        left: 20.0,
        right: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Solicitud de Adopción - ${widget.mascota.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Completa tus datos de contacto para la evaluación preliminar.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Campo Celular
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _buildInputDecoration(
                  label: 'Número de Contacto (Celular)',
                  icon: Icons.phone_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa un número de celular.';
                  }
                  if (value.trim().length < 10) {
                    return 'Ingresa un número de celular válido (10 dígitos).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Campo Correo Electrónico
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration(
                  label: 'Correo Electrónico',
                  icon: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu correo electrónico.';
                  }
                  final bool emailValid = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  ).hasMatch(value.trim());
                  if (!emailValid) {
                    return 'Ingresa un correo electrónico válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Campo Dirección
              TextFormField(
                controller: _addressController,
                keyboardType: TextInputType.streetAddress,
                decoration: _buildInputDecoration(
                  label: 'Dirección de Residencia',
                  icon: Icons.home_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu dirección de residencia.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- SECCIÓN DE FOTOS (Cámara y Miniaturas) ---
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _tomarFoto,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 28),
                            SizedBox(height: 6),
                            Text(
                              'Tomar foto de vivienda',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Si hay fotos, mostramos la lista horizontal de miniaturas
              if (_fotosVivienda.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _fotosVivienda.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              image: DecorationImage(
                                image: FileImage(File(_fotosVivienda[index])),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -5,
                            right: -5,
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _fotosVivienda.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // --- ÚNICO BOTÓN DE ENVIAR ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          'Enviar Solicitud',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
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