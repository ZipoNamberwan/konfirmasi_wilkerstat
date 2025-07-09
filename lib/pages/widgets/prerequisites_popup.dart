import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_state.dart';

class PrerequisitesPopup extends StatelessWidget {
  final Function() onFilterNotConfirmed;
  final VoidCallback onShowCamera;
  final VoidCallback onSendData;

  const PrerequisitesPopup({
    super.key,
    required this.onFilterNotConfirmed,
    required this.onShowCamera,
    required this.onSendData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdatingBloc, UpdatingState>(
      builder: (context, state) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (state.data.isFirstStepDone() &&
                              state.data.isSecondStepDone()
                          ? Colors.green
                          : Colors.orange)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  state.data.isFirstStepDone() && state.data.isSecondStepDone()
                      ? Icons.check_circle
                      : Icons.list_alt,
                  color:
                      state.data.isFirstStepDone() &&
                              state.data.isSecondStepDone()
                          ? Colors.green[600]
                          : Colors.orange[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.data.isFirstStepDone() && state.data.isSecondStepDone()
                      ? 'Siap untuk Dikirim!'
                      : 'Langkah yang Diperlukan',
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
            children: [
              Text(
                state.data.isFirstStepDone() && state.data.isSecondStepDone()
                    ? 'Semua persyaratan sudah terpenuhi. Data siap untuk dikirim ke server.'
                    : 'Selesaikan langkah-langkah berikut sebelum mengirim data:',
                style: const TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
              ),
              const SizedBox(height: 16),
              _buildPrerequisiteRow(
                icon: Icons.assignment_turned_in,
                title: 'Konfirmasi Status Usaha',
                isCompleted: state.data.isFirstStepDone(),
                description:
                    state.data.isFirstStepDone()
                        ? 'Semua usaha telah dikonfirmasi'
                        : '${state.data.getNotconfirmedCount()} dari ${state.data.businesses.length} usaha belum dikonfirmasi',
              ),
              const SizedBox(height: 12),
              _buildPrerequisiteRow(
                icon: Icons.camera_alt,
                title: 'Upload Foto Dokumentasi',
                isCompleted: state.data.isSecondStepDone(),
                description:
                    state.data.isSecondStepDone()
                        ? 'Foto dokumentasi sudah diupload'
                        : 'Ambil foto untuk dokumentasi proses',
              ),
            ],
          ),
          actions: [
            if (!state.data.isFirstStepDone()) ...[
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onFilterNotConfirmed();
                },
                icon: const Icon(Icons.assignment_turned_in, size: 16),
                label: const Text(
                  'Konfirmasi Usaha',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
            if (state.data.isFirstStepDone() &&
                !state.data.isSecondStepDone()) ...[
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onShowCamera();
                },
                icon: const Icon(Icons.camera_alt, size: 16),
                label: const Text(
                  'Ambil Foto',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
            if (state.data.isFirstStepDone() &&
                state.data.isSecondStepDone()) ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onSendData();
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
                  'Kirim Data',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPrerequisiteRow({
    required IconData icon,
    required String title,
    required bool isCompleted,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            size: 18,
            color: isCompleted ? Colors.green[600] : Colors.grey[600],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      isCompleted ? Colors.green[700] : const Color(0xFF2D3748),
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted ? Colors.green[600] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
