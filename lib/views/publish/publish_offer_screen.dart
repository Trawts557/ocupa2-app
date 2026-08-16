import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ocupa2_app/models/job_type.dart';
import 'package:ocupa2_app/models/offer.dart';
import 'package:ocupa2_app/models/payment.dart';
import 'package:ocupa2_app/services/publish_service.dart';
import 'package:ocupa2_app/services/payment_service.dart';
import 'package:ocupa2_app/views/payments/card_payment_screen.dart';

class PublishOfferScreen extends StatefulWidget {
  final PublishService publishService;
  final PaymentService paymentService;

  const PublishOfferScreen({
    super.key,
    required this.publishService,
    required this.paymentService,
  });

  @override
  State<PublishOfferScreen> createState() => _PublishOfferScreenState();
}

class _PublishOfferScreenState extends State<PublishOfferScreen> {
  final _formKey = GlobalKey<FormState>();

  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _payController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  final Map<String, TextEditingController> _dynamicTextControllers = {};
  final Map<String, DateTime?> _dynamicDateValues = {};
  final Map<String, String?> _dynamicSelectValues = {};
  final Map<String, bool> _dynamicCheckValues = {};

  List<JobType> _jobTypes = [];
  JobType? _selectedType;
  String _contractType = 'temporal';
  DateTime? _deadline;
  File? _photoFile;

  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadJobTypes();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    _payController.dispose();
    _latController.dispose();
    _lngController.dispose();
    for (final c in _dynamicTextControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadJobTypes() async {
    try {
      final types = await widget.publishService.getJobTypes();
      setState(() {
        _jobTypes = types;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showError('No se pudieron cargar los tipos de empleo');
    }
  }

  void _onJobTypeChanged(JobType? type) {
    setState(() {
      _selectedType = type;
      _dynamicTextControllers.clear();
      _dynamicDateValues.clear();
      _dynamicSelectValues.clear();
      _dynamicCheckValues.clear();

      if (type != null) {
        for (final field in type.customFields) {
          switch (field.type) {
            case 'text':
              _dynamicTextControllers[field.key] = TextEditingController();
              break;
            case 'date':
              _dynamicDateValues[field.key] = null;
              break;
            case 'select':
              _dynamicSelectValues[field.key] = null;
              break;
            case 'check':
              _dynamicCheckValues[field.key] = false;
              break;
          }
        }
      }
    });
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _pickDynamicDate(String key) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dynamicDateValues[key] = picked);
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _photoFile = File(picked.path));
    }
  }

  Map<String, dynamic> _collectDynamicAnswers() {
    final answers = <String, dynamic>{};
    _dynamicTextControllers.forEach((key, controller) {
      answers[key] = controller.text;
    });
    _dynamicDateValues.forEach((key, date) {
      if (date != null) answers[key] = date.toIso8601String();
    });
    _dynamicSelectValues.forEach((key, value) {
      if (value != null) answers[key] = value;
    });
    _dynamicCheckValues.forEach((key, value) {
      answers[key] = value;
    });
    return answers;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == null) {
      _showError('Selecciona un tipo de empleo');
      return;
    }
    if (_photoFile == null) {
      _showError('La foto del empleo es obligatoria');
      return;
    }
    if (_deadline == null) {
      _showError('Selecciona la fecha límite para aplicar');
      return;
    }

    setState(() => _submitting = true);
    try {
      final bytes = await _photoFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final photoUrl = await widget.publishService.uploadImage(base64Image);

      final draftOffer = Offer(
        id: '',
        jobTypeId: _selectedType!.id,
        contractType: _contractType,
        latitude: double.tryParse(_latController.text) ?? 0,
        longitude: double.tryParse(_lngController.text) ?? 0,
        address: _addressController.text,
        pay: double.tryParse(_payController.text) ?? 0,
        description: _descriptionController.text,
        photoUrl: photoUrl,
        deadline: _deadline!,
        active: true,
      );

      // TODO: incluir _collectDynamicAnswers() en el body si Swagger lo requiere

      final published = await widget.publishService.publishOffer(draftOffer);

      if (!mounted) return;

      final payment = await Navigator.push<Payment>(
        context,
        MaterialPageRoute(
          builder: (_) => CardPaymentScreen(
            paymentService: widget.paymentService,
            offerId: published.id,
          ),
        ),
      );

      if (payment != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oferta publicada y pago confirmado')),
        );
        Navigator.pop(context, published);
      }
    } catch (e) {
      _showError('No se pudo publicar la oferta: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Publicar oferta')),
      body: _submitting
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<JobType>(
                    decoration: const InputDecoration(labelText: 'Tipo de empleo'),
                    items: _jobTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                        .toList(),
                    onChanged: _onJobTypeChanged,
                    validator: (v) => v == null ? 'Selecciona un tipo' : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Tipo de contrato'),
                    value: _contractType,
                    items: const [
                      DropdownMenuItem(value: 'temporal', child: Text('Temporal')),
                      DropdownMenuItem(value: 'fijo', child: Text('Fijo')),
                      DropdownMenuItem(value: 'por_horas', child: Text('Por horas')),
                    ],
                    onChanged: (v) => setState(() => _contractType = v!),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Dirección'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Ingresa la dirección' : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Latitud'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lngController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Longitud'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _payController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Pago ofrecido'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Ingresa el pago' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Descripción del trabajo'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Ingresa una descripción' : null,
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _deadline == null
                          ? 'Fecha límite para aplicar'
                          : 'Fecha límite: ${DateFormat('dd/MM/yyyy').format(_deadline!)}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickDeadline,
                  ),
                  const Divider(),

                  if (_selectedType != null && _selectedType!.customFields.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Detalles adicionales de ${_selectedType!.name}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._selectedType!.customFields.map(_buildDynamicField),
                  ],

                  const SizedBox(height: 16),

                  Text('Foto del empleo *', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_photoFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_photoFile!, height: 180, fit: BoxFit.cover),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.photo_camera),
                    label: Text(_photoFile == null ? 'Seleccionar foto' : 'Cambiar foto'),
                  ),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Publicar y pagar 1 USD'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildDynamicField(JobTypeField field) {
    switch (field.type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            controller: _dynamicTextControllers[field.key],
            decoration: InputDecoration(labelText: field.label),
          ),
        );

      case 'date':
        final value = _dynamicDateValues[field.key];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              value == null
                  ? field.label
                  : '${field.label}: ${DateFormat('dd/MM/yyyy').format(value)}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _pickDynamicDate(field.key),
          ),
        );

      case 'select':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: field.label),
            value: _dynamicSelectValues[field.key],
            items: (field.options ?? [])
                .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                .toList(),
            onChanged: (v) => setState(() => _dynamicSelectValues[field.key] = v),
          ),
        );

      case 'check':
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(field.label),
            value: _dynamicCheckValues[field.key] ?? false,
            onChanged: (v) =>
                setState(() => _dynamicCheckValues[field.key] = v ?? false),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}