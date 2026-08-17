import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/offer.dart';
import '../../../services/offer_service.dart';

class ApplyScreen extends StatefulWidget {
  final Offer offer;

  const ApplyScreen({
    super.key,
    required this.offer,
  });

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final OfferService _offerService = OfferService();
  final TextEditingController _commentController = TextEditingController();

  final Map<String, TextEditingController> _answerControllers = {};

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    for (final question in widget.offer.questions) {
      if (question.type == 'text' && question.id != null) {
        _answerControllers[question.id!] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();

    for (final controller in _answerControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _submitApplication() async {
    // Validar preguntas obligatorias
    for (final question in widget.offer.questions) {
      if (!question.required || question.id == null) {
        continue;
      }

      final controller = _answerControllers[question.id!];

      if (controller != null && controller.text.trim().isEmpty) {
        _showMessage(
          'Debes responder: ${question.label }',
          isError: true,
        );
        return;
      }
    }

    final answers = <Map<String, String>>[];

    for (final question in widget.offer.questions) {
      if (question.id == null) continue;
      
      final controller = _answerControllers[question.id!];

      if (controller != null && controller.text.trim().isNotEmpty) {
        answers.add({
          'questionId': question.id!,
          'value': controller.text.trim(),
        });
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _offerService.applyToOffer(
        offerId: widget.offer.id,
        comment: _commentController.text.trim(),
        answers: answers,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Postulación enviada'),
            content: const Text(
              'Tu postulación fue enviada correctamente.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(
      String message, {
        required bool isError,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? AppColors.error : AppColors.secondary,
      ),
    );
  }

  Widget _buildQuestion(OfferQuestion question) {
    switch (question.type) {
      case 'text':
        return _buildTextQuestion(question);

      case 'date':
        return _buildDateQuestion(question);

      case 'select':
        return _buildSelectQuestion(question);

      case 'check':
        return _buildCheckQuestion(question);

      default:
        return _buildTextQuestion(question);
    }
  }

  Widget _buildTextQuestion(OfferQuestion question) {
    if (question.id == null) return const SizedBox.shrink();
    
    final controller = _answerControllers.putIfAbsent(
      question.id!,
      () => TextEditingController(),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: question.label ,
          hintText: question.required
              ? 'Respuesta obligatoria'
              : 'Respuesta opcional',
        ),
      ),
    );
  }

  Widget _buildDateQuestion(OfferQuestion question) {
    if (question.id == null) return const SizedBox.shrink();

    final controller = _answerControllers.putIfAbsent(
      question.id!,
      () => TextEditingController(),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: question.label ,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        onTap: () async {
          final selectedDate = await showDatePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            initialDate: DateTime.now(),
          );

          if (selectedDate != null) {
            controller.text =
            '${selectedDate.year}-'
                '${selectedDate.month.toString().padLeft(2, '0')}-'
                '${selectedDate.day.toString().padLeft(2, '0')}';
          }
        },
      ),
    );
  }

  Widget _buildSelectQuestion(OfferQuestion question) {
    if (question.id == null) return const SizedBox.shrink();

    final controller = _answerControllers.putIfAbsent(
      question.id!,
      () => TextEditingController(),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: question.label ,
          hintText: 'Escribe tu respuesta',
        ),
      ),
    );
  }

  Widget _buildCheckQuestion(OfferQuestion question) {
    if (question.id == null) return const SizedBox.shrink();

    final controller = _answerControllers.putIfAbsent(
      question.id!,
      () => TextEditingController(),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: CheckboxListTile(
        value: controller.text == 'true',
        onChanged: (value) {
          setState(() {
            controller.text = value == true ? 'true' : 'false';
          });
        },
        title: Text(question.label  ),
        contentPadding: EdgeInsets.zero,
        activeColor: AppColors.secondary,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Postularme'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              offer.jobTypeName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Completa la información para enviar tu postulación.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 28),

            if (offer.questions.isNotEmpty) ...[
              const Text(
                'Preguntas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              ...offer.questions.map(_buildQuestion),

              const SizedBox(height: 8),
            ],

            const Text(
              'Comentario',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Escribe un comentario para el empleador...',
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApplication,
                child: _isSubmitting
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Enviar postulación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}