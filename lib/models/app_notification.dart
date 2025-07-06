class AppNotification {
  String id;
  String type;
  String title;
  String message;
  String timestamp;
  bool read;
  dynamic data;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.timestamp,
    required this.message,
    required this.read,
    required this.data,
  });

  factory AppNotification.fromMap(Map<dynamic, dynamic> data) {
    return AppNotification(
      id: data['id'] ?? '',
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      timestamp: data['timestamp'] ?? '',
      message: data['message'] ?? '',
      read: data['read']?? false,
      data: data['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'read': read,
      'timestamp': timestamp,
      'message': message,
      'data': data,
    };
  }
}
