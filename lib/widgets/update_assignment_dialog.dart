import 'package:flutter/material.dart';

class UpdateAssignmentDialog extends StatelessWidget {
  final VoidCallback onUpdate;
  final VoidCallback? onCancel;
  final List<String> localAssignments;
  final List<String> serverAssignments;

  const UpdateAssignmentDialog({
    super.key,
    required this.onUpdate,
    this.onCancel,
    required this.localAssignments,
    required this.serverAssignments,
  });

  static void show({
    required BuildContext context,
    required VoidCallback onUpdate,
    VoidCallback? onCancel,
    required List<String> localAssignments,
    required List<String> serverAssignments,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateAssignmentDialog(
        onUpdate: onUpdate,
        onCancel: onCancel,
        localAssignments: localAssignments,
        serverAssignments: serverAssignments,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.system_update,
                size: 32,
                color: Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Perbedaan Assignment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Terdapat perbedaan pada assignment yang tersedia di penyimpanan local dan di server. Silakan lakukan sinkronisasi untuk mendapatkan data terbaru.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Cancel Button (if onCancel is provided)
                if (onCancel != null) ...[
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onCancel?.call();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        'Nanti',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Update Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onUpdate();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text(
                      'Sinkronisasi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
