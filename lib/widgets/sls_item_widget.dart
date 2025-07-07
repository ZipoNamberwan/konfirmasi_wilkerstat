import 'package:flutter/material.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';

class SlsItemWidget extends StatelessWidget {
  final Sls sls;
  final Function(Sls) onSlsDownload;

  const SlsItemWidget({
    super.key,
    required this.sls,
    required this.onSlsDownload,
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
                  ? null
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
          title: Text(
            sls.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color:
                  slsIsDownloaded ? const Color(0xFF2D3748) : Colors.grey[600],
            ),
          ),
          subtitle: Text(
            sls.code,
            style: TextStyle(
              color: slsIsDownloaded ? Colors.grey[600] : Colors.grey[500],
              fontSize: 12,
            ),
          ),
          trailing:
              !slsIsDownloaded
                  ? Icon(Icons.lock_outline, color: Colors.grey[500], size: 16)
                  : null,
        ),
      ),
    );
  }
}
