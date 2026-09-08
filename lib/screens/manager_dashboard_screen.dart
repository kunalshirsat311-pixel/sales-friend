import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/share_service.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  final ShareService _shareService = ShareService();
  final TextEditingController _codeController = TextEditingController();
  List<String> _linkedSalesmen = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLinkedSalesmen();
  }

  Future<void> _fetchLinkedSalesmen() async {
    setState(() => _isLoading = true);
    List<String> list = await _shareService.getLinkedSalesmen();
    if (mounted) {
      setState(() {
        _linkedSalesmen = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _showLinkDialog() async {
    _codeController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter 6-Digit Code'),
        content: TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: 'e.g. 543210',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              String code = _codeController.text.trim();
              if (code.length != 6) return;
              Navigator.pop(ctx);
              String? err = await _shareService.linkWithCode(code);
              if (err != null) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(err)));
                }
              } else {
                await _fetchLinkedSalesmen();
              }
            },
            child: const Text('Link'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_link),
            tooltip: 'Link Salesman',
            onPressed: _showLinkDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _linkedSalesmen.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.group_off_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No salesmen linked yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _showLinkDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Enter Salesman Code'),
                    ),
                  ],
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('visits')
                  .where('userId', whereIn: _linkedSalesmen)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No logged visits from linked salesmen.'),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(data['clientName'] ?? 'Unnamed Client'),
                        subtitle: Text(
                          '${data['notes'] ?? ''}\nLocation: ${data['latitude'] ?? '-'}, ${data['longitude'] ?? '-'}',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
