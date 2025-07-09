import 'package:flutter/material.dart';

class CameraDialog extends StatelessWidget {
  final VoidCallback onTakePicture;

  const CameraDialog({super.key, required this.onTakePicture});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Color(0xFF667eea),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Ambil Foto Dokumentasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ambil foto untuk dokumentasi proses konfirmasi usaha.',
            style: TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
          ),
          SizedBox(height: 12),
          Text(
            'Tips untuk foto yang baik:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• Pastikan pencahayaan cukup\n• Foto area yang representatif\n• Hindari foto yang buram',
            style: TextStyle(fontSize: 13, color: Color(0xFF4A5568)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Batal',
            style: TextStyle(
              color: Color(0xFF718096),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onTakePicture();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.camera_alt, size: 16),
          label: const Text(
            'Buka Kamera',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
