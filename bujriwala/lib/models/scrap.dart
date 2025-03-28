// lib/models/scrap.dart
class Scrap {
  final String id;
  final String customerEmail;
  final String customerAddress;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  bool isCollected;
  Map<String, double> bids;
  String? acceptedCollectorAddress;

  Scrap({
    required this.id,
    required this.customerEmail,
    required this.customerAddress,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    this.isCollected = false,
    this.bids = const {},
    this.acceptedCollectorAddress,
  });

  // Convert Scrap to Firestore-compatible map
  Map<String, dynamic> toJson() => {
        'id': id,
        'customerEmail': customerEmail,
        'customerAddress': customerAddress,
        'latitude': latitude,
        'longitude': longitude,
        'imageUrls': imageUrls,
        'isCollected': isCollected,
        'bids': bids,
        'acceptedCollectorAddress': acceptedCollectorAddress,
      };

  // Create Scrap from Firestore document
  factory Scrap.fromJson(Map<String, dynamic> json) => Scrap(
        id: json['id'],
        customerEmail: json['customerEmail'],
        customerAddress: json['customerAddress'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        imageUrls: List<String>.from(json['imageUrls']),
        isCollected: json['isCollected'],
        bids: Map<String, double>.from(json['bids']),
        acceptedCollectorAddress: json['acceptedCollectorAddress'],
      );
}