// lib/features/censo/presentation/pages/censo_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:bienestar_animal_app/features/censo/models/censo_model.dart';
import 'package:bienestar_animal_app/features/censo/data/censo_repository.dart';
import 'detalle_censo_page.dart';

class CensoPage extends StatefulWidget {
  const CensoPage({super.key});

  @override
  State<CensoPage> createState() => _CensoPageState();
}

class _CensoPageState extends State<CensoPage> {
  int _selectedTabIndex = 0; // 0: Censar Mascota, 1: Mis Mascotas

  final _formKey = GlobalKey<FormState>();
  String _especie = 'Perro';
  String _sexo = 'Macho';
  String _unidadEdad = 'Años';

  final _nombreMascotaController = TextEditingController();
  final _razaController = TextEditingController();
  final _edadController = TextEditingController();
  final _nombrePropietarioController = TextEditingController();
  final _documentoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();

  bool _isSubmitting = false;
  late Future<List<CensoModel>> _misMascotasFuture;

  @override
  void initState() {
    super.initState();
    _loadMisMascotas();
  }

  void _loadMisMascotas() {
    _misMascotasFuture = CensoRepository.obtenerMascotasCensadas();
  }

  @override
  void dispose() {
    _nombreMascotaController.dispose();
    _razaController.dispose();
    _edadController.dispose();
    _nombrePropietarioController.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _submitCenso() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final censo = CensoModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        especie: _especie,
        nombreMascota: _nombreMascotaController.text.trim(),
        raza: _razaController.text.trim(),
        edad: int.parse(_edadController.text.trim()),
        unidadEdad: _unidadEdad,
        sexo: _sexo,
        nombrePropietario: _nombrePropietarioController.text.trim(),
        documentoPropietario: _documentoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        direccion: _direccionController.text.trim(),
        fechaRegistro: DateTime.now(),
      );

      await CensoRepository.registrarMascota(censo);

      if (!mounted) return;

      // Limpieza de campos
      _nombreMascotaController.clear();
      _razaController.clear();
      _edadController.clear();
      _nombrePropietarioController.clear();
      _documentoController.clear();
      _telefonoController.clear();
      _direccionController.clear();

      setState(() {
        _especie = 'Perro';
        _sexo = 'Macho';
        _unidadEdad = 'Años';
        _selectedTabIndex = 1; // Cambiar automáticamente a la pestaña Mis Mascotas
        _loadMisMascotas();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mascota registrada en el censo municipal con éxito.'),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al procesar el registro.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildTabSelector(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedTabIndex == 0
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Registre su mascota para acceder a los beneficios y jornadas de salud animal de la Alcaldía.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          _buildFormSection(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    )
                  : _buildMisMascotasTab(),
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
              'CENSO DE MASCOTAS',
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
                  'Censar Mascota',
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
                  'Mis Mascotas',
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

  Widget _buildMisMascotasTab() {
    return FutureBuilder<List<CensoModel>>(
      future: _misMascotasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error cargando datos: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No registra mascotas censadas previamente.'),
          );
        }

        final mascotas = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: mascotas.length,
          itemBuilder: (context, index) {
            final mascota = mascotas[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: InkWell(
                onTap: () async {
                  final actualizado = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleCensoPage(mascota: mascota),
                    ),
                  );

                  if (actualizado == true) {
                    setState(() {
                      _loadMisMascotas();
                    });
                  }
                },
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    mascota.nombreMascota,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${mascota.especie} • ${mascota.raza} • ${mascota.edad} ${mascota.unidadEdad}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
                ),
              ),
            );
          },
        );
      },
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
              'Datos de la Mascota',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _especie,
                    decoration: _inputDecoration('Especie', Icons.pets),
                    items: ['Perro', 'Gato']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _especie = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sexo,
                    decoration: _inputDecoration('Sexo', Icons.transgender),
                    items: ['Macho', 'Hembra']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _sexo = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreMascotaController,
              decoration: _inputDecoration('Nombre de la mascota', Icons.badge_outlined),
              validator: (v) => v!.trim().isEmpty ? 'Ingrese el nombre' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _razaController,
              decoration: _inputDecoration('Raza (o Criollo)', Icons.category_outlined),
              validator: (v) => v!.trim().isEmpty ? 'Ingrese la raza' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _edadController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _inputDecoration('Edad', Icons.cake_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Ingrese edad';
                      final numEdad = int.tryParse(v.trim());
                      if (numEdad == null || numEdad <= 0) return 'Edad inválida';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _unidadEdad,
                    decoration: _inputDecoration('Unidad', Icons.schedule_outlined),
                    items: ['Años', 'Meses']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (val) => setState(() => _unidadEdad = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Datos del Propietario',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombrePropietarioController,
              decoration: _inputDecoration('Nombre completo', Icons.person_outline),
              validator: (v) => v!.trim().isEmpty ? 'Ingrese su nombre' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _documentoController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration('Número de Documento', Icons.credit_card),
              validator: (v) => v!.trim().isEmpty ? 'Ingrese su documento' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration('Número de Celular', Icons.phone_android),
              validator: (v) => v!.trim().length < 10 ? 'Mínimo 10 dígitos' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _direccionController,
              decoration: _inputDecoration('Dirección (Mosquera)', Icons.home_outlined),
              validator: (v) => v!.trim().isEmpty ? 'Ingrese su dirección' : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isSubmitting ? null : _submitCenso,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Registrar en Censo Municipal',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}