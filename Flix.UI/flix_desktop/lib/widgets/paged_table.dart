import 'package:flutter/material.dart';

class TableColumn<T> {
  const TableColumn({
    required this.label,
    required this.flex,
    required this.value,
    this.bold = false,
    this.muted = false,
  }) : builder = null;

  const TableColumn.custom({
    required this.label,
    required this.flex,
    required this.builder,
  })  : value = null,
        bold = false,
        muted = false;

  factory TableColumn.actions({
    String label = "ACTIONS",
    int flex = 14,
    void Function(T item)? onEdit,
    void Function(T item)? onDelete,
  }) {
    return TableColumn<T>.custom(
      label: label,
      flex: flex,
      builder: (context, item) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _actionButton(
            context: context,
            icon: Icons.edit_square,
            tooltip: "Edit",
            onPressed: onEdit == null ? null : () => onEdit(item),
          ),
          _actionButton(
            context: context,
            icon: Icons.delete_outline,
            tooltip: "Delete",
            onPressed: onDelete == null ? null : () => onDelete(item),
          ),
        ],
      ),
    );
  }

  final String label;
  final int flex;
  final bool bold;
  final bool muted;

  final String Function(T item)? value;

  final Widget Function(BuildContext context, T item)? builder;

  Widget _buildCell(BuildContext context, T item) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Widget Function(BuildContext, T)? cellBuilder = builder;
    if (cellBuilder != null) {
      return Expanded(flex: flex, child: cellBuilder(context, item));
    }

    return Expanded(
      flex: flex,
      child: Text(
        value!(item),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: muted ? colors.onSurfaceVariant : colors.onSurface,
          fontSize: 13.5,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colors.onTertiary,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  static Widget _actionButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      color: Theme.of(context).colorScheme.onSurface,
      tooltip: tooltip,
      splashRadius: 20,
    );
  }
}

class PagedTable<T> extends StatelessWidget {
  const PagedTable({
    super.key,
    required this.columns,
    required this.items,
    required this.isLoading,
    required this.emptyMessage,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.onPageChanged,
  });

  final List<TableColumn<T>> columns;
  final List<T> items;
  final bool isLoading;
  final String emptyMessage;
  final int page;
  final int pageSize;
  final int totalCount;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildTable(context)),
        const SizedBox(height: 12),
        Pagination(
          page: page,
          pageSize: pageSize,
          totalCount: totalCount,
          onPageChanged: onPageChanged,
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildTableHeader(context),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? Center(
                        child: Text(
                          emptyMessage,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          color: colors.outlineVariant,
                        ),
                        itemBuilder: (context, index) =>
                            _buildRow(context, items[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      height: 46,
      color: Theme.of(context).colorScheme.tertiary,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final column in columns) column._buildHeaderCell(context),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, T item) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final column in columns) column._buildCell(context, item),
        ],
      ),
    );
  }
}

class Pagination extends StatelessWidget {
  const Pagination({
    super.key,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.onPageChanged,
  });

  final int page;
  final int pageSize;
  final int totalCount;
  final ValueChanged<int> onPageChanged;

  int get _totalPages {
    final int pages = (totalCount / pageSize).ceil();
    return pages < 1 ? 1 : pages;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final int totalPages = _totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text("Previous"),
          style: TextButton.styleFrom(
            foregroundColor: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4),
        ..._pageNumbers(totalPages).map((page) => page == null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  "...",
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              )
            : _buildPageButton(context, page)),
        const SizedBox(width: 4),
        TextButton.icon(
          onPressed: page < totalPages ? () => onPageChanged(page + 1) : null,
          icon: const Icon(Icons.arrow_forward, size: 16),
          label: const Text("Next"),
          iconAlignment: IconAlignment.end,
          style: TextButton.styleFrom(
            foregroundColor: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPageButton(BuildContext context, int pageNumber) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool selected = pageNumber == page;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: selected ? null : () => onPageChanged(pageNumber),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            pageNumber.toString(),
            style: TextStyle(
              color: selected ? colors.onSecondary : colors.onSurfaceVariant,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  List<int?> _pageNumbers(int totalPages) {
    if (totalPages <= 7) {
      return List<int?>.generate(totalPages, (index) => index + 1);
    }

    final Set<int> pages = {1, 2, 3, totalPages - 1, totalPages};
    for (int candidate = page - 1; candidate <= page + 1; candidate++) {
      if (candidate >= 1 && candidate <= totalPages) pages.add(candidate);
    }

    final List<int> sorted = pages.toList()..sort();
    final List<int?> withGaps = [];
    for (int i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) withGaps.add(null);
      withGaps.add(sorted[i]);
    }

    return withGaps;
  }
}
