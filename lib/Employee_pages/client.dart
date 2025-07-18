// client.dart

class Client {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String address;
  final double lat; // Prefix LatLng with googleMaps
  final double lng;
  String status;
  final String departureTime;
  final String orderId;
  final String clientId;
  final String? originalOrderId; // Make this optional

  Client(
      {required this.fullName,
      required this.phoneNumber,
      required this.email,
      required this.address,
      required this.lat,
      required this.lng,
      required this.status,
      required this.departureTime,
      required this.orderId,
      required this.clientId,
      this.originalOrderId});
}
