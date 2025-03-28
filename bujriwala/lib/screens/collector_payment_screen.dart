import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bujriwala/services/payment_service.dart';
import 'package:bujriwala/services/scrap_service.dart';
import 'package:bujriwala/models/scrap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CollectorPaymentScreen extends StatefulWidget {
  final User collector;

  const CollectorPaymentScreen({super.key, required this.collector});

  @override
  _CollectorPaymentScreenState createState() => _CollectorPaymentScreenState();
}

class _CollectorPaymentScreenState extends State<CollectorPaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  final ScrapService _scrapService = ScrapService();
  final ImagePicker _picker = ImagePicker();
  double _tokenBalance = 0.0;
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Scrap? _selectedScrap;
  bool _showNearbyOnly = false;
  File? _collectedImage;

  @override
  void initState() {
    super.initState();
    _fetchTokenBalance();
  }

  Future<void> _fetchTokenBalance() async {
    final balance = await _paymentService.getTokenBalance(widget.collector.uid);
    setState(() => _tokenBalance = balance);
  }

  void _loadScrapMarkers(List<Scrap> scraps) {
    setState(() {
      _markers = scraps.where((scrap) {
        if (_showNearbyOnly) {
          return (scrap.latitude - 19.0760).abs() < 0.1 && (scrap.longitude - 72.8777).abs() < 0.1;
        }
        return true;
      }).map((scrap) => Marker(
        markerId: MarkerId(scrap.id),
        position: LatLng(scrap.latitude, scrap.longitude),
        infoWindow: InfoWindow(title: 'Scrap #${scrap.id}'),
        onTap: () => _showScrapDetails(scrap),
      )).toSet();
    });
  }

  void _showScrapDetails(Scrap scrap) {
    setState(() => _selectedScrap = scrap);
    showModalBottomSheet(context: context, builder: (context) => _buildScrapDetailsSheet(scrap));
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _collectedImage = File(pickedFile.path));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image selected for proof of collection')),
      );
    }
  }

  void _showQrCode(Scrap scrap) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scrap QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: 'ScrapID:${scrap.id}|Collector:${widget.collector.uid}',
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 10),
            const Text('Show this QR code to the customer or recycler for verification.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildScrapDetailsSheet(Scrap scrap) {
    final TextEditingController bidController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scrap #${scrap.id}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Customer: ${scrap.customerEmail}'),
            const SizedBox(height: 10),
            Text('Images: ${scrap.imageUrls.join(", ")}'),
            const SizedBox(height: 10),
            Text('Location: (${scrap.latitude.toStringAsFixed(4)}, ${scrap.longitude.toStringAsFixed(4)})'),
            const SizedBox(height: 10),
            if (scrap.acceptedCollectorAddress == widget.collector.uid) ...[
              const Text('Accepted! Proceed to collect.'),
              if (_collectedImage != null)
                Image.file(_collectedImage!, height: 100, width: 100, fit: BoxFit.cover),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _showImageSourceDialog(),
                child: const Text('Upload Proof of Collection'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _showQrCode(scrap),
                child: const Text('Generate QR Code'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _collectedImage != null ? () => _collectScrap(scrap) : null,
                child: Text('Pay and Collect (₹${scrap.bids[widget.collector.uid]})'),
              ),
            ] else if (scrap.acceptedCollectorAddress != null)
              const Text('Already accepted by another collector.')
            else ...[
              TextField(
                controller: bidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Your Bid (INR)'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final bid = double.tryParse(bidController.text) ?? 0.0;
                  if (bid > 0) {
                    await _scrapService.placeBid(scrap.id, widget.collector.uid, bid);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bid placed: ₹$bid')));
                  }
                },
                child: const Text('Place Bid'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _collectScrap(Scrap scrap) {
    final bidAmount = scrap.bids[widget.collector.uid]!;
    _paymentService.initiatePayment(bidAmount, widget.collector.email ?? '', widget.collector.uid);
    _scrapService.markScrapCollected(scrap.id);
    setState(() {
      _selectedScrap = null;
      _collectedImage = null;
    });
    Navigator.pop(context);
    _showCustomerLocation(scrap);
  }

  void _showCustomerLocation(Scrap scrap) {
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(scrap.latitude, scrap.longitude), 15.0));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navigate to: (${scrap.latitude}, ${scrap.longitude})')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collector Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Welcome, ${widget.collector.email ?? 'Collector'}!', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 10),
                Text('Token Balance: $_tokenBalance WST', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _showNearbyOnly = !_showNearbyOnly);
                      },
                      child: Text(_showNearbyOnly ? 'Show All' : 'Nearby Only'),
                    ),
                    ElevatedButton(
                      onPressed: () => showModalBottomSheet(context: context, builder: (context) => _buildBidHistorySheet()),
                      child: const Text('Bid History'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Scrap>>(
              stream: _scrapService.getAvailableScraps(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                _loadScrapMarkers(snapshot.data!);
                return GoogleMap(
                  initialCameraPosition: const CameraPosition(target: LatLng(19.0760, 72.8777), zoom: 12.0),
                  markers: _markers,
                  onMapCreated: (controller) => _mapController = controller,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidHistorySheet() {
    return StreamBuilder<List<Scrap>>(
      stream: _scrapService.getScrapsWithBids(widget.collector.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final bidHistory = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your Bid History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              bidHistory.isEmpty
                  ? const Text('No bids placed yet.')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: bidHistory.length,
                      itemBuilder: (context, index) {
                        final scrap = bidHistory[index];
                        return ListTile(
                          title: Text('Scrap #${scrap.id}'),
                          subtitle: Text('Bid: ₹${scrap.bids[widget.collector.uid]}'),
                          trailing: scrap.acceptedCollectorAddress == widget.collector.uid
                              ? const Chip(label: Text('Accepted'))
                              : scrap.acceptedCollectorAddress != null
                                  ? const Chip(label: Text('Lost'))
                                  : const Chip(label: Text('Pending')),
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    _mapController.dispose();
    super.dispose();
  }
}