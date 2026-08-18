import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

import '../../services/contract_service.dart';

class ContractDetailView extends StatefulWidget {
  final String contractId;

  const ContractDetailView({super.key, required this.contractId});

  @override
  State<ContractDetailView> createState() => _ContractDetailViewState();
}

class _ContractDetailViewState extends State<ContractDetailView> {
  final ContractService _contractService = ContractService();
  final ImagePicker _imagePicker = ImagePicker();

  Future<Map<String, dynamic>>? _futureContract;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _futureContract = _contractService.getContractById(widget.contractId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del contrato')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureContract,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final contract = snapshot.data;
          if (contract == null) {
            return const Center(child: Text('No se pudo cargar el contrato.'));
          }

          return _buildContractDetail(context, contract);
        },
      ),
    );
  }

  Widget _buildContractDetail(
    BuildContext context,
    Map<String, dynamic> contract,
  ) {
    final contratante = contract['contratante'] as Map<String, dynamic>?;
    final contratado = contract['contratado'] as Map<String, dynamic>?;
    final comments = contract['comments'] as List<dynamic>? ?? [];
    final photos = contract['photos'] as List<dynamic>? ?? [];
    final String status = contract['status']?.toString() ?? 'Sin estado';
    final String role = contract['myRole']?.toString() ?? 'Sin rol';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contract['jobTypeName']?.toString() ?? 'Contrato',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          _buildInfo('Estado', status),
          _buildInfo('Mi rol', role),
          _buildInfo(
            'Contratante',
            contratante?['nombre']?.toString() ?? 'No disponible',
          ),
          _buildInfo(
            'Contratado',
            contratado?['nombre']?.toString() ?? 'No disponible',
          ),
          _buildInfo('Salario', _formatSalary(contract)),
          _buildInfo(
            'Fecha de inicio',
            contract['startDate']?.toString() ?? 'No definida',
          ),
          _buildInfo(
            'Duración',
            contract['duration']?.toString() ?? 'No definida',
          ),
          const SizedBox(height: 24),
          Text('Acciones', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildActions(contract),
          const SizedBox(height: 28),
          Text('Comentarios', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (comments.isEmpty)
            const Text('Este contrato todavía no tiene comentarios.')
          else
            ...comments.map(
              (c) => _buildComment(c as Map<String, dynamic>),
            ),
          const SizedBox(height: 28),
          Text('Fotos', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (photos.isEmpty)
            const Text('Este contrato todavía no tiene fotos.')
          else
            ...photos.map((p) => _buildPhoto(p as Map<String, dynamic>)),
        ],
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActions(Map<String, dynamic> contract) {
    final String role = contract['myRole']?.toString() ?? '';
    final String status = contract['status']?.toString() ?? '';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (status == 'pending' && role == 'contratado')
          ElevatedButton(onPressed: _acceptContract, child: const Text('Aceptar')),
        if (status == 'pending' && role == 'contratado')
          OutlinedButton(onPressed: _rejectContract, child: const Text('Rechazar')),
        if (status == 'pending' && role == 'contratante')
          ElevatedButton(onPressed: _setTerms, child: const Text('Fijar términos')),
        if (status == 'active')
          ElevatedButton(onPressed: _addComment, child: const Text('Comentar')),
        if (status == 'active')
          OutlinedButton.icon(
            onPressed: _addPhoto,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Agregar foto'),
          ),
        if (status == 'active')
          OutlinedButton(onPressed: _cancelContract, child: const Text('Cancelar contrato')),
      ],
    );
  }

  Widget _buildComment(Map<String, dynamic> comment) {
    final by = comment['by'] as Map<String, dynamic>?;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              by?['nombre']?.toString() ?? 'Usuario',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(comment['body']?.toString() ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoto(Map<String, dynamic> photo) {
    final by = photo['by'] as Map<String, dynamic>?;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.image_outlined),
        title: Text(photo['description']?.toString() ?? 'Foto del contrato'),
        subtitle: Text(by?['nombre']?.toString() ?? 'Usuario'),
      ),
    );
  }

  String _formatSalary(Map<String, dynamic> contract) {
    final salary = contract['salary'];
    final currency = contract['currency']?.toString() ?? '';
    if (salary == null) return 'No definido';
    return '$salary $currency';
  }

  // ============================================
  // ACCIONES
  // ============================================

  Future<void> _setTerms() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _TermsDialog(),
    );

    if (!mounted || result == null) return;

    final salary = double.tryParse(result['salary'] ?? '');
    final startDate = result['startDate'] ?? '';
    final duration = result['duration'] ?? '';

    if (salary == null || startDate.isEmpty || duration.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los términos correctamente')),
      );
      return;
    }

    try {
      await _contractService.setTerms(
        id: widget.contractId,
        salary: salary,
        currency: 'DOP',
        startDate: startDate,
        duration: duration,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Términos actualizados')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _acceptContract() async {
    try {
      await _contractService.acceptContract(widget.contractId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contrato aceptado correctamente')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _rejectContract() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rechazar contrato'),
        content: const Text('¿Seguro que deseas rechazar este contrato?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _contractService.rejectContract(widget.contractId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contrato rechazado')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _addComment() async {
    final comment = await showDialog<String>(
      context: context,
      builder: (_) => const _TextDialog(
        title: 'Agregar comentario',
        label: 'Comentario',
        maxLines: 4,
        confirmLabel: 'Enviar',
      ),
    );

    if (comment == null || comment.isEmpty || !mounted) return;

    try {
      await _contractService.addComment(id: widget.contractId, body: comment);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario agregado')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _addPhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (image == null || !mounted) return;

    final description = await showDialog<String>(
      context: context,
      builder: (_) => const _TextDialog(
        title: 'Agregar foto',
        label: 'Descripción',
        hint: 'Describe esta foto',
        maxLines: 3,
        confirmLabel: 'Subir',
      ),
    );

    if (description == null || description.isEmpty || !mounted) return;

    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      final extension = image.name.split('.').last.toLowerCase();
      final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
      final dataUri = 'data:$mimeType;base64,$base64Image';

      await _contractService.addPhoto(
        id: widget.contractId,
        photo: dataUri,
        description: description,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto agregada correctamente')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _cancelContract() async {
    final justification = await showDialog<String>(
      context: context,
      builder: (_) => const _TextDialog(
        title: 'Cancelar contrato',
        label: 'Justificación',
        maxLines: 3,
        confirmLabel: 'Cancelar contrato',
      ),
    );

    if (justification == null || justification.isEmpty || !mounted) return;

    try {
      await _contractService.cancelContract(
        id: widget.contractId,
        justification: justification,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contrato cancelado')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }
}

// ============================================
// DIÁLOGOS (cada uno maneja y desecha SUS PROPIOS controllers)
// ============================================

/// Diálogo de términos: salary, fecha, duración.
class _TermsDialog extends StatefulWidget {
  const _TermsDialog();

  @override
  State<_TermsDialog> createState() => _TermsDialogState();
}

class _TermsDialogState extends State<_TermsDialog> {
  final _salaryController = TextEditingController();
  final _dateController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void dispose() {
    _salaryController.dispose();
    _dateController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fijar términos'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Salario'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Fecha de inicio',
                hintText: '2026-08-20',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duración',
                hintText: '3 meses',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'salary': _salaryController.text.trim(),
            'startDate': _dateController.text.trim(),
            'duration': _durationController.text.trim(),
          }),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

/// Diálogo genérico de un solo campo de texto.
class _TextDialog extends StatefulWidget {
  final String title;
  final String label;
  final String? hint;
  final int maxLines;
  final String confirmLabel;

  const _TextDialog({
    required this.title,
    required this.label,
    this.hint,
    this.maxLines = 1,
    required this.confirmLabel,
  });

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}