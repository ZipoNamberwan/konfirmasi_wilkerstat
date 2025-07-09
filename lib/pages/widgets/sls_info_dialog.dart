import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_state.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';

class SlsInfoDialog extends StatelessWidget {
  const SlsInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdatingBloc, UpdatingState>(
      builder: (context, state) {
        // Calculate totals based on BusinessStatus keys
        final totalBusinesses = state.data.businesses.length;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667eea).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF667eea),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Informasi SLS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Area Information Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildCleanInfoRow(
                        icon: Icons.apartment,
                        label: 'SLS',
                        value: state.data.sls?.name ?? '',
                      ),
                      const SizedBox(height: 12),
                      _buildCleanInfoRow(
                        icon: Icons.location_city,
                        label: 'Desa/Kelurahan',
                        value: state.data.sls?.village.name ?? '',
                      ),
                      const SizedBox(height: 12),
                      _buildCleanInfoRow(
                        icon: Icons.qr_code,
                        label: 'Kode SLS',
                        value: state.data.sls?.code ?? '',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Business Summary
                const Text(
                  'Ringkasan Usaha',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),

                // Statistics Rows
                _buildStatRow(
                  icon: Icons.business,
                  label: 'Total Usaha',
                  value: totalBusinesses.toString(),
                  color: Colors.blue,
                ),
                const SizedBox(height: 6),

                // Business status rows in desired order: found, notFound, notConfirmed
                ..._getOrderedStatusRows(state.data.summary),

                const SizedBox(height: 16),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCleanInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF667eea)),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A5568),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3748),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getOrderedStatusRows(Map<int, int> businessSummary) {
    // Use BusinessStatus.values directly for consistent ordering: found, notFound, notConfirmed
    return BusinessStatus.values.map<Widget>((status) {
      int count = businessSummary[status.key] ?? 0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: _buildStatRow(
          icon: _getIconForStatus(status),
          label: status.text, // Use the status.text from BusinessStatus
          value: count.toString(),
          color: status.color, // Use the status.color from BusinessStatus
        ),
      );
    }).toList();
  }

  IconData _getIconForStatus(BusinessStatus status) {
    if (status == BusinessStatus.found) {
      return Icons.visibility;
    } else if (status == BusinessStatus.notFound) {
      return Icons.visibility_off;
    } else if (status == BusinessStatus.notConfirmed) {
      return Icons.help_outline;
    }
    return Icons.help_outline;
  }
}
