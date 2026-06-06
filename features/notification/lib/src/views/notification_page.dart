import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:provider/provider.dart';
import '../controllers/notification_controller.dart';

// ========================
// HALAMAN NOTIFIKASI (KOTAK MASUK)
// ========================
class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNotifs();
    });
  }

  void _refreshNotifs() {
    final session = context.read<SessionController>();
    final userId = session.currentUser?.id;
    if (userId != null) {
      final ids = [userId];
      if (session.isTeknisi) {
        ids.add('staff_general');
      }
      context.read<NotificationController>().loadNotifications(ids);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGrey,
      appBar: const CustomHeader(title: 'Kotak Masuk'),
      body: Consumer<NotificationController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.notifications.isEmpty) {
            return _buildEmpty();
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshNotifs();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.notifications.length,
              itemBuilder: (context, index) {
                final item = controller.notifications[index];
                return _buildNotifCard(context, controller, item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotifCard(BuildContext context, NotificationController controller, NotificationModel item) {
    bool isClaim = item.type == 'claim';
    bool isReport = item.type == 'report';

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (direction) {
        controller.deleteNotification(item.id);
      },
      child: GestureDetector(
        onTap: () {
          if (!item.isRead) {
            controller.markAsRead(item.id);
          }
          // Optional: Navigate based on metadata
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : AppColors.primaryYellow.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: item.isRead ? Colors.transparent : AppColors.primaryYellow),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isClaim ? Colors.green : (isReport ? Colors.red : AppColors.primaryBlue),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isClaim ? Icons.check_circle_outline : (isReport ? Icons.flag_outlined : Icons.notifications_outlined),
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: item.isRead ? AppColors.primaryBlue : Colors.black87,
                          ),
                        ),
                        Text(
                          TimeHelper.formatRelative(item.createdAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: item.isRead ? AppColors.textGrey : Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined,
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
