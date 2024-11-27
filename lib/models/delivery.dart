// models/delivery.dart
class Delivery {
  final String id; // delivery id
  final DateTime scheduledTime; // estimated delivery time
  final DateTime actualTime; //actual delivery time
  final String status; // "on-time", "early", or "delayed"

  Delivery({
    required this.id,
    required this.scheduledTime,
    required this.actualTime,
    required this.status,
  });

  // Calculate deviation in minutes
  int get timeDeviation {
    return actualTime.difference(scheduledTime).inMinutes;
  }
}
