import 'package:flix_mobile/models/app_notification.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/base_provider.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:signalr_netcore/signalr_client.dart';

class NotificationProvider extends BaseProvider<AppNotification> {
  NotificationProvider() : super("Notification");

  static const int _pageSize = 50;

  static final String _hubUrl = () {
    const String root = String.fromEnvironment("API_BASE_URL",
        defaultValue: BaseProvider.defaultBaseUrl);

    return "${root.endsWith('/') ? root : '$root/'}hubs/notifications";
  }();

  HubConnection? _hub;
  bool _wantsConnection = false;
  bool _isStarting = false;

  List<AppNotification> _notifications = const [];
  int _unreadCount = 0;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLive => _hub?.state == HubConnectionState.Connected;

  @override
  AppNotification fromJson(data) {
    return AppNotification.fromJson(data);
  }

  Future<void> load() async {
    final SearchResult<AppNotification> result = await get(filter: {
      "page": 1,
      "pageSize": _pageSize,
      "includeTotalCount": true,
    });

    _notifications = itemsOf(result);
    _unreadCount = _notifications.where((item) => item.unread).length;

    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    final AppNotification updated =
        AppNotification.fromJson(await putJson("MarkAsRead/$id"));

    _notifications = _notifications
        .map((item) => item.id == id ? updated : item)
        .toList(growable: false);

    _unreadCount = _notifications.where((item) => item.unread).length;

    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    await putJson("MarkAllAsRead");

    await load();
  }

  Future<void> start() async {
    _wantsConnection = true;

    if (_isStarting || isLive) return;

    _isStarting = true;

    try {
      final HubConnection hub = _hub ??= _build();

      await hub.start();
    } catch (_) {
      _retryLater();
    } finally {
      _isStarting = false;
    }
  }

  Future<void> stop() async {
    _wantsConnection = false;

    final HubConnection? hub = _hub;
    _hub = null;

    _notifications = const [];
    _unreadCount = 0;

    if (hub != null) {
      try {
        await hub.stop();
      } catch (_) {}
    }

    notifyListeners();
  }

  HubConnection _build() {
    final HubConnection hub = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => AuthProvider.accessToken ?? "",
          ),
        )
        .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 30000])
        .build();

    hub.on("notificationReceived", _onNotificationReceived);
    hub.on("unreadCountChanged", _onUnreadCountChanged);

    hub.onreconnected(({connectionId}) {
      load().catchError((_) {});
    });

    hub.onclose(({error}) {
      if (_wantsConnection) _retryLater();
    });

    return hub;
  }

  void _onNotificationReceived(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    final Object? payload = arguments.first;
    if (payload is! Map) return;

    final AppNotification notification;

    try {
      notification = AppNotification.fromJson(Map<String, dynamic>.from(payload));
    } catch (_) {
      return;
    }

    _notifications = [
      notification,
      ..._notifications.where((item) => item.id != notification.id),
    ];

    if (arguments.length > 1 && arguments[1] is int) {
      _unreadCount = arguments[1] as int;
    } else {
      _unreadCount = _notifications.where((item) => item.unread).length;
    }

    notifyListeners();
  }

  void _onUnreadCountChanged(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    final Object? count = arguments.first;
    if (count is! int) return;

    _unreadCount = count;

    notifyListeners();
  }

  void _retryLater() {
    Future.delayed(const Duration(seconds: 10), () async {
      if (!_wantsConnection || isLive || _isStarting) return;

      await AuthProvider.refreshSession();

      await start();
    });
  }
}
