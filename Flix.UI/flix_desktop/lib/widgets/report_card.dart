import 'package:flix_desktop/enums/report_status.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flutter/material.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.header,
    required this.subjectIcon,
    required this.subject,
    required this.reportedBy,
    required this.createdAt,
    required this.description,
    required this.status,
    required this.reviewedBy,
    required this.resolvedAt,
    required this.adminComment,
    required this.onReview,
  });

  final String header;
  final IconData subjectIcon;
  final String subject;
  final String reportedBy;
  final DateTime? createdAt;
  final String? description;
  final ReportStatus status;
  final String? reviewedBy;
  final DateTime? resolvedAt;
  final String? adminComment;
  final VoidCallback onReview;

  bool get _isOpen => status == ReportStatus.open;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildHeading(context)),
              const SizedBox(width: 24),
              ReportStatusChip(status: status),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description?.trim().isNotEmpty == true
                ? description!.trim()
                : "This report has no written description.",
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 14.5,
              height: 1.35,
            ),
          ),
          if (!_isOpen) ...[
            const SizedBox(height: 16),
            _buildOutcome(context),
          ],
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _isOpen
                ? ElevatedButton.icon(
                    onPressed: onReview,
                    icon: const Icon(Icons.gavel, size: 18),
                    label: const Text("Review"),
                  )
                : OutlinedButton.icon(
                    onPressed: onReview,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text("Update outcome"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.onSurface,
                      side: BorderSide(color: colors.outline),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final TextStyle byline = TextStyle(
      color: colors.onSurfaceVariant,
      fontSize: 13.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(subjectIcon, size: 17, color: colors.onSurfaceVariant),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                subject,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            style: byline,
            children: [
              const TextSpan(text: "Reported by "),
              TextSpan(
                text: reportedBy,
                style: byline.copyWith(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: " on ${formatDate(createdAt)}"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOutcome(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final String reviewer =
        reviewedBy?.trim().isNotEmpty == true ? reviewedBy!.trim() : "an admin";
    final String verb =
        status == ReportStatus.resolved ? "Resolved" : "Dismissed";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$verb by $reviewer on ${formatDate(resolvedAt)}",
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            adminComment?.trim().isNotEmpty == true
                ? adminComment!.trim()
                : "No comment was left for the reporter.",
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class ReportStatusChip extends StatelessWidget {
  const ReportStatusChip({super.key, required this.status});

  static const Color _resolvedColor = Color(0xFF22C55E);

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Color color = switch (status) {
      ReportStatus.open => colors.primary,
      ReportStatus.resolved => _resolvedColor,
      ReportStatus.dismissed => colors.onSurfaceVariant,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        getReportStatus(status),
        style: TextStyle(
          color: color,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
