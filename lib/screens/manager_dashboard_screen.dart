import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'visit_detail_screen.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  final _codeController = TextEditingController();
  final List<String> _linkedSalesmenIds = [];
  final Map<String, Map<String, dynamic>> _salesmenInfo = {};
  bool _isLoading = false;
  String? _error;

  Future<void> _linkSalesman() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Enter a valid 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection('salesmen')
          .where('shareCode', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() {
          _error = 'No salesman found with that code';
          _isLoading = false;
        });
        return;
      }

      final salesmanDoc = query.docs.first;
      final salesmanId = salesmanDoc.id;

      if (_linkedSalesmenIds.contains(salesmanId)) {
        setState(() {
          _error = 'Already linked to this salesman';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _linkedSalesmenIds.add(salesmanId);
        _salesmenInfo[salesmanId] = {
          'name': salesmanDoc.data()['name'] ?? 'Unknown',
          'code': code,
        };
        _codeController.clear();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager View'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Code input section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Enter 6-digit share code',
                    border: const OutlineInputBorder(),
                    errorText: _error,
                    suffixIcon: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.add_link),
                            onPressed: _linkSalesman,
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Linked salesmen chips
          if (_linkedSalesmenIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: _linkedSalesmenIds.map((id) {
                  final info = _salesmenInfo[id]!;
                  return Chip(
                    label: Text(info['name']!),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _linkedSalesmenIds.remove(id);
                        _salesmenInfo.remove(id);
                      });
                    },
                    backgroundColor: Colors.deepPurple.shade100,
                  );
                }).toList(),
              ),
            ),

          const Divider(),

          // Visits feed
          Expanded(
            child: _linkedSalesmenIds.isEmpty
                ? const Center(
                    child: Text(
                      'Enter a share code to see visits',
                      style: TextStyle(color: Colors.black45),
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('visits')
                        .where('userId', whereIn: _linkedSalesmenIds)
                        .orderBy('visitTime', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final visits = snapshot.data!.docs;

                      if (visits.isEmpty) {
                        return const Center(child: Text('No visits found yet'));
                      }

                      return ListView.builder(
                        itemCount: visits.length,
                        itemBuilder: (context, index) {
                          final visit =
                              visits[index].data() as Map<String, dynamic>;
                          final visitTime = (visit['visitTime'] as Timestamp)
                              .toDate();
                          final salesmanName =
                              _salesmenInfo[visit['userId']]?['name'] ??
                              'Unknown';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: ListTile(
                              leading: visit['photoUrl'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        visit['photoUrl'],
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.store),
                                    ),
                              title: Text(visit['clientName'] ?? 'Unknown'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(visit['location'] ?? ''),
                                  Text(
                                    '$salesmanName • ${DateFormat('dd MMM, hh:mm a').format(visitTime)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        VisitDetailScreen(visit: visits[index]),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
