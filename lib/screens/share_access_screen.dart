import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/share_service.dart';

class ShareAccessScreen extends StatefulWidget {
  const ShareAccessScreen({super.key});

  @override
  State<ShareAccessScreen> createState() => _ShareAccessScreenState();
}

class _ShareAccessScreenState extends State<ShareAccessScreen> {
  final ShareService _shareService = ShareService();
  String? _shareCode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrCreateCode();
  }

  Future<void> _loadOrCreateCode() async {
    setState(() => _isLoading = true);
    try {
      String? existing = await _shareService.getExistingCode();
      if (existing != null) {
        setState(() => _shareCode = existing);
      } else {
        String newCode = await _shareService.generateShareCode();
        setState(() => _shareCode = newCode);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load code: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard() {
    if (_shareCode == null) return;
    Clipboard.setData(ClipboardData(text: _shareCode!));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Code copied to clipboard!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Manager Access')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.share_outlined,
                      size: 72,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your 6-Digit Share Code',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Share this code with your manager so they can view your visit logs in real time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        _shareCode ?? '------',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Code'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
