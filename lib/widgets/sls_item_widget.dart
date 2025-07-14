import 'package:flutter/material.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';

class SlsItemWidget extends StatelessWidget {
  final Sls sls;
  final Function(Sls) onSlsDownload;
  final Function(Sls)? onSlsClick;
  final DateTime? lastSentAt;

  const SlsItemWidget({
    super.key,
    required this.sls,
    required this.onSlsDownload,
    this.onSlsClick,
    this.lastSentAt,
  });

  @override
  Widget build(BuildContext context) {
    final slsIsDownloaded = sls.hasDownloaded;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: slsIsDownloaded ? Colors.grey[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: slsIsDownloaded ? Colors.grey[200]! : Colors.grey[300]!,
        ),
      ),
      child: Opacity(
        opacity: slsIsDownloaded ? 1.0 : 0.6,
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 4.0,
          ),
          onTap:
              slsIsDownloaded
                  ? () {
                    if (onSlsClick != null) {
                      onSlsClick!(sls);
                    }
                  }
                  : () {
                    onSlsDownload(sls);
                  },
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  slsIsDownloaded
                      ? const Color(0xFF667eea).withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.map_outlined,
              color:
                  slsIsDownloaded ? const Color(0xFF667eea) : Colors.grey[600],
              size: 16,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  sls.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color:
                        slsIsDownloaded
                            ? const Color(0xFF2D3748)
                            : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sls.code,
                style: TextStyle(
                  color: slsIsDownloaded ? Colors.grey[600] : Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              if (slsIsDownloaded) ...[
                const SizedBox(height: 2),
                Text(
                  lastSentAt != null
                      ? _formatDate(lastSentAt!)
                      : 'Belum dikirim',
                  style: TextStyle(
                    color:
                        lastSentAt != null
                            ? Colors.green[600]
                            : Colors.orange[600],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          trailing:
              !slsIsDownloaded
                  ? Icon(Icons.lock_outline, color: Colors.grey[500], size: 16)
                  : Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[600],
                    size: 14,
                  ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    String dateStr;
    if (difference.inDays == 0) {
      // Today - show time
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      dateStr = 'hari ini $hour:$minute';
    } else if (difference.inDays == 1) {
      // Yesterday
      dateStr = 'kemarin';
    } else if (difference.inDays < 7) {
      // This week
      dateStr = '${difference.inDays} hari lalu';
    } else {
      // Older than a week - show date
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      dateStr = '$day/$month/$year';
    }

    return 'Dikirim pada: $dateStr';
  }
}
