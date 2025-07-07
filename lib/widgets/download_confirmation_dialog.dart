import 'package:flutter/material.dart';

class DownloadConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String itemName;
  final String itemType; // 'village' or 'sls'
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const DownloadConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.itemName,
    required this.itemType,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              itemType == 'village' ? Icons.location_city : Icons.map_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF667eea).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  itemType == 'village'
                      ? Icons.location_city_outlined
                      : Icons.map_outlined,
                  color: const Color(0xFF667eea),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Data akan diunduh dan disimpan secara lokal.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Batal',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.download, size: 16),
          label: const Text(
            'Unduh',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  /// Show village download confirmation dialog
  static Future<void> showVillageDownload({
    required BuildContext context,
    required String villageName,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DownloadConfirmationDialog(
          title: 'Unduh Seluruh Prelist',
          message:
              'Apakah Anda yakin ingin mengunduh prelist untuk seluruh SLS di Desa ini?',
          itemName: villageName,
          itemType: 'village',
          onConfirm: onConfirm,
          onCancel: onCancel,
        );
      },
    );
  }

  /// Show SLS download confirmation dialog
  static Future<void> showSlsDownload({
    required BuildContext context,
    required String slsName,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DownloadConfirmationDialog(
          title: 'Unduh Prelist SLS',
          message:
              'Prelist SLS ini belum diunduh. Apakah Anda ingin mengunduh prelist untuk SLS ini?',
          itemName: slsName,
          itemType: 'sls',
          onConfirm: onConfirm,
          onCancel: onCancel,
        );
      },
    );
  }
}
