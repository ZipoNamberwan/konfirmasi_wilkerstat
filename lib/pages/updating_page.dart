import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_state.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';
import 'package:konfirmasi_wilkerstat/pages/widgets/business_item_widget.dart';

class UpdatingPage extends StatefulWidget {
  final Sls selectedSls;

  const UpdatingPage({super.key, required this.selectedSls});

  @override
  State<UpdatingPage> createState() => _UpdatingPageState();
}

class _UpdatingPageState extends State<UpdatingPage> {
  late final UpdatingBloc _provider;

  @override
  void initState() {
    super.initState();

    _provider = UpdatingBloc()..add(Init(slsId: widget.selectedSls.id));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UpdatingBloc>(
      create: (context) => _provider,
      child: BlocConsumer<UpdatingBloc, UpdatingState>(
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
                              _provider.add(FilterByKeyword(keyword: value));
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
                                          state.data.selectedStatusFilter ==
                                          null,
                                      onTap: () {
                                        _provider.add(
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
                                        _provider.add(
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
                                        _provider.add(
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
                                        _provider.add(
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
                                  _provider.add(ClearFilters());
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
                            // Compact count display
                            Text(
                              '${state.data.filteredBusinesses.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
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
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              itemCount: state.data.filteredBusinesses.length,
                              itemBuilder: (context, index) {
                                final business =
                                    state.data.filteredBusinesses[index];
                                return BusinessItemWidget(
                                  business: business,
                                  onStatusChanged: (status) {},
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
                : 'Belum ada data usaha',
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
                _provider.add(ClearFilters());
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
}
