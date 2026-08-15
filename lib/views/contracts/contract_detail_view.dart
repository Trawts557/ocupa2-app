import 'package:flutter/material.dart';
import '../../services/contract_service.dart';

class ContractDetailView extends StatefulWidget {
  final String contractId;

  const ContractDetailView({super.key, required this.contractId});

  @override
  State<ContractDetailView> createState() => _ContractDetailViewState();
}

class _ContractDetailViewState extends State<ContractDetailView> {
  final ContractService _contractService = ContractService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del contrato')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _contractService.getContractById(widget.contractId),
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
              (comment) => _buildComment(comment as Map<String, dynamic>),
            ),

          const SizedBox(height: 28),

          Text('Fotos', style: Theme.of(context).textTheme.titleLarge),

          const SizedBox(height: 12),

          if (photos.isEmpty)
            const Text('Este contrato todavía no tiene fotos.')
          else
            ...photos.map(
              (photo) => _buildPhoto(photo as Map<String, dynamic>),
            ),
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
          ElevatedButton(
            onPressed: _acceptContract,
            child: const Text('Aceptar'),
          ),

        if (status == 'pending' && role == 'contratado')
          OutlinedButton(
            onPressed: _rejectContract,
            child: const Text('Rechazar'),
          ),

        if (status == 'pending' && role == 'contratante')
          ElevatedButton(
            onPressed: _setTerms,
            child: const Text('Fijar términos'),
          ),

        if (status == 'active')
          ElevatedButton(onPressed: _addComment, child: const Text('Comentar')),

        if (status == 'active')
          OutlinedButton(
            onPressed: () {
              // TODO:
              // Seleccionar imagen y enviarla mediante
              // POST /contracts/{id}/photos
            },
            child: const Text('Agregar foto'),
          ),

        if (status == 'active')
          OutlinedButton(
            onPressed: _cancelContract,
            child: const Text('Cancelar contrato'),
          ),
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

    if (salary == null) {
      return 'No definido';
    }

    return '$salary $currency';
  }

  Future<void> _acceptContract() async {
    try {
      await _contractService.acceptContract(widget.contractId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contrato aceptado correctamente')),
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _rejectContract() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rechazar contrato'),
          content: const Text('¿Seguro que deseas rechazar este contrato?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Rechazar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _contractService.rejectContract(widget.contractId);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Contrato rechazado')));

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _setTerms() async {
    final salaryController = TextEditingController();

    final durationController = TextEditingController();

    final dateController = TextEditingController();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Fijar términos'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: salaryController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Salario'),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de inicio',
                    hintText: '2026-08-20',
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: durationController,
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
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      salaryController.dispose();
      durationController.dispose();
      dateController.dispose();
      return;
    }

    final salary = double.tryParse(salaryController.text.trim());

    final startDate = dateController.text.trim();

    final duration = durationController.text.trim();

    salaryController.dispose();
    durationController.dispose();
    dateController.dispose();

    if (salary == null || startDate.isEmpty || duration.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los términos correctamente'),
        ),
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Términos actualizados')));

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _addComment() async {
    final controller = TextEditingController();

    final String? comment = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar comentario'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Comentario'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (comment == null || comment.isEmpty) {
      return;
    }

    try {
      await _contractService.addComment(id: widget.contractId, body: comment);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Comentario agregado')));

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _cancelContract() async {
    final controller = TextEditingController();

    final String? justification = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar contrato'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Justificación'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Volver'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Cancelar contrato'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (justification == null || justification.isEmpty) {
      return;
    }

    try {
      await _contractService.cancelContract(
        id: widget.contractId,
        justification: justification,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Contrato cancelado')));

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }
}
