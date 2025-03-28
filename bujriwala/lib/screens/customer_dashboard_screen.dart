import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class CustomerDashboard extends StatefulWidget {
  final String role;
  const CustomerDashboard({super.key, required this.role});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  final List<Map<String, dynamic>> _scrapRequests = [];
  final ImagePicker _picker = ImagePicker();
  User? _user;
  double _totalEarnings = 0.0;
  int _completedRequests = 0;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _loadMockData();
  }

  void _loadMockData() {
    setState(() {
      _scrapRequests.clear();
      _scrapRequests.addAll([
        {
          'id': 1,
          'image': null,
          'status': 'Pending',
          'timestamp': DateTime.now().toString(),
          'type': 'Plastic',
          'weight': 2.5
        },
        {
          'id': 2,
          'image': null,
          'status': 'Completed',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)).toString(),
          'type': 'Metal',
          'weight': 1.8
        },
      ]);
      _completedRequests = 1;
      _totalEarnings = 15.50;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _scrapRequests.add({
          'id': Random().nextInt(1000),
          'image': File(pickedFile.path),
          'status': 'Pending',
          'timestamp': DateTime.now().toString(),
          'type': 'Unknown',
          'weight': 0.0
        });
      });
      _showSuccess('Scrap photo added successfully!');
    }
  }

  Future<void> _deleteRequest(int id) async {
    setState(() {
      _scrapRequests.removeWhere((request) => request['id'] == id);
    });
    _showSuccess('Request deleted successfully!');
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.role.capitalize()} Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMockData,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsRow(),
              const SizedBox(height: 20),
              _buildWelcomeCard(),
              const SizedBox(height: 20),
              if (widget.role == 'customer') _buildUploadScrapSection(),
              const SizedBox(height: 20),
              _buildPendingRequests(),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.role == 'customer'
          ? FloatingActionButton(
              onPressed: () => _showImageSourceDialog(),
              child: const Icon(Icons.add_photo_alternate),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade400],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: _user?.photoURL != null
                      ? NetworkImage(_user!.photoURL!)
                      : null,
                  child: _user?.photoURL == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  _user?.displayName ?? '${widget.role.capitalize()} Warrior',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  _user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.green),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              _loadMockData();
            },
          ),
          if (widget.role == 'customer')
            ListTile(
              leading: const Icon(Icons.upload, color: Colors.green),
              title: const Text('Upload Scrap'),
              onTap: () {
                Navigator.pop(context);
                _showImageSourceDialog();
              },
            ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.green),
            title: const Text('History'),
            onTap: () {
              Navigator.pop(context);
              _showError('History feature coming soon!');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/sign_in');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard('Earnings', '\$${_totalEarnings.toStringAsFixed(2)}', Colors.blue),
        _buildStatCard('Completed', '$_completedRequests', Colors.green),
        _buildStatCard('Pending', '${_scrapRequests.where((r) => r['status'] == 'Pending').length}', Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.recycling, size: 40, color: Colors.green),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${_user?.displayName?.split(' ')[0] ?? "${widget.role.capitalize()} Warrior"}!',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.role == 'customer'
                        ? 'Recycle more, earn more!'
                        : widget.role == 'collector'
                            ? 'Collect and make a difference!'
                            : 'Recycle for a better tomorrow!',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadScrapSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload Scrap', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _scrapRequests.isEmpty
                ? const Center(
                    child: Text('No scrap items yet. Add some photos!', style: TextStyle(color: Colors.grey)),
                  )
                : SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _scrapRequests.length,
                      itemBuilder: (context, index) {
                        final request = _scrapRequests[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: request['image'] != null
                                          ? DecorationImage(
                                              image: FileImage(request['image']),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: request['image'] == null
                                        ? const Icon(Icons.image_not_supported, size: 60)
                                        : null,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteRequest(request['id']),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(request['type'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(request['status'], style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            if (_scrapRequests.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton(
                  onPressed: () => _showSuccess('Scrap request submitted!'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Submit All Scrap'),
                ),
              ),
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

  Widget _buildPendingRequests() {
    final pendingRequests = _scrapRequests.where((r) => r['status'] == 'Pending').toList();
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pending Requests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            pendingRequests.isEmpty
                ? const Center(
                    child: Text('No pending requests.', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pendingRequests.length,
                    itemBuilder: (context, index) {
                      final request = pendingRequests[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: request['image'] != null ? FileImage(request['image']) : null,
                          child: request['image'] == null ? const Icon(Icons.recycling) : null,
                        ),
                        title: Text('Request #${request['id']} - ${request['type']}'),
                        subtitle: Text('Weight: ${request['weight']}kg | ${request['timestamp']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteRequest(request['id']),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}