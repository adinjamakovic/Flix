import 'package:flix_mobile/enums/notification_type.dart';
import 'package:flix_mobile/models/app_notification.dart';
import 'package:flix_mobile/providers/notification_provider.dart';
import 'package:flix_mobile/screens/movie_details/movie_details.dart';
import 'package:flix_mobile/screens/movie_requests/movie_requests_list.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  static const double _cardAccentWidth = 3;

  late NotificationProvider _notificationProvider;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _notificationProvider = context.read<NotificationProvider>();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _notificationProvider.load();

      if (!mounted) return;

      setState(() => _isLoading = false);
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = errorText(e);
      });
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationProvider.markAllAsRead();
    } on Exception catch (e) {
      if (!mounted) return;

      showSnack(context, errorText(e));
    }
  }

  Future<void> _open(AppNotification notification) async {
    final int? id = notification.id;

    if (id != null && notification.unread) {
      try {
        await _notificationProvider.markAsRead(id);
      } on Exception catch (e) {
        if (!mounted) return;

        showSnack(context, errorText(e));
      }
    }

    if (!mounted) return;

    final Widget? destination = _destinationOf(notification);

    if (destination == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  // The ids on a notification are a deep link and nothing more, so a movie that
  // has since been deleted simply leaves the row unclickable.
  Widget? _destinationOf(AppNotification notification) {
    if (notification.movieId != null &&
        notification.type != NotificationType.movieRequestSubmitted &&
        notification.type != NotificationType.movieRequestReceived) {
      return MovieDetails(movieId: notification.movieId);
    }

    if (notification.movieRequestId != null) return const MovieRequestsList();

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final int unreadCount = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text("Mark all read"),
            ),
        ],
      ),
      body: SafeArea(top: false, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return buildMessage(
        context,
        _error!,
        action: TextButton(onPressed: _load, child: const Text("Try again")),
      );
    }

    final List<AppNotification> notifications =
        context.watch<NotificationProvider>().notifications;

    if (notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            buildMessage(
              context,
              "Nothing here yet.\n"
              "Movie requests and reports you send show up here as they move.",
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _buildCard(notifications[index]),
      ),
    );
  }

  Widget _buildCard(AppNotification notification) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final bool unread = notification.unread;
    final Color accent = unread ? colors.primary : colors.outlineVariant;

    return Container(
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.only(left: _cardAccentWidth),
      child: Material(
        color: unread ? colors.surfaceContainer : colors.surfaceContainerLow,
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(4),
          right: Radius.circular(14),
        ),
        child: InkWell(
          onTap: () => _open(notification),
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(4),
            right: Radius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  getNotificationIcon(
                    notification.type ?? NotificationType.movieRequestSubmitted,
                  ),
                  size: 20,
                  color: unread ? colors.primary : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title ?? "-",
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                          fontWeight:
                              unread ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message ?? "",
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatDateTime(notification.createdAt),
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unread) ...[
                  const SizedBox(width: 10),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
