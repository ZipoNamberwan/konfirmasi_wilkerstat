import 'package:flutter/material.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessItemWidget extends StatelessWidget {
  final Business business;
  final Function(Business, BusinessStatus) onStatusChanged;
  final bool isLocked;
  final Function(Object) onError;

  const BusinessItemWidget({
    super.key,
    required this.business,
    required this.onStatusChanged,
    this.isLocked = false,
    required this.onError,
  });

  void _openGoogleMaps(Business business) async {
    final lat = business.latitude;
    final lng = business.longitude;
    final url = 'https://www.google.com/maps?q=$lat,$lng';
    // final url =
    //     'https://www.google.com/maps/search/?api=1&query=${business.latitude},${business.longitude}';

    // Use url_launcher to open the URL
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      onError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Name and ID
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    business.name,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                // Status indicator
                InkWell(
                  onTap:
                      () =>
                          ((business.latitude != '0') &&
                                  (business.longitude != '0'))
                              ? _openGoogleMaps(business)
                              : null,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        margin: const EdgeInsets.only(right: 4, left: 4),
                        decoration: BoxDecoration(
                          color:
                              isLocked
                                  ? Colors.grey[200]
                                  : business.status?.color.withValues(
                                    alpha: 0.1,
                                  ),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color:
                                isLocked
                                    ? Colors.grey[400]!
                                    : (business.status?.color.withValues(
                                          alpha: 0.3,
                                        ) ??
                                        Colors.grey[600]!),
                          ),
                        ),
                        child: Text(
                          business.status?.text ??
                              BusinessStatus.notConfirmed.text,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color:
                                isLocked
                                    ? Colors.grey[600]!
                                    : (business.status?.color ??
                                        Colors.grey[600]!),
                          ),
                        ),
                      ),
                      if ((business.latitude != '0') &&
                          (business.longitude != '0'))
                        Icon(
                          Icons.open_in_new,
                          size: 16,
                          color:
                              isLocked ? Colors.grey[600] : Color(0xFF667eea),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Business details
            if (business.owner != null) ...[
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Pemilik: ${business.owner}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],

            // Business Address
            if (business.address != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      business.address!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],

            const SizedBox(height: 10),

            // Toggle Button (more compact)
            Container(
              width: double.infinity,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isLocked ? Colors.grey[200]! : Colors.grey[300]!,
                ),
                color: isLocked ? Colors.grey[100] : Colors.grey[50],
              ),
              child: Stack(
                children: [
                  // Background for selected side
                  // Show bar only for confirmed statuses (found or notFound)
                  // No bar for notConfirmed (null status)
                  if (business.status == BusinessStatus.found ||
                      business.status == BusinessStatus.notFound)
                    Align(
                      // duration: const Duration(milliseconds: 200),
                      // curve: Curves.easeInOut,
                      alignment:
                          business.status == BusinessStatus.found
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 30,
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color:
                              isLocked
                                  ? Colors.grey[400]
                                  : (business.status == BusinessStatus.found
                                      ? Colors.green[600]
                                      : Colors.red[600]),
                          boxShadow:
                              isLocked
                                  ? []
                                  : [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                        ),
                      ),
                    ),

                  // Buttons
                  Row(
                    children: [
                      // Yes Button (Found)
                      Expanded(
                        child: GestureDetector(
                          onTap:
                              isLocked
                                  ? null
                                  : () => onStatusChanged(
                                    business,
                                    BusinessStatus.found,
                                  ),
                          child: Container(
                            height: 36,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                                bottomLeft: Radius.circular(18),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Ada',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isLocked
                                          ? (business.status ==
                                                  BusinessStatus.found
                                              ? Colors.white70
                                              : Colors.grey[500])
                                          : (business.status ==
                                                  BusinessStatus.found
                                              ? Colors.white
                                              : Colors.grey[700]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // No Button (Not Found)
                      Expanded(
                        child: GestureDetector(
                          onTap:
                              isLocked
                                  ? null
                                  : () => onStatusChanged(
                                    business,
                                    BusinessStatus.notFound,
                                  ),
                          child: Container(
                            height: 36,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(18),
                                bottomRight: Radius.circular(18),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Tidak Ada',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isLocked
                                          ? (business.status ==
                                                  BusinessStatus.notFound
                                              ? Colors.white70
                                              : Colors.grey[500])
                                          : (business.status ==
                                                  BusinessStatus.notFound
                                              ? Colors.white
                                              : Colors.grey[700]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
