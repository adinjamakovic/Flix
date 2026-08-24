import 'dart:math';

import 'package:flutter/material.dart';

class InfiniteList<T> extends StatefulWidget {
  const InfiniteList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.emptyMessage,
    this.separatorBuilder,
    this.initialCount = 5,
    this.step = 5,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final String emptyMessage;
  final IndexedWidgetBuilder? separatorBuilder;
  final int initialCount;
  final int step;

  @override
  State<InfiniteList<T>> createState() => _InfiniteListState<T>();
}

class _InfiniteListState<T> extends State<InfiniteList<T>> {
  late int _visible = widget.initialCount;

  bool _onScroll(ScrollNotification notification) {
    final bool atBottom =
        notification.metrics.pixels >= notification.metrics.maxScrollExtent - 40;

    if (atBottom && _visible < widget.items.length) {
      setState(() {
        _visible = min(_visible + widget.step, widget.items.length);
      });
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (widget.items.isEmpty) {
      return Center(
        child: Text(
          widget.emptyMessage,
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      );
    }

    final int count = min(_visible, widget.items.length);
    final bool hasMore = count < widget.items.length;

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: hasMore ? count + 1 : count,
        separatorBuilder: widget.separatorBuilder ??
            (context, index) => const SizedBox.shrink(),
        itemBuilder: (context, index) => index == count
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : widget.itemBuilder(context, widget.items[index], index),
      ),
    );
  }
}
