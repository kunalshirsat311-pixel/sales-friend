import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class ShareAccessScreen extends StatefulWidget {
  const ShareAccessScreen({super.key});

  @override
  State<ShareAccessScreen> createState() => _ShareAccessScreenState();
}

class _ShareAccessScreenState extends State<ShareAccessScreen> {
  String? _shareCode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingCode();
  }

  Future<void> _loadExistingCode() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('salesmen')
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data()?['shareCode'] != null) {
      setState(() {
        _shareCode = doc.data()?['shareCode'];
      });
    }
  }

  Future<void> _generateCode() async {
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final code = (100000 + Random().nextInt(900000)).toString();

    await FirebaseFirestore.instance.collection('salesmen').doc(user.uid).set({
      'shareCode': code,
      'name': user.displayName ?? 'Salesman',
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() {
      _shareCode = code;
      _isLoading = false;
    });
  }

  Future<void> _revokeCode() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('salesmen')
        .doc(user.uid)
        .update({'shareCode': FieldValue.delete()});

    setState(() => _shareCode = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share with Manager'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Give your manager a 6-digit code to view your visits in real time.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 32),
            if (_shareCode != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple, width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Share Code',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _shareCode!,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        letterSpacing: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _revokeCode,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Revoke Access'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generateCode,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isLoading ? 'Generating...' : 'Generate Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
            const Spacer(),
            const Text(
              'Tip: Share this code verbally or via WhatsApp. Your manager enters it once and sees all your visits instantly.',
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
