import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../models/home/notification_model.dart';
import 'package:graduation_project/services/notifications_service/notifications_service.dart';


String _timeAgo(String sentAt) {
  try {
    DateTime date;
    if (sentAt.contains('/')) {
      final parts = sentAt.split('/');
      date = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      ).toLocal();
    } else {
      date = DateTime.parse(sentAt).toLocal();
    }

    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  } catch (_) {
    return '';
  }
}

_IconConfig _iconConfigFromType(String type) {
  switch (type.toLowerCase()) {
    case 'order':
      return _IconConfig(
        icon: Icons.inventory_2_outlined,
        bgColor: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF00A63E),
      );
    case 'bags':
    case 'baggage':
      return _IconConfig(
        icon: Icons.luggage_outlined,
        bgColor: const Color(0xFFDBEAFE),
        iconColor: const Color(0xFF155DFC),
      );
    case 'appointment':
      return _IconConfig(
        icon: Icons.flight_outlined,
        bgColor: const Color(0xFFFEF9C2),
        iconColor: const Color(0xFFD08700),
      );
    case 'delivery':
      return _IconConfig(
        icon: Icons.location_on_outlined,
        bgColor: const Color(0xFFDBEAFE),
        iconColor: const Color(0xFF155DFC),
      );
    case 'boarding':
      return _IconConfig(
        icon: Icons.airplanemode_active,
        bgColor: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF00A63E),
      );
    case 'gate':
      return _IconConfig(
        icon: Icons.notifications_outlined,
        bgColor: const Color(0xFFFFE2E2),
        iconColor: const Color(0xFFE7000B),
      );
    case 'bagscan':
    case 'bag_scan':
      return _IconConfig(
        icon: Icons.location_on_outlined,
        bgColor: const Color(0xFFDBEAFE),
        iconColor: const Color(0xFF155DFC),
      );
    case 'accountalert':
      return _IconConfig(
        icon: Icons.person_outline,
        bgColor: const Color(0xFFFEF9C2),
        iconColor: const Color(0xFFD08700),
      );
    default:
      return _IconConfig(
        icon: Icons.notifications_outlined,
        bgColor: const Color(0xFFDBEAFE),
        iconColor: const Color(0xFF155DFC),
      );
  }
}


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final int _selectedIndex = 2;
  final NotificationsService _service = NotificationsService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _isMarkingAll = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await _service.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = response.notifications;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    final success = await _service.markAsRead(notificationId);
    if (success && mounted) {
      setState(() {
        _notifications = _notifications.map((n) {
          return n.notificationId == notificationId
              ? NotificationModel(
                  notificationId: n.notificationId,
                  type: n.type,
                  title: n.title,
                  message: n.message,
                  orderId: n.orderId,
                  baggageId: n.baggageId,
                  isRead: true,
                  sentAt: n.sentAt,
                )
              : n;
        }).toList();
      });
    }
  }

  Future<void> _handleMarkAllAsRead() async {
    if (_isMarkingAll) return;
    setState(() => _isMarkingAll = true);

    final success = await _service.markAllAsRead();

    if (success && mounted) {
      setState(() {
        _notifications = _notifications
            .map((n) => NotificationModel(
                  notificationId: n.notificationId,
                  type: n.type,
                  title: n.title,
                  message: n.message,
                  orderId: n.orderId,
                  baggageId: n.baggageId,
                  isRead: true,
                  sentAt: n.sentAt,
                ))
            .toList();
        _isMarkingAll = false;
      });
    } else {
      if (mounted) setState(() => _isMarkingAll = false);
    }
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF274C77),
                      ),
                    )
                  : _notifications.isEmpty
                      ? _buildEmptyState()
                      : _buildNotificationsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.chevron_left,
              size: 28,
              color: Colors.black87,
            ),
          ),
          const Expanded(
            child: Text(
              'Notifications',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF274C77),
              ),
            ),
          ),
          _isMarkingAll
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF274C77),
                  ),
                )
              : GestureDetector(
                  onTap: _handleMarkAllAsRead,
                  child: const Text(
                    'Read All',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF155DFC),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_notifications.png',
            width: 220,
            height: 220,
          ),
          const SizedBox(height: 24),
          const Text(
            'No Notification Available',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF274C77),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "We strive to keep you informed...",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7D94)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _NotificationCard(
          item: _notifications[index],
          onMarkAsRead: _markAsRead,
        );
      },
    );
  }
}


class _NotificationCard extends StatefulWidget {
  final NotificationModel item;
  final Future<void> Function(int notificationId) onMarkAsRead;

  const _NotificationCard({
    required this.item,
    required this.onMarkAsRead,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _isMarkingRead = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _controller.forward() : _controller.reverse();
  }

  Future<void> _handleMarkAsRead() async {
    if (_isMarkingRead) return;
    setState(() => _isMarkingRead = true);
    await widget.onMarkAsRead(widget.item.notificationId);
    if (mounted) setState(() => _isMarkingRead = false);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isUnread = !item.isRead;
    final iconCfg = _iconConfigFromType(item.type);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconCfg.bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        Icon(iconCfg.icon, color: iconCfg.iconColor, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                          Text(
                            _timeAgo(item.sentAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8B8A8A),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF155DFC),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizeTransition(
                        sizeFactor: _expandAnim,
                        axisAlignment: -1,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            item.message,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4A5565),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      if (item.orderId != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Order ID: ${item.orderId}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8B8A8A),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: isUnread
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
              children: [
                if (isUnread)
                  GestureDetector(
                    onTap: _handleMarkAsRead,
                    child: _isMarkingRead
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF155DFC),
                            ),
                          )
                        : Row(
                            children: const [
                              Icon(
                                Icons.check_circle_outline,
                                size: 14,
                                color: Color(0xFF155DFC),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Mark as read',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF155DFC),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                GestureDetector(
                  onTap: _toggle,
                  child: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: Color(0xFF8B8A8A),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconConfig {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  const _IconConfig({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}
