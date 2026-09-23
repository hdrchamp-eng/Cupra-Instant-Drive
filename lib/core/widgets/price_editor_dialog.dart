import 'package:flutter/material.dart';

/// Owns its controller until the dialog's reverse transition has finished.
class PriceEditorDialog extends StatefulWidget {
  const PriceEditorDialog({
    required this.title,
    required this.initialRappen,
    super.key,
  });

  final String title;
  final int initialRappen;

  @override
  State<PriceEditorDialog> createState() => _PriceEditorDialogState();
}

class _PriceEditorDialogState extends State<PriceEditorDialog> {
  late final controller = TextEditingController(
    text: (widget.initialRappen / 100).toStringAsFixed(2),
  );
  String? error;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void save() {
    final francs = double.tryParse(controller.text.trim().replaceAll(',', '.'));
    if (francs == null || !francs.isFinite || francs < 0 || francs > 1000000) {
      setState(
        () => error = 'Gültigen Preis zwischen CHF 0 und 1’000’000 eingeben.',
      );
      return;
    }
    Navigator.of(context).pop((francs * 100).round());
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: 'Preis in CHF', errorText: error),
      onSubmitted: (_) => save(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Abbrechen'),
      ),
      FilledButton(onPressed: save, child: const Text('Speichern')),
    ],
  );
}
