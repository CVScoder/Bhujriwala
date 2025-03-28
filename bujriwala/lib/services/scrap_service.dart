// lib/services/scrap_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bujriwala/models/scrap.dart';

class ScrapService {
  final CollectionReference _scrapsCollection = FirebaseFirestore.instance.collection('scraps');

  Future<void> publishScrap(Scrap scrap) async {
    await _scrapsCollection.doc(scrap.id).set(scrap.toJson());
  }

  Stream<List<Scrap>> getAvailableScraps() {
    return _scrapsCollection
        .where('isCollected', isEqualTo: false)
        .where('acceptedCollectorAddress', isNull: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Scrap.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Future<void> placeBid(String scrapId, String collectorAddress, double bidAmount) async {
    await _scrapsCollection.doc(scrapId).update({
      'bids.$collectorAddress': bidAmount,
    });
  }

  Future<void> acceptBid(String scrapId, String collectorAddress) async {
    await _scrapsCollection.doc(scrapId).update({
      'acceptedCollectorAddress': collectorAddress,
    });
  }

  Future<void> markScrapCollected(String scrapId) async {
    await _scrapsCollection.doc(scrapId).update({
      'isCollected': true,
    });
  }

  Stream<List<Scrap>> getScrapsByEmail(String email) {
    return _scrapsCollection
        .where('customerEmail', isEqualTo: email)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Scrap.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<Scrap>> getScrapsWithBids(String collectorAddress) {
    return _scrapsCollection
        .where('bids.$collectorAddress', isGreaterThan: 0)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Scrap.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }
}