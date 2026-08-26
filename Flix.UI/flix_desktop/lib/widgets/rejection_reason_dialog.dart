import 'package:flutter/material.dart';

Future<String?> showRejectionReasonDialog(
  BuildContext context, {
  required String title,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _RejectionReasonDialog(title: title),
  );
}

class _RejectionReasonDialog extends StatefulWidget {
  const _RejectionReasonDialog({required this.title});

  final String title;

  @override
  State<_RejectionReasonDialog> createState() => _RejectionReasonDialogState();
}

class _RejectionReasonDialogState extends State<_RejectionReasonDialog> {
  final TextEditingController _reasonController = TextEditingController();

  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    final String reason = _reasonController.text.trim();

    if (reason.isEmpty) {
      setState(() {
        _error = "Tell the requester why their submission was rejected";
      });
      return;
    }

    Navigator.pop(context, reason);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text("Reject submission"),
      content: SizedBox(
        width: 460,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Reject ${widget.title}? It stays out of the catalogue, and the "
              "requester cannot send it again for review.",
              style: TextStyle(color: colors.onSurface, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Text(
              "Reason for the requester",
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              autofocus: true,
              maxLines: 4,
              maxLength: 2000,
              style: TextStyle(color: colors.onSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Explain what is wrong with this submission...",
                errorText: _error,
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            Text(
              "This reaches the requester by e-mail and on their requests list.",
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12.5),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          ),
          child: const Text("Reject"),
        ),
      ],
    );
  }
}
