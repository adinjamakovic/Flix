import 'package:flix_mobile/providers/notification_provider.dart';
import 'package:flix_mobile/screens/notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The way into the notification list, with the unread count on it. It watches
/// the provider rather than loading anything, so the count moves with what the
/// hub pushes wherever this sits.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final int unreadCount = context.watch<NotificationProvider>().unreadCount;

    return IconButton(
      tooltip: "Notifications",
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Notifications()),
      ),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none),
          if (unreadCount > 0)
            Positioned(
              right: -4,
              top: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                constraints: const BoxConstraints(minWidth: 16),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unreadCount > 99 ? "99+" : "$unreadCount",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
