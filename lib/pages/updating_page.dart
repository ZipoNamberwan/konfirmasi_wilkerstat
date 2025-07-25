import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_state.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';
import 'package:konfirmasi_wilkerstat/pages/login_page.dart';
import 'package:konfirmasi_wilkerstat/widgets/business_item_widget.dart';
import 'package:konfirmasi_wilkerstat/widgets/custom_snackbar.dart';
import 'package:konfirmasi_wilkerstat/widgets/location_dialog.dart';
import 'package:konfirmasi_wilkerstat/widgets/message_dialog.dart';
import 'package:konfirmasi_wilkerstat/widgets/sls_info_dialog.dart';
import 'package:konfirmasi_wilkerstat/widgets/prerequisites_popup.dart';
import 'package:konfirmasi_wilkerstat/widgets/send_confirmation_dialog.dart';
import 'package:konfirmasi_wilkerstat/widgets/unlock_confirmation_dialog.dart';

class UpdatingPage extends StatefulWidget {
  final Sls selectedSls;

  const UpdatingPage({super.key, required this.selectedSls});

  @override
  State<UpdatingPage> createState() => _UpdatingPageState();
}

class _UpdatingPageState extends State<UpdatingPage> {
  late final UpdatingBloc _updatingBloc;
  late final TextEditingController _searchController;
  @override
  void initState() {
    super.initState();
    _updatingBloc =
        context.read<UpdatingBloc>()..add(Init(slsId: widget.selectedSls.id));
    _searchController = TextEditingController();
    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        _updatingBloc.add(FilterByKeyword(keyword: _searchController.text));
      } else {
        _updatingBloc.add(ClearFilters(clearKeyword: true));
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdatingBloc, UpdatingState>(
      listener: (context, state) {
        if (state is SendDataSuccess) {
          CustomSnackBar.showSuccess(context, message: 'Data berhasil dikirim');
        } else if (state is SendDataFailed) {
          CustomSnackBar.showError(context, message: 'Gagal mengirim data');
        } else if (state is SlsUnlocked) {
          Navigator.pop(context);
          CustomSnackBar.showSuccess(context, message: 'SLS berhasil diunlock');
        } else if (state is TokenExpired) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        } else if (state is MockupLocationDetected) {
          showDialog(
            context: context,
            builder:
                (context) => MessageDialog(
                  title: 'Fake GPS Terdeteksi',
                  message:
                      'Kami mendeteksi bahwa Anda menggunakan aplikasi Fake GPS. '
                      'Silakan matikan aplikasi tersebut untuk melanjutkan tagging.',
                  type: MessageType.error,
                  buttonText: 'Tutup',
                ),
          );
        }
      },
      builder: (context, state) {
        if (state is Initializing) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                state.data.sls.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              backgroundColor: const Color(0xFF667eea),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
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
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF667eea),
                      ),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Memuat data usaha...',
                      style: TextStyle(
                        color: Color(0xFF2D3748),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.data.sls.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // if (state.data.sls.locked) ...[
                    //   const SizedBox(width: 8),
                    //   Container(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 6,
                    //       vertical: 2,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: Colors.orange[600],
                    //       borderRadius: BorderRadius.circular(4),
                    //     ),
                    //     child: const Text(
                    //       'TERKUNCI',
                    //       style: TextStyle(
                    //         fontSize: 10,
                    //         fontWeight: FontWeight.bold,
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //   ),
                    // ],
                  ],
                ),
                Text(
                  state.data.sls.village.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            backgroundColor:
                state.data.sls.locked
                    ? Colors.orange[600]
                    : const Color(0xFF667eea),
            elevation: 0,
            centerTitle: false,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              _buildStatusButton(
                state.data.isFirstStepDone(),
                state.data.isSecondStepDone(),
                state.data.isSecondStepNeeded(),
                state.data.sls.locked,
              ),
              IconButton(
                onPressed: state.data.sls.locked ? null : () => _showSlsInfo(),
                icon: Icon(
                  Icons.info_outline,
                  color: state.data.sls.locked ? Colors.white54 : Colors.white,
                ),
                tooltip: state.data.sls.locked ? null : 'Informasi SLS',
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                    state.data.sls.locked
                        ? [Colors.orange[600]!, const Color(0xFFF8F9FA)]
                        : [const Color(0xFF667eea), const Color(0xFFF8F9FA)],
                stops: const [0.0, 0.3],
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
                          enabled: !state.data.sls.locked,
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari usaha...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color:
                                  state.data.sls.locked
                                      ? Colors.grey[400]
                                      : null,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color:
                                  state.data.sls.locked
                                      ? Colors.grey[400]
                                      : const Color(0xFF718096),
                              size: 20,
                            ),
                            suffixIcon:
                                state.data.keywordFilter?.isNotEmpty == true
                                    ? IconButton(
                                      onPressed:
                                          state.data.sls.locked
                                              ? null
                                              : () {
                                                _searchController.clear();
                                                _updatingBloc.add(
                                                  ClearFilters(
                                                    clearKeyword: true,
                                                  ),
                                                );
                                              },
                                      icon: Icon(
                                        Icons.clear,
                                        size: 18,
                                        color:
                                            state.data.sls.locked
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                      ),
                                    )
                                    : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color:
                                    state.data.sls.locked
                                        ? Colors.grey[300]!
                                        : const Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color:
                                    state.data.sls.locked
                                        ? Colors.grey[300]!
                                        : const Color(0xFFE2E8F0),
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF667eea),
                              ),
                            ),
                            filled: true,
                            fillColor:
                                state.data.sls.locked
                                    ? Colors.grey[100]
                                    : const Color(0xFFF7FAFC),
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
                                    isLocked: state.data.sls.locked,
                                    onTap:
                                        state.data.sls.locked
                                            ? null
                                            : () {
                                              _updatingBloc.add(
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
                                    isLocked: state.data.sls.locked,
                                    onTap:
                                        state.data.sls.locked
                                            ? null
                                            : () {
                                              _updatingBloc.add(
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
                                    isLocked: state.data.sls.locked,
                                    onTap:
                                        state.data.sls.locked
                                            ? null
                                            : () {
                                              _updatingBloc.add(
                                                FilterByStatus(
                                                  status:
                                                      BusinessStatus.notFound,
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
                                    isLocked: state.data.sls.locked,
                                    onTap:
                                        state.data.sls.locked
                                            ? null
                                            : () {
                                              _updatingBloc.add(
                                                FilterByStatus(
                                                  status:
                                                      BusinessStatus
                                                          .notConfirmed,
                                                ),
                                              );
                                            },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Clear filter button
                          if (state.data.selectedStatusFilter != null)
                            GestureDetector(
                              onTap:
                                  state.data.sls.locked
                                      ? null
                                      : () {
                                        _updatingBloc.add(
                                          ClearFilters(clearStatus: true),
                                        );
                                      },
                              child: Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color:
                                      state.data.sls.locked
                                          ? Colors.grey[50]
                                          : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.clear,
                                  size: 16,
                                  color:
                                      state.data.sls.locked
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                ),
                              ),
                            ),
                          const SizedBox(width: 6),
                          // Sort button
                          GestureDetector(
                            onTap:
                                state.data.sls.locked
                                    ? null
                                    : () {
                                      _showSortOptions(
                                        context,
                                        state.data.sortBy,
                                      );
                                    },
                            child: Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color:
                                    state.data.sls.locked
                                        ? Colors.grey[50]
                                        : Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Stack(
                                children: [
                                  Icon(
                                    Icons.sort,
                                    size: 16,
                                    color:
                                        state.data.sls.locked
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
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
                            state.data.sls.locked,
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                            itemCount: state.data.filteredBusinesses.length,
                            itemBuilder: (context, index) {
                              final business =
                                  state.data.filteredBusinesses[index];
                              return BusinessItemWidget(
                                business: business,
                                isLocked: state.data.sls.locked,
                                onStatusChanged: (bsn, status) {
                                  if (!state.data.sls.locked) {
                                    _updatingBloc.add(
                                      UpdateBusinessStatus(
                                        business: bsn,
                                        status: status,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
          floatingActionButton:
              state.data.sls.locked
                  ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: () => _showUnlockConfirmation(),
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.lock_open),
                        label: const Text(
                          'Unlock SLS',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        elevation: 6,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Klik tombol ini untuk mengubah data lagi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                  : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
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
    VoidCallback? onTap,
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color:
              isSelected && !isLocked
                  ? const Color(0xFF667eea)
                  : isSelected && isLocked
                  ? Colors.grey[300]
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected && !isLocked
                    ? const Color(0xFF667eea)
                    : isLocked
                    ? Colors.grey[300]!
                    : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color:
                isSelected && !isLocked
                    ? Colors.white
                    : isLocked
                    ? Colors.grey[500]
                    : const Color(0xFF4A5568),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    String? keywordFilter,
    BusinessStatus? status,
    bool isLocked,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 64,
            color: isLocked ? Colors.grey[300] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            keywordFilter?.isNotEmpty == true || status != null
                ? 'Tidak ada usaha yang sesuai\ndengan filter yang dipilih'
                : 'Tidak ada data usaha prelist',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isLocked ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if ((keywordFilter?.isNotEmpty == true || status != null) &&
              !isLocked)
            TextButton(
              onPressed: () {
                _updatingBloc.add(ClearFilters());
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
            _updatingBloc.add(
              FilterByStatus(status: BusinessStatus.notConfirmed),
            );
          },
          onGetLocation: () {
            _showLocationDialog(context);
          },
          onSendData: () {
            _showSendConfirmationDialog(context);
          },
        );
      },
    );
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
            _updatingBloc.add(SortByEvent(sortBy: sortBy));
          },
        );
      },
    );
  }

  void _showSendConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SendConfirmationDialog(
          onConfirm: () {
            _updatingBloc.add(const SendData());
          },
        );
      },
    );
  }

  Future<void> _showLocationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return LocationDialog();
      },
    );

    _updatingBloc.add(ResetFormChiefSlsInfo());
  }

  Widget _buildStatusButton(
    bool isFirstStepDone,
    bool isSecondStepDone,
    bool isSecondStepNeeded,
    bool isLocked,
  ) {
    Color circleColor;
    IconData buttonIcon;
    String tooltip;

    if (isFirstStepDone && (!isSecondStepNeeded || isSecondStepDone)) {
      // All required steps completed - Green
      circleColor = Colors.green[400]!;
      buttonIcon = Icons.send;
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
      onPressed: isLocked ? null : () => _showPrerequisitesPopup(),
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isLocked ? Colors.transparent : circleColor,
          shape: BoxShape.circle,
          boxShadow:
              isLocked
                  ? []
                  : [
                    BoxShadow(
                      color: circleColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Icon(
          buttonIcon,
          color: isLocked ? Colors.white54 : Colors.white,
          size: 20,
        ),
      ),
      tooltip: isLocked ? null : tooltip,
    );
  }

  void _showUnlockConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UnlockConfirmationDialog(onConfirm: () => _unlockSls());
      },
    );
  }

  void _unlockSls() {
    _updatingBloc.add(UpdateSlsLockedStatus(locked: false));
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
