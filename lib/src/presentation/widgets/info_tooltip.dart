import 'package:flutter/material.dart';

/// A small info icon that shows an explanation dialog when tapped.
class InfoTooltip extends StatelessWidget {
  final String title;
  final String message;
  final Color? color;

  const InfoTooltip({
    super.key,
    required this.title,
    required this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDialog(context),
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Icon(
          Icons.info_outline,
          size: 16,
          color: color ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

/// A row combining a label and an InfoTooltip icon.
class LabelWithInfo extends StatelessWidget {
  final String label;
  final String tooltipTitle;
  final String tooltipMessage;
  final TextStyle? labelStyle;

  const LabelWithInfo({
    super.key,
    required this.label,
    required this.tooltipTitle,
    required this.tooltipMessage,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: labelStyle),
        InfoTooltip(title: tooltipTitle, message: tooltipMessage),
      ],
    );
  }
}
