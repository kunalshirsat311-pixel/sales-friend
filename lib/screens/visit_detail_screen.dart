import 'package:flutter/material.dart';
import '../models/visit_model.dart';

class VisitDetailScreen extends StatelessWidget {
  final VisitModel visit;

  const VisitDetailScreen({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade600,
        elevation: 0,
        title: Text(
          visit.clientName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo Section ──
            if (visit.photoUrl != null)
              Stack(
                children: [
                  Image.network(
                    visit.photoUrl!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 250,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                  // Location stamp on photo
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      color: Colors.black.withOpacity(0.6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              visit.locationAddress,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                height: 160,
                color: Colors.indigo.shade50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: Colors.indigo.shade200,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No photo added',
                      style: TextStyle(
                        color: Colors.indigo.shade300,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Client Name ──
                  _buildSectionCard(
                    icon: Icons.business_outlined,
                    label: 'Client',
                    content: visit.clientName,
                  ),

                  const SizedBox(height: 12),

                  // ── Visit Time ──
                  _buildSectionCard(
                    icon: Icons.access_time,
                    label: 'Visit Time',
                    content: _formatDateTime(visit.visitTime),
                  ),

                  const SizedBox(height: 12),

                  // ── Location ──
                  _buildSectionCard(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    content: visit.locationAddress,
                  ),

                  const SizedBox(height: 12),

                  // ── Notes ──
                  if (visit.notes.isNotEmpty)
                    _buildSectionCard(
                      icon: Icons.notes_outlined,
                      label: 'Visit Notes',
                      content: visit.notes,
                    ),

                  if (visit.notes.isEmpty)
                    _buildSectionCard(
                      icon: Icons.notes_outlined,
                      label: 'Visit Notes',
                      content: 'No notes added for this visit.',
                      muted: true,
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HELPER WIDGETS ──────────────────────────────────────────

  Widget _buildSectionCard({
    required IconData icon,
    required String label,
    required String content,
    bool muted = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.indigo.shade400, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: muted ? Colors.grey.shade400 : Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    String period = dt.hour >= 12 ? 'PM' : 'AM';
    int hour = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
        ? 12
        : dt.hour;
    String minute = dt.minute.toString().padLeft(2, '0');
    String day = dt.day.toString();
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '$day ${months[dt.month - 1]} ${dt.year} at $hour:$minute $period';
  }
}
