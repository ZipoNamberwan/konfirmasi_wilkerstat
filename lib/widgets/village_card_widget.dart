import 'package:flutter/material.dart';
import 'package:konfirmasi_wilkerstat/model/upload.dart';
import 'package:konfirmasi_wilkerstat/model/village.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';
import 'sls_item_widget.dart';

class VillageCardWidget extends StatelessWidget {
  final Village village;
  final List<Sls> villageSlsList;
  final Function(Village) onVillageDownload;
  final Function(Sls) onSlsDownload;
  final Function(Sls)? onSlsClick;
  final Map<String, SlsUpload?> latestSlsUploads;

  const VillageCardWidget({
    super.key,
    required this.village,
    required this.villageSlsList,
    required this.onVillageDownload,
    required this.onSlsDownload,
    this.onSlsClick,
    required this.latestSlsUploads,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = true;

    // Check SLS download status
    final downloadedSlsCount =
        villageSlsList.where((sls) => sls.hasDownloaded).length;
    final totalSlsCount = villageSlsList.length;
    final hasAnyDownloadedSls = downloadedSlsCount > 0;
    final hasAllSlsDownloaded =
        downloadedSlsCount == totalSlsCount && totalSlsCount > 0;
    final hasNoSlsDownloaded = downloadedSlsCount == 0;

    // Determine village display state
    final showDownloadButton =
        hasNoSlsDownloaded; // Only show when no SLS are downloaded (rule 2)
    final villageShowsAsDownloaded =
        hasAnyDownloadedSls; // Show as downloaded if any SLS is downloaded (rule 3)

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Village Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF667eea).withValues(alpha: 0.1),
                    const Color(0xFF764ba2).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    villageShowsAsDownloaded
                        ? Icons.location_city
                        : Icons.cloud_download,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        village.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    if (!villageShowsAsDownloaded) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.download_outlined,
                              size: 12,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Belum Diunduh',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (!hasAllSlsDownloaded) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_download,
                              size: 12,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$downloadedSlsCount/$totalSlsCount',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  '${village.id} • ${villageSlsList.length} SLS',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ),

            // Download Button Section - Only show when no SLS are downloaded (rule 2)
            if (showDownloadButton) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    onVillageDownload(village);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text(
                    'Unduh Prelist',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],

            // SLS List (Always show, with individual download status styling)
            if (isExpanded && villageSlsList.isNotEmpty) ...[
              const SizedBox(height: 6),
              ...villageSlsList.map((sls) {
                return SlsItemWidget(
                  sls: sls,
                  onSlsDownload: hasAnyDownloadedSls ? onSlsDownload : (sls) {},
                  onSlsClick: onSlsClick,
                  lastSentAt: latestSlsUploads[sls.id]?.createdAt,
                );
              }),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}
