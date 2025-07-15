import 'package:flutter/material.dart';
import 'package:konfirmasi_wilkerstat/model/version.dart';

class VersionUpdateDialog extends StatelessWidget {
  final Version version;
  final VoidCallback onUpdate;

  const VersionUpdateDialog({
    super.key,
    required this.version,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  version.isMandatory
                      ? Colors.orange.withValues(alpha: 0.1)
                      : const Color(0xFF667eea).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              version.isMandatory ? Icons.priority_high : Icons.system_update,
              color:
                  version.isMandatory
                      ? Colors.orange[700]
                      : const Color(0xFF667eea),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              version.isMandatory ? 'Pembaruan Wajib' : 'Pembaruan Tersedia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    version.isMandatory
                        ? Colors.orange[800]
                        : const Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (version.title.isNotEmpty) ...[
            Text(
              version.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
          ],

          if (version.versionName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Versi ${version.versionName}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (version.description != null &&
              version.description!.isNotEmpty) ...[
            const Text(
              'Apa yang baru:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                version.description!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4A5568),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (version.isMandatory) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pembaruan ini wajib untuk melanjutkan penggunaan aplikasi.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!version.isMandatory)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Nanti Saja',
              style: TextStyle(
                color: Color(0xFF718096),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ElevatedButton.icon(
          onPressed: () {
            onUpdate();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                version.isMandatory
                    ? Colors.orange[600]
                    : const Color(0xFF667eea),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.download, size: 16),
          label: Text(
            version.isMandatory ? 'Perbarui Sekarang' : 'Perbarui',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
