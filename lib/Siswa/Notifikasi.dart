import 'package:flutter/material.dart';

void main() {
  runApp(Notifikasi());
}

class Notifikasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifications Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NotificationPage(),
    );
  }
}

class Notification {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final bool isNew;

  Notification({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.isNew,
  });
}

class NotificationPage extends StatelessWidget {
  final List<Notification> notifications = [
    Notification(
      title: "NILAI",
      message: "Hore, nilai pai kamu udh di publish sama guru",
      time: "9:35 AM",
      icon: Icons.check_circle,
      isNew: true,
    ),
    
    Notification(
      title: "NILAI",
      message: "Hore, nilai Tematik kamu udh di publish sama guru",
      time: "Yesterday",
      icon: Icons.check_circle,
      isNew: false,
    ),
   
    
  ];

  @override
  Widget build(BuildContext context) {
    final newNotifications = notifications.where((n) => n.isNew).toList();
    final earlierNotifications = notifications.where((n) => !n.isNew).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView(
        children: <Widget>[
          if (newNotifications.isNotEmpty) ...[
            SectionHeader(title: 'New', count: newNotifications.length),
            NotificationList(notifications: newNotifications),
          ],
          if (earlierNotifications.isNotEmpty) ...[
            SectionHeader(title: 'Earlier', count: earlierNotifications.length),
            NotificationList(notifications: earlierNotifications),
          ],
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade50,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.blue,
            child: Text(
              '$count',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  final List<Notification> notifications;

  NotificationList({required this.notifications});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue.shade100,
                child: Icon(notification.icon, color: Colors.blue, size: 30),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (notification.message.isNotEmpty)
                      Text(notification.message),
                    Text(
                      notification.time,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (notification.isNew)
                Icon(Icons.circle, color: Colors.blue, size: 12),
            ],
          ),
        );
      },
    );
  }
}
