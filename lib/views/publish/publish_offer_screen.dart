import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:ocupa2_app/models/create_offer_request.dart';
import 'package:ocupa2_app/models/job_type.dart';
import 'package:ocupa2_app/services/payment_service.dart';
import 'package:ocupa2_app/services/publish_service.dart';

class PublishOfferScreen extends StatefulWidget {
  final PublishService publishService;
  final PaymentService paymentService;

  const PublishOfferScreen({
    super.key,
    required this.publishService,
    required this.paymentService,
  });

  @override
  State<PublishOfferScreen> createState() =>
      _PublishOfferScreenState();
}

class _PublishOfferScreenState
    extends State<PublishOfferScreen> {
  final _formKey = GlobalKey<FormState>();

  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _payController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  final Map<String, TextEditingController>
      _dynamicTextControllers = {};

  final Map<String, DateTime?>
      _dynamicDateValues = {};

  final Map<String, String?>
      _dynamicSelectValues = {};

  final Map<String, bool>
      _dynamicCheckValues = {};

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

    for (final controller
        in _dynamicTextControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // CARGAR TIPOS DE EMPLEO
  // ============================================================

  Future<void> _loadJobTypes() async {
    try {
      final types =
          await widget.publishService.getJobTypes();

      if (!mounted) return;

      setState(() {
        _jobTypes = types;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showError(
        'No se pudieron cargar los tipos de empleo',
      );
    }
  }

  // ============================================================
  // CAMBIAR TIPO DE EMPLEO
  // ============================================================

  void _onJobTypeChanged(JobType? type) {
    for (final controller
        in _dynamicTextControllers.values) {
      controller.dispose();
    }

    setState(() {
      _selectedType = type;

      _dynamicTextControllers.clear();
      _dynamicDateValues.clear();
      _dynamicSelectValues.clear();
      _dynamicCheckValues.clear();

      if (type != null) {
        for (final field
            in type.customFields) {
          switch (field.type) {
            case 'text':
              _dynamicTextControllers[field.key] =
                  TextEditingController();
              break;

            case 'date':
              _dynamicDateValues[field.key] =
                  null;
              break;

            case 'select':
              _dynamicSelectValues[field.key] =
                  null;
              break;

            case 'check':
              _dynamicCheckValues[field.key] =
                  false;
              break;
          }
        }
      }
    });
  }

  // ============================================================
  // FECHA LÍMITE
  // ============================================================

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().add(
        const Duration(days: 7),
      ),
      firstDate: DateTime.now(),
      lastDate:
          DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  // ============================================================
  // FECHAS DINÁMICAS
  // ============================================================

  Future<void> _pickDynamicDate(
    String key,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate:
          DateTime.now().subtract(
        const Duration(days: 365),
      ),
      lastDate:
          DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (picked != null) {
      setState(() {
        _dynamicDateValues[key] =
            picked;
      });
    }
  }

  // ============================================================
  // SELECCIONAR FOTO
  // ============================================================

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();

    final picked =
        await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        _photoFile =
            File(picked.path);
      });
    }
  }

  // ============================================================
  // CAMPOS DINÁMICOS
  // ============================================================

  Map<String, dynamic>
      _collectDynamicAnswers() {
    final answers =
        <String, dynamic>{};

    _dynamicTextControllers
        .forEach(
      (key, controller) {
        answers[key] =
            controller.text;
      },
    );

    _dynamicDateValues
        .forEach(
      (key, date) {
        if (date != null) {
          answers[key] =
              date.toIso8601String();
        }
      },
    );

    _dynamicSelectValues
        .forEach(
      (key, value) {
        if (value != null) {
          answers[key] = value;
        }
      },
    );

    _dynamicCheckValues
        .forEach(
      (key, value) {
        answers[key] = value;
      },
    );

    return answers;
  }

  // ============================================================
  // PUBLICAR OFERTA
  // ============================================================

  Future<void> _submit() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_selectedType == null) {
      _showError(
        'Selecciona un tipo de empleo',
      );
      return;
    }

    if (_photoFile == null) {
      _showError(
        'La foto del empleo es obligatoria',
      );
      return;
    }

    if (_deadline == null) {
      _showError(
        'Selecciona la fecha límite para aplicar',
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      // --------------------------------------------------------
      // 1. Convertir imagen a Base64
      // --------------------------------------------------------

      final bytes =
          await _photoFile!.readAsBytes();

      final base64Image =
          base64Encode(bytes);

      // --------------------------------------------------------
      // 2. Subir imagen
      // --------------------------------------------------------

      final photoUrl =
          await widget.publishService
              .uploadImage(
        base64Image,
      );

      // --------------------------------------------------------
      // 3. Recoger campos dinámicos
      // --------------------------------------------------------

      final dynamicAnswers =
          _collectDynamicAnswers();

      debugPrint(
        'Respuestas dinámicas: '
        '$dynamicAnswers',
      );

      // --------------------------------------------------------
      // 4. Crear CreateOfferRequest
      // --------------------------------------------------------

      final offer =
          CreateOfferRequest(
        jobTypeId:
            _selectedType!.id,

        contractType:
            _contractType,

        latitude:
            double.tryParse(
                  _latController.text
                      .replaceAll(
                    ',',
                    '.',
                  ),
                ) ??
                0,

        longitude:
            double.tryParse(
                  _lngController.text
                      .replaceAll(
                    ',',
                    '.',
                  ),
                ) ??
                0,

        address:
            _addressController.text
                .trim(),

        pay:
            double.tryParse(
                  _payController.text
                      .replaceAll(
                    ',',
                    '.',
                  ),
                ) ??
                0,

        description:
            _descriptionController
                .text
                .trim(),

        photoUrl:
            photoUrl,

        deadline:
            _deadline!,
      );

      // --------------------------------------------------------
      // 5. Publicar
      // --------------------------------------------------------

      await widget.publishService
          .publishOffer(offer);

      if (!mounted) return;

      // --------------------------------------------------------
      // 6. Confirmación
      // --------------------------------------------------------

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Oferta publicada correctamente',
          ),
        ),
      );

      Navigator.pop(
        context,
        offer,
      );
    } catch (e) {
      if (!mounted) return;

      _showError(
        'No se pudo publicar la oferta: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Publicar oferta',
        ),
      ),
      body: _submitting
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                children: [

                  // ==================================================
                  // TIPO DE EMPLEO
                  // ==================================================

                  DropdownButtonFormField<
                      JobType>(
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Tipo de empleo',
                    ),
                    items: _jobTypes
                        .map(
                          (type) =>
                              DropdownMenuItem<
                                  JobType>(
                            value: type,
                            child:
                                Text(
                              type.name,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged:
                        _onJobTypeChanged,
                    validator:
                        (value) {
                      if (value ==
                          null) {
                        return 'Selecciona un tipo';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // CONTRATO
                  // ==================================================

                  DropdownButtonFormField<
                      String>(
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Tipo de contrato',
                    ),
                    initialValue:
                        _contractType,
                    items: const [
                      DropdownMenuItem(
                        value:
                            'temporal',
                        child:
                            Text(
                          'Temporal',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'fijo',
                        child:
                            Text(
                          'Fijo',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            'por_horas',
                        child:
                            Text(
                          'Por horas',
                        ),
                      ),
                    ],
                    onChanged:
                        (value) {
                      if (value !=
                          null) {
                        setState(() {
                          _contractType =
                              value;
                        });
                      }
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // DIRECCIÓN
                  // ==================================================

                  TextFormField(
                    controller:
                        _addressController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Dirección',
                    ),
                    validator:
                        (value) {
                      if (value ==
                              null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Ingresa la dirección';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // LATITUD Y LONGITUD
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child:
                            TextFormField(
                          controller:
                              _latController,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal:
                                true,
                          ),
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Latitud',
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Requerido';
                            }

                            return null;
                          },
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child:
                            TextFormField(
                          controller:
                              _lngController,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal:
                                true,
                          ),
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Longitud',
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Requerido';
                            }

                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // PAGO
                  // ==================================================

                  TextFormField(
                    controller:
                        _payController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Pago ofrecido',
                      prefixText:
                          'RD\$ ',
                    ),
                    validator:
                        (value) {
                      if (value ==
                              null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Ingresa el pago';
                      }

                      final pay =
                          double.tryParse(
                        value.replaceAll(
                          ',',
                          '.',
                        ),
                      );

                      if (pay == null ||
                          pay <= 0) {
                        return 'Ingresa un pago válido';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // DESCRIPCIÓN
                  // ==================================================

                  TextFormField(
                    controller:
                        _descriptionController,
                    maxLines: 4,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Descripción del trabajo',
                    ),
                    validator:
                        (value) {
                      if (value ==
                              null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Ingresa una descripción';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // FECHA LÍMITE
                  // ==================================================

                  ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    title: Text(
                      _deadline == null
                          ? 'Fecha límite para aplicar'
                          : 'Fecha límite: '
                              '${DateFormat(
                            'dd/MM/yyyy',
                          ).format(
                            _deadline!,
                          )}',
                    ),
                    trailing:
                        const Icon(
                      Icons.calendar_today,
                    ),
                    onTap:
                        _pickDeadline,
                  ),

                  const Divider(),

                  // ==================================================
                  // CAMPOS DINÁMICOS
                  // ==================================================

                  if (_selectedType !=
                          null &&
                      _selectedType!
                          .customFields
                          .isNotEmpty) ...[
                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Detalles adicionales de '
                      '${_selectedType!.name}',
                      style:
                          Theme.of(
                        context,
                      )
                              .textTheme
                              .titleMedium,
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    ..._selectedType!
                        .customFields
                        .map(
                          _buildDynamicField,
                        ),
                  ],

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // FOTO
                  // ==================================================

                  Text(
                    'Foto del empleo *',
                    style:
                        Theme.of(
                      context,
                    )
                            .textTheme
                            .titleMedium,
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  if (_photoFile !=
                      null)
                    ClipRRect(
                      borderRadius:
                          BorderRadius
                              .circular(
                        8,
                      ),
                      child:
                          Image.file(
                        _photoFile!,
                        height: 180,
                        width:
                            double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                  const SizedBox(
                    height: 8,
                  ),

                  OutlinedButton
                      .icon(
                    onPressed:
                        _pickPhoto,
                    icon:
                        const Icon(
                      Icons
                          .photo_camera,
                    ),
                    label: Text(
                      _photoFile ==
                              null
                          ? 'Seleccionar foto'
                          : 'Cambiar foto',
                    ),
                  ),

                  const SizedBox(
                    height: 32,
                  ),

                  // ==================================================
                  // PUBLICAR
                  // ==================================================

                  ElevatedButton(
                    onPressed:
                        _submit,
                    child:
                        const Text(
                      'Publicar oferta',
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // CAMPOS DINÁMICOS
  // ============================================================

  Widget _buildDynamicField(
    JobTypeField field,
  ) {
    switch (field.type) {

      case 'text':
        return Padding(
          padding:
              const EdgeInsets.only(
            bottom: 16,
          ),
          child:
              TextFormField(
            controller:
                _dynamicTextControllers[
                    field.key],
            decoration:
                InputDecoration(
              labelText:
                  field.label,
            ),
          ),
        );

      case 'date':
        final selectedDate =
            _dynamicDateValues[
                field.key];

        return Padding(
          padding:
              const EdgeInsets.only(
            bottom: 16,
          ),
          child: ListTile(
            contentPadding:
                EdgeInsets.zero,
            title: Text(
              selectedDate == null
                  ? field.label
                  : '${field.label}: '
                      '${DateFormat(
                    'dd/MM/yyyy',
                  ).format(
                    selectedDate,
                  )}',
            ),
            trailing:
                const Icon(
              Icons.calendar_today,
            ),
            onTap: () =>
                _pickDynamicDate(
              field.key,
            ),
          ),
        );

      case 'select':
        return Padding(
          padding:
              const EdgeInsets.only(
            bottom: 16,
          ),
          child:
              DropdownButtonFormField<
                  String>(
            decoration:
                InputDecoration(
              labelText:
                  field.label,
            ),
            initialValue:
                _dynamicSelectValues[
                    field.key],
            items:
                (field.options ??
                        [])
                    .map(
                      (option) =>
                          DropdownMenuItem<
                              String>(
                        value:
                            option,
                        child:
                            Text(
                          option,
                        ),
                      ),
                    )
                    .toList(),
            onChanged:
                (value) {
              setState(() {
                _dynamicSelectValues[
                        field.key] =
                    value;
              });
            },
          ),
        );

      case 'check':
        return Padding(
          padding:
              const EdgeInsets.only(
            bottom: 8,
          ),
          child:
              CheckboxListTile(
            contentPadding:
                EdgeInsets.zero,
            title:
                Text(field.label),
            value:
                _dynamicCheckValues[
                        field.key] ??
                    false,
            onChanged:
                (value) {
              setState(() {
                _dynamicCheckValues[
                        field.key] =
                    value ?? false;
              });
            },
          ),
        );

      default:
        return const SizedBox
            .shrink();
    }
  }
}