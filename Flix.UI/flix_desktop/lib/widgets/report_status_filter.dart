import 'package:flix_desktop/enums/report_status.dart';
import 'package:flutter/material.dart';

class ReportStatusFilter extends StatelessWidget {
  const ReportStatusFilter({
    super.key,
    required this.status,
    required this.allLabel,
    required this.onChanged,
  });

  final ReportStatus? status;
  final String allLabel;
  final ValueChanged<ReportStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 26,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Status",
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 46,
                child: InputDecorator(
                  isEmpty: status == null,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ReportStatus?>(
                      value: status,
                      isExpanded: true,
                      isDense: true,
                      alignment: AlignmentDirectional.centerStart,
                      borderRadius: BorderRadius.circular(10),
                      icon:
                          Icon(Icons.expand_more, color: colors.onSurfaceVariant),
                      style: TextStyle(color: colors.onSurface, fontSize: 14),
                      items: [
                        DropdownMenuItem<ReportStatus?>(
                          value: null,
                          child: Text(
                            allLabel,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        ...ReportStatus.values.map(
                          (status) => DropdownMenuItem<ReportStatus?>(
                            value: status,
                            child: Text(getReportStatus(status)),
                          ),
                        ),
                      ],
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 74),
      ],
    );
  }
}
