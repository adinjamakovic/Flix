import 'package:flix_desktop/enums/report_status.dart';
import 'package:flutter/material.dart';

class ReportReview {
  const ReportReview(this.status, this.adminComment);

  final ReportStatus status;
  final String adminComment;
}

Future<ReportReview?> showReportReviewDialog(
  BuildContext context, {
  required String header,
  required ReportStatus status,
  String? adminComment,
}) {
  return showDialog<ReportReview>(
    context: context,
    builder: (context) => _ReportReviewDialog(
      header: header,
      status: status,
      adminComment: adminComment,
    ),
  );
}

class _ReportReviewDialog extends StatefulWidget {
  const _ReportReviewDialog({
    required this.header,
    required this.status,
    required this.adminComment,
  });

  final String header;
  final ReportStatus status;
  final String? adminComment;

  @override
  State<_ReportReviewDialog> createState() => _ReportReviewDialogState();
}

class _ReportReviewDialogState extends State<_ReportReviewDialog> {
  late ReportStatus _status;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();

    _status = widget.status == ReportStatus.dismissed
        ? ReportStatus.dismissed
        : ReportStatus.resolved;

    _commentController = TextEditingController(text: widget.adminComment ?? "");
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text("Review report"),
      content: SizedBox(
        width: 460,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.header,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildLabel("Outcome"),
            const SizedBox(height: 8),
            SegmentedButton<ReportStatus>(
              segments: const [
                ButtonSegment<ReportStatus>(
                  value: ReportStatus.resolved,
                  label: Text("Resolved"),
                  icon: Icon(Icons.check, size: 18),
                ),
                ButtonSegment<ReportStatus>(
                  value: ReportStatus.dismissed,
                  label: Text("Dismissed"),
                  icon: Icon(Icons.block, size: 18),
                ),
              ],
              selected: {_status},
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                setState(() {
                  _status = selection.first;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildLabel("Comment for the reporter"),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 2000,
              style: TextStyle(color: colors.onSurface, fontSize: 14),
              decoration: const InputDecoration(
                hintText: "Explain what was done about this report...",
              ),
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
          onPressed: () => Navigator.pop(
            context,
            ReportReview(_status, _commentController.text.trim()),
          ),
          child: const Text("Save"),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Text(
      label,
      style: TextStyle(
        color: colors.onSurfaceVariant,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
