import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/core/theme/app_colors.dart';
import 'package:ocupa2_app/services/employer_service.dart';
import 'package:ocupa2_app/services/offer_service.dart';

class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({super.key});

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  late final EmployerService _employerService;
  late final OfferService _offerService;

  final _formPayment = GlobalKey<FormState>();
  final _cardNumberCtrl = TextEditingController(text: '4242424242424242');
  final _cvvCtrl = TextEditingController(text: '123');
  final _expMonthCtrl = TextEditingController(text: '12');
  final _expYearCtrl = TextEditingController(text: '2030');
  final _cardholderCtrl = TextEditingController();
  String? _paymentId;
  bool _paying = false;

  File? _photoFile;
  String? _photoUrl;
  bool _uploading = false;

  final _formOffer = GlobalKey<FormState>();
  final _jobTypeKeyCtrl = TextEditingController(text: 'chofer');
  String _contractType = 'temporal';
  final _descriptionCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _amountCtrl = TextEditingController(text: '1500');
  final _currencyCtrl = TextEditingController(text: 'DOP');
  final _deadlineCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  bool _publishing = false;

  int _step = 0;

  @override
  void initState() {
    super.initState();
    _employerService = EmployerService(apiClient: ApiClient());
    _offerService = OfferService();
  }

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cvvCtrl.dispose();
    _expMonthCtrl.dispose();
    _expYearCtrl.dispose();
    _cardholderCtrl.dispose();
    _jobTypeKeyCtrl.dispose();
    _descriptionCtrl.dispose();
    _addressCtrl.dispose();
    _amountCtrl.dispose();
    _currencyCtrl.dispose();
    _deadlineCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar oferta')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: _next,
        onStepCancel: _previous,
        controlsBuilder: (context, details) => const SizedBox.shrink(),
        steps: [
          Step(
            title: const Text('1. Pago de la oferta'),
            subtitle: const Text('1 USD simulado'),
            isActive: _step >= 0,
            state: _paymentId != null ? StepState.complete : StepState.indexed,
            content: _buildPaymentForm(),
          ),
          Step(
            title: const Text('2. Foto de la oferta'),
            subtitle: const Text('Imagen obligatoria'),
            isActive: _step >= 1,
            state: _photoUrl != null ? StepState.complete : StepState.indexed,
            content: _buildPhotoStep(),
          ),
          Step(
            title: const Text('3. Datos de la oferta'),
            isActive: _step >= 2,
            state: StepState.indexed,
            content: _buildOfferForm(),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _canContinue() && !_publishing ? _next : null,
            child: _publishing
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_step == 2 ? 'Publicar oferta' : 'Continuar'),
          ),
        ),
      ),
    );
  }

  bool _canContinue() {
    if (_step == 0) return _paymentId != null;
    if (_step == 1) return _photoUrl != null;
    if (_step == 2) return true;
    return false;
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step += 1);
    } else {
      _publish();
    }
  }

  void _previous() {
    if (_step > 0) setState(() => _step -= 1);
  }

  Widget _buildPaymentForm() {
    return Form(
      key: _formPayment,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tarjeta aprobada: 4242 4242 4242 4242\n'
                    'Tarjeta rechazada: 4000 0000 0000 0002',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardNumberCtrl,
            decoration: const InputDecoration(
              labelText: 'Número de tarjeta *',
              prefixIcon: Icon(Icons.credit_card),
            ),
            keyboardType: TextInputType.number,
            validator: (v) =>
                (v == null || v.length < 13) ? 'Número inválido' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cvvCtrl,
                  decoration: const InputDecoration(labelText: 'CVV *'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.length < 3) ? 'CVV inválido' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _expMonthCtrl,
                  decoration: const InputDecoration(labelText: 'Mes *'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerido' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _expYearCtrl,
                  decoration: const InputDecoration(labelText: 'Año *'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerido' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cardholderCtrl,
            decoration: const InputDecoration(
              labelText: 'Titular (opcional)',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _paying ? null : _processPayment,
            icon: _paying
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.payment),
            label: Text(_paymentId != null ? 'Pago aprobado ✅' : 'Pagar 1 USD'),
          ),
          if (_paymentId != null) ...[
            const SizedBox(height: 8),
            Text('paymentId: $_paymentId',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_formPayment.currentState!.validate()) return;

    setState(() => _paying = true);

    try {
      final id = await _employerService.createPayment(
        cardNumber: _cardNumberCtrl.text.replaceAll(' ', ''),
        cvv: _cvvCtrl.text,
        expMonth: int.parse(_expMonthCtrl.text),
        expYear: int.parse(_expYearCtrl.text),
        cardholder: _cardholderCtrl.text,
      );

      if (!mounted) return;

      setState(() {
        _paymentId = id;
        _paying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pago aprobado ✅')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _paying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _buildPhotoStep() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickPhoto,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: _photoFile == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 48),
                        SizedBox(height: 8),
                        Text('Toca para seleccionar imagen'),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_photoFile!, fit: BoxFit.cover),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _photoFile == null || _uploading ? null : _uploadPhoto,
          icon: _uploading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_upload),
          label: Text(_photoUrl != null ? 'Foto subida ✅' : 'Subir foto'),
        ),
      ],
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() {
        _photoFile = File(file.path);
        _photoUrl = null;
      });
    }
  }

  Future<void> _uploadPhoto() async {
    setState(() => _uploading = true);

    try {
      final bytes = await _photoFile!.readAsBytes();
      final base64 = base64Encode(bytes);

      final url = await _employerService.uploadPhoto(base64);

      if (!mounted) return;

      setState(() {
        _photoUrl = url;
        _uploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto subida ✅')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _buildOfferForm() {
    return Form(
      key: _formOffer,
      child: Column(
        children: [
          TextFormField(
            controller: _jobTypeKeyCtrl,
            decoration: const InputDecoration(
              labelText: 'Tipo de trabajo (jobTypeKey) *',
              hintText: 'chofer, plomero, electricista...',
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _contractType,
            decoration: const InputDecoration(labelText: 'Tipo de contrato *'),
            items: const [
              DropdownMenuItem(value: 'temporal', child: Text('Temporal')),
              DropdownMenuItem(value: 'fijo', child: Text('Fijo')),
              DropdownMenuItem(value: 'horas', child: Text('Por horas')),
            ],
            onChanged: (v) => setState(() => _contractType = v ?? 'temporal'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Descripción *'),
            validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressCtrl,
            decoration: const InputDecoration(
              labelText: 'Dirección *',
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latCtrl,
                  decoration: const InputDecoration(labelText: 'Latitud'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _lngCtrl,
                  decoration: const InputDecoration(labelText: 'Longitud'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _amountCtrl,
                  decoration: const InputDecoration(labelText: 'Monto'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _currencyCtrl,
                  decoration: const InputDecoration(labelText: 'Moneda'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _deadlineCtrl,
            decoration: const InputDecoration(
              labelText: 'Fecha límite (YYYY-MM-DD)',
              prefixIcon: Icon(Icons.calendar_today),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _publish() async {
    if (!_formOffer.currentState!.validate()) return;
    if (_paymentId == null || _photoUrl == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa el pago y la foto primero')),
        );
      }
      return;
    }

    setState(() => _publishing = true);

    try {
      final lat = double.tryParse(_latCtrl.text) ?? 18.4861;
      final lng = double.tryParse(_lngCtrl.text) ?? -69.9312;

      await _offerService.createOffer(
        jobTypeKey: _jobTypeKeyCtrl.text,
        contractType: _contractType,
        description: _descriptionCtrl.text,
        address: _addressCtrl.text,
        lat: lat,
        lng: lng,
        amount: double.tryParse(_amountCtrl.text) ?? 1500,
        currency: _currencyCtrl.text.isEmpty ? 'DOP' : _currencyCtrl.text,
        paymentId: _paymentId,
        photo: _photoUrl,
        deadline: _deadlineCtrl.text.isEmpty
            ? null
            : DateTime.tryParse(_deadlineCtrl.text),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oferta publicada ✅')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }
}