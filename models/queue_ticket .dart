import 'user.dart';

class QueueTicket {
  final String id;
  final String department;
  final User user;
  final DateTime timestamp;
  final int position;

  QueueTicket({
    required this.id,
    required this.department,
    required this.user,
    required this.timestamp,
    required this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'department': department,
      'user': user.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'position': position,
    };
  }

  factory QueueTicket.fromJson(Map<String, dynamic> json) {
    return QueueTicket(
      id: json['id'],
      department: json['department'],
      user: User.fromJson(json['user']),
      timestamp: DateTime.parse(json['timestamp']),
      position: json['position'],
    );
  }
}