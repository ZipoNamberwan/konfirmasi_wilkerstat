import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_state.dart';

class PrerequisitesPopup extends StatelessWidget {
  final Function() onFilterNotConfirmed;
  final VoidCallback onGetLocation;
  final VoidCallback onSendData;

  const PrerequisitesPopup({
    super.key,
    required this.onFilterNotConfirmed,
    required this.onGetLocation,
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
                              (!state.data.isSecondStepNeeded() ||
                                  state.data.isSecondStepDone())
                          ? Colors.green
                          : Colors.orange)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  state.data.isFirstStepDone() &&
                          (!state.data.isSecondStepNeeded() ||
                              state.data.isSecondStepDone())
                      ? Icons.send
                      : Icons.list_alt,
                  color:
                      state.data.isFirstStepDone() &&
                              (!state.data.isSecondStepNeeded() ||
                                  state.data.isSecondStepDone())
                          ? Colors.green[600]
                          : Colors.orange[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.data.isFirstStepDone() &&
                          (!state.data.isSecondStepNeeded() ||
                              state.data.isSecondStepDone())
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
                state.data.isFirstStepDone() &&
                        (!state.data.isSecondStepNeeded() ||
                            state.data.isSecondStepDone())
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
                onTap:
                    state.data.isFirstStepDone()
                        ? null
                        : () {
                          Navigator.pop(context);
                          onFilterNotConfirmed();
                        },
              ),
              // Only show second step if needed
              if (state.data.isSecondStepNeeded()) ...[
                const SizedBox(height: 12),
                _buildPrerequisiteRow(
                  icon: Icons.location_on,
                  title: 'Ambil Lokasi Konfirmasi',
                  isCompleted: state.data.isSecondStepDone(),
                  description:
                      state.data.isSecondStepDone()
                          ? 'Lokasi konfirmasi sudah diambil'
                          : 'Ambil lokasi Konfirmasi sebagai bukti verifikasi. Contoh, bisa di rumah ketua SLS atau lokasi lain yang relevan',
                  onTap:
                      state.data.isSecondStepDone()
                          ? null
                          : () {
                            // Navigator.pop(context);
                            onGetLocation();
                          },
                  locationText:
                      state.data.sls.slsChiefLocation != null
                          ? 'Lokasi: ${state.data.sls.slsChiefLocation!.latitude.toStringAsFixed(6)}, ${state.data.sls.slsChiefLocation!.longitude.toStringAsFixed(6)}'
                          : null,
                  onRetakeLocation:
                      state.data.sls.slsChiefLocation != null
                          ? () {
                            // Navigator.pop(context);
                            onGetLocation();
                          }
                          : null,
                ),
              ],
            ],
          ),
          actions: [
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
            if (state.data.isFirstStepDone() &&
                (!state.data.isSecondStepNeeded() ||
                    state.data.isSecondStepDone())) ...[
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
    VoidCallback? onTap,
    String? locationText,
    VoidCallback? onRetakeLocation,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Row(
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
                          isCompleted
                              ? Colors.green[700]
                              : const Color(0xFF2D3748),
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
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
                  if (locationText != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            locationText,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        if (onRetakeLocation != null) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onRetakeLocation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.blue[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    size: 12,
                                    color: Colors.blue[600],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Ambil Ulang',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ],
        ),
      ),
    );
  }
}
