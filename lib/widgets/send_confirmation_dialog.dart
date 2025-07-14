import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_state.dart';

class SendConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const SendConfirmationDialog({
    super.key,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdatingBloc, UpdatingState>(
      listener: (context, state) {
        if (state is SendDataFailed || state is SendDataSuccess) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isSending = state.data.isSendingToServer;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    isSending
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF667eea),
                            ),
                          ),
                        )
                        : const Icon(
                          Icons.cloud_upload_outlined,
                          color: Color(0xFF667eea),
                          size: 20,
                        ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isSending ? 'Mengirim Data...' : 'Kirim Data ke Server',
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
              if (isSending) ...[
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF667eea),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.data.sendingMessage ??
                            'Sedang mengirim data ke server...',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A5568),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const Text(
                  'Apakah Anda yakin ingin mengirim semua data konfirmasi usaha ke server?',
                  style: TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Data yang akan dikirim:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Status konfirmasi semua usaha\n• Informasi SLS\n• Data petugas',
                  style: TextStyle(fontSize: 13, color: Color(0xFF4A5568)),
                ),
              ],
            ],
          ),
          actions: [
            if (!isSending)
              TextButton(
                onPressed: onCancel ?? () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ElevatedButton.icon(
              onPressed:
                  isSending
                      ? null
                      : () {
                        onConfirm();
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.send, size: 16),
              label: const Text(
                'Kirim',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
