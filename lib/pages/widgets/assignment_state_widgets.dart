import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_event.dart';

class NoAssignmentWidget extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const NoAssignmentWidget({
    super.key,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon based on state
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(
                            color: Color(0xFF667eea),
                            strokeWidth: 4,
                          )
                          : Icon(_getIcon(), size: 40, color: _getIconColor()),
                ),
                const SizedBox(height: 24),

                // Title based on state
                Text(
                  _getTitle(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Message based on state
                Text(
                  _getMessage(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Hint/Error container based on state
                _buildInfoContainer(),
                const SizedBox(height: 24),

                // Action button
                if (!isLoading) _buildActionButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getIconBackgroundColor() {
    if (errorMessage != null) return Colors.red;
    return const Color(0xFF667eea);
  }

  IconData _getIcon() {
    if (errorMessage != null) return Icons.error_outline;
    return Icons.assignment_outlined;
  }

  Color _getIconColor() {
    if (errorMessage != null) return Colors.red;
    return const Color(0xFF667eea);
  }

  String _getTitle() {
    if (isLoading) return 'Mengunduh Assignment...';
    if (errorMessage != null) return 'Gagal Mengunduh Assignment';
    return 'Tidak Ada Assignment';
  }

  String _getMessage() {
    if (isLoading) return 'Harap tunggu sebentar';
    if (errorMessage != null) return errorMessage!;
    return 'Belum ada desa dan SLS yang ditugaskan untuk Anda.';
  }

  Widget _buildInfoContainer() {
    if (isLoading) return const SizedBox.shrink();

    Color containerColor;
    Color borderColor;
    Color iconColor;
    Color textColor;
    IconData icon;
    String text;

    if (errorMessage != null) {
      containerColor = Colors.red[50]!;
      borderColor = Colors.red[200]!;
      iconColor = Colors.red[600]!;
      textColor = Colors.red[700]!;
      icon = Icons.warning_amber_outlined;
      text = 'Pastikan Anda terhubung ke internet dan coba lagi.';
    } else {
      containerColor = Colors.blue[50]!;
      borderColor = Colors.blue[200]!;
      iconColor = Colors.blue[600]!;
      textColor = Colors.blue[700]!;
      icon = Icons.info_outline;
      text =
          'Hubungi Admin Kabupaten untuk mendapatkan penugasan wilayah kerja.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: textColor, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          if (onRetry != null) {
            onRetry!();
          } else {
            context.read<ProjectBloc>().add(const DownloadAssignments());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              errorMessage != null ? Colors.red : const Color(0xFF667eea),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.refresh, size: 20),
        label: Text(
          errorMessage != null ? 'Coba Lagi' : 'Unduh Assignment',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
