import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_state.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';
import 'package:konfirmasi_wilkerstat/pages/widgets/business_item_widget.dart';
import 'package:konfirmasi_wilkerstat/pages/widgets/sls_info_dialog.dart';
import 'package:konfirmasi_wilkerstat/pages/widgets/prerequisites_popup.dart';
import 'package:konfirmasi_wilkerstat/pages/widgets/camera_dialog.dart';

class UpdatingPage extends StatefulWidget {
  final Sls selectedSls;

  const UpdatingPage({super.key, required this.selectedSls});

  @override
  State<UpdatingPage> createState() => _UpdatingPageState();
}

class _UpdatingPageState extends State<UpdatingPage> {
  late final UpdatingBloc _updatingProvider;

  @override
  void initState() {
    super.initState();
    _updatingProvider =
        context.read<UpdatingBloc>()..add(Init(slsId: widget.selectedSls.id));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdatingBloc, UpdatingState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.selectedSls.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.selectedSls.village.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF667eea),
            elevation: 0,
            centerTitle: false,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              _buildStatusButton(
                state.data.isFirstStepDone(),
                state.data.isSecondStepDone(),
                state.data.isSecondStepNeeded(),
              ),
              IconButton(
                onPressed: () => _showSlsInfo(),
                icon: const Icon(Icons.info_outline, color: Colors.white),
                tooltip: 'Informasi SLS',
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF667eea), Color(0xFFF8F9FA)],
                stops: [0.0, 0.3],
              ),
            ),
            child: Column(
              children: [
                // Compact Search and Filter Section
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      // Search Bar (more compact)
                      SizedBox(
                        height: 40,
                        child: TextField(
                          onChanged: (value) {
                            _updatingProvider.add(
                              FilterByKeyword(keyword: value),
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari usaha...',
                            hintStyle: const TextStyle(fontSize: 14),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF718096),
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF667eea),
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF7FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Compact Status Filter
                      Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildCompactFilterChip(
                                    label: 'Semua',
                                    isSelected:
                                        state.data.selectedStatusFilter == null,
                                    onTap: () {
                                      _updatingProvider.add(
                                        FilterByStatus(status: null),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _buildCompactFilterChip(
                                    label: 'Ada',
                                    isSelected:
                                        state.data.selectedStatusFilter ==
                                        BusinessStatus.found,
                                    onTap: () {
                                      _updatingProvider.add(
                                        FilterByStatus(
                                          status: BusinessStatus.found,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _buildCompactFilterChip(
                                    label: 'Tidak Ada',
                                    isSelected:
                                        state.data.selectedStatusFilter ==
                                        BusinessStatus.notFound,
                                    onTap: () {
                                      _updatingProvider.add(
                                        FilterByStatus(
                                          status: BusinessStatus.notFound,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _buildCompactFilterChip(
                                    label: 'Belum Konfirmasi',
                                    isSelected:
                                        state.data.selectedStatusFilter ==
                                        BusinessStatus.notConfirmed,
                                    onTap: () {
                                      _updatingProvider.add(
                                        FilterByStatus(
                                          status: BusinessStatus.notConfirmed,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Clear filter button
                          if (state.data.selectedStatusFilter != null ||
                              state.data.keywordFilter != null)
                            GestureDetector(
                              onTap: () {
                                _updatingProvider.add(ClearFilters());
                              },
                              child: Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.clear,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          const SizedBox(width: 6),
                          // Sort button
                          GestureDetector(
                            onTap: () {
                              _showSortOptions(context, state.data.sortBy);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Stack(
                                children: [
                                  Icon(
                                    Icons.sort,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Business List (more compact)
                Expanded(
                  child:
                      state.data.filteredBusinesses.isEmpty
                          ? _buildEmptyState(
                            state.data.keywordFilter,
                            state.data.selectedStatusFilter,
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                            itemCount: state.data.filteredBusinesses.length,
                            itemBuilder: (context, index) {
                              final business =
                                  state.data.filteredBusinesses[index];
                              return BusinessItemWidget(
                                business: business,
                                onStatusChanged: (bsn, status) {
                                  _updatingProvider.add(
                                    UpdateBusinessStatus(
                                      business: bsn,
                                      status: status,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
          // floatingActionButton: FloatingActionButton.extended(
          //   onPressed: () {
          //     _showSendConfirmationDialog(context);
          //   },
          //   backgroundColor: const Color(0xFF667eea),
          //   foregroundColor: Colors.white,
          //   icon: const Icon(Icons.cloud_upload_outlined),
          //   label: const Text(
          //     'Kirim Data',
          //     style: TextStyle(fontWeight: FontWeight.w600),
          //   ),
          //   elevation: 6,
          // ),
        );
      },
    );
  }

  Widget _buildCompactFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667eea) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF667eea) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF4A5568),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String? keywordFilter, BusinessStatus? status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            keywordFilter?.isNotEmpty == true || status != null
                ? 'Tidak ada usaha yang sesuai\ndengan filter yang dipilih'
                : 'Tidak ada data usaha prelist',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (keywordFilter?.isNotEmpty == true || status != null)
            TextButton(
              onPressed: () {
                _updatingProvider.add(ClearFilters());
              },
              child: const Text(
                'Reset Filter',
                style: TextStyle(
                  color: Color(0xFF2B6CB0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPrerequisitesPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PrerequisitesPopup(
          onFilterNotConfirmed: () {
            _updatingProvider.add(
              FilterByStatus(status: BusinessStatus.notConfirmed),
            );
          },
          onShowCamera: () {
            _showCameraDialog(context);
          },
          onSendData: () {
            _showSendConfirmationDialog(context);
          },
        );
      },
    );
  }

  void _showCameraDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CameraDialog(onTakePicture: _takePicture);
      },
    );
  }

  void _takePicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 60,
      );

      if (!mounted) return;

      if (image != null) {
        // String? _capturedImagePath = image.path;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto berhasil diambil: ${image.name}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        // User cancelled the camera
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pengambilan foto dibatalkan'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error mengambil foto: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showSlsInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SlsInfoDialog();
      },
    );
  }

  void _showSortOptions(BuildContext context, SortBy selectedSortBy) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return _SortModalContent(
          selectedSortBy: selectedSortBy,
          onSortSelected: (sortBy) {
            _updatingProvider.add(SortByEvent(sortBy: sortBy));
          },
        );
      },
    );
  }

  void _showSendConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: Color(0xFF667eea),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Kirim Data ke Server',
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
                'Apakah Anda yakin ingin mengirim semua data konfirmasi usaha ke server?',
                style: TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
              ),
              SizedBox(height: 12),
              Text(
                'Data yang akan dikirim:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Status konfirmasi semua usaha\n• Informasi SLS yang dipilih\n• Data update terbaru',
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
                _showSendingProgressDialog(context);
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

  void _showSendingProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mengirim data ke server...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Harap tunggu sebentar',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusButton(
    bool isFirstStepDone,
    bool isSecondStepDone,
    bool isSecondStepNeeded,
  ) {
    Color circleColor;
    IconData buttonIcon;
    String tooltip;

    if (isFirstStepDone && (!isSecondStepNeeded || isSecondStepDone)) {
      // All required steps completed - Green
      circleColor = Colors.green[400]!;
      buttonIcon = Icons.check_circle;
      tooltip =
          isSecondStepNeeded
              ? 'Siap untuk dikirim'
              : 'Siap untuk dikirim (1 langkah)';
    } else if (isFirstStepDone && isSecondStepNeeded && !isSecondStepDone) {
      // Only first step completed - Orange
      circleColor = Colors.orange[400]!;
      buttonIcon = Icons.pending_actions;
      tooltip = '1 dari 2 langkah selesai';
    } else {
      // No steps completed - Red
      circleColor = Colors.red[400]!;
      buttonIcon = Icons.error_outline;
      tooltip =
          isSecondStepNeeded
              ? 'Belum ada langkah yang diselesaikan'
              : 'Konfirmasi usaha diperlukan';
    }

    return IconButton(
      onPressed: () => _showPrerequisitesPopup(),
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: circleColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: circleColor.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(buttonIcon, color: Colors.white, size: 20),
      ),
      tooltip: tooltip,
    );
  }
}

// Separate stateful widget for the sort modal to handle local state
class _SortModalContent extends StatefulWidget {
  final SortBy selectedSortBy;
  final Function(SortBy) onSortSelected;

  const _SortModalContent({
    required this.selectedSortBy,
    required this.onSortSelected,
  });

  @override
  _SortModalContentState createState() => _SortModalContentState();
}

class _SortModalContentState extends State<_SortModalContent> {
  late SortBy _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedSortBy;
  }

  void _selectSort(SortBy sortBy) async {
    // Update local state first for immediate visual feedback
    setState(() {
      _currentSelection = sortBy;
    });

    // Send the event to Bloc
    widget.onSortSelected(sortBy);

    // Add a small delay for visual feedback before closing
    await Future.delayed(const Duration(milliseconds: 200));

    // Close the modal
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.sort, color: Color(0xFF667eea)),
                    const SizedBox(width: 8),
                    const Text(
                      'Urutkan Berdasarkan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Scrollable sort options
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Name sorting options
                    _buildSortOption(
                      context,
                      icon: Icons.sort_by_alpha,
                      title: 'Nama (A-Z)',
                      subtitle: 'Urutkan nama usaha dari A ke Z',
                      isSelected: _currentSelection == SortBy.nameAsc,
                      onTap: () => _selectSort(SortBy.nameAsc),
                    ),

                    _buildSortOption(
                      context,
                      icon: Icons.sort_by_alpha,
                      title: 'Nama (Z-A)',
                      subtitle: 'Urutkan nama usaha dari Z ke A',
                      isSelected: _currentSelection == SortBy.nameDesc,
                      onTap: () => _selectSort(SortBy.nameDesc),
                    ),

                    // // Status sorting options
                    // _buildSortOption(
                    //   context,
                    //   icon: Icons.check_circle_outline,
                    //   title: 'Status (Dikonfirmasi Dulu)',
                    //   subtitle:
                    //       'Tampilkan yang sudah dikonfirmasi terlebih dahulu',
                    //   isSelected: _currentSelection == SortBy.statusAsc,
                    //   onTap: () => _selectSort(SortBy.statusAsc),
                    // ),

                    // _buildSortOption(
                    //   context,
                    //   icon: Icons.help_outline,
                    //   title: 'Status (Belum Dikonfirmasi Dulu)',
                    //   subtitle:
                    //       'Tampilkan yang belum dikonfirmasi terlebih dahulu',
                    //   isSelected: _currentSelection == SortBy.statusDesc,
                    //   onTap: () => _selectSort(SortBy.statusDesc),
                    // ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? const Color(0xFF667eea).withValues(alpha: 0.1)
                        : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? const Color(0xFF667eea) : Colors.grey[600],
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
                          isSelected
                              ? const Color(0xFF667eea)
                              : const Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Radio button instead of checkmark
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (value) => onTap(),
              activeColor: const Color(0xFF667eea),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
