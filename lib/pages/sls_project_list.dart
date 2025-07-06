import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_state.dart';
import 'widgets/assignment_state_widgets.dart';

class SlsProjectList extends StatefulWidget {
  const SlsProjectList({super.key});

  @override
  State<SlsProjectList> createState() => _SlsProjectListState();
}

class _SlsProjectListState extends State<SlsProjectList> {
  late final ProjectBloc _projectBloc;
  @override
  void initState() {
    super.initState();
    _projectBloc = context.read<ProjectBloc>()..add(Init());
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'assignment':
        // TODO: Implement download assignment logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sinkronisasi Assignment'),
            backgroundColor: Color(0xFF667eea),
          ),
        );
        break;
      case 'guide':
        // TODO: Implement app guide logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Panduan'),
            backgroundColor: Color(0xFF667eea),
          ),
        );
        break;
      case 'about':
        // TODO: Implement about app logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tentang Aplikasi'),
            backgroundColor: Color(0xFF667eea),
          ),
        );
        break;
    }
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems() {
    return [
      PopupMenuItem<String>(
        value: 'assignment',
        child: Row(
          children: [
            Icon(Icons.download, color: const Color(0xFF667eea), size: 20),
            const SizedBox(width: 12),
            const Text(
              'Sinkronisasi Assignment',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'guide',
        child: Row(
          children: [
            Icon(Icons.help_outline, color: const Color(0xFF667eea), size: 20),
            const SizedBox(width: 12),
            const Text(
              'Panduan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'about',
        child: Row(
          children: [
            Icon(Icons.info_outline, color: const Color(0xFF667eea), size: 20),
            const SizedBox(width: 12),
            const Text(
              'Tentang Aplikasi',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    ];
  }

  void _handleVillageDownload(village) {
    // TODO: Implement village download logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mengunduh data untuk ${village.name}...'),
        backgroundColor: const Color(0xFF667eea),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    // Here you would typically trigger a Bloc event to download the village data
    // Example: _projectBloc.add(DownloadVillageData(villageId: village.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectBloc, ProjectState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Daftar Assignment',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFF667eea),
            elevation: 0,
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                offset: const Offset(0, 50),
                onSelected: (String value) {
                  _handleMenuSelection(value);
                },
                itemBuilder: (BuildContext context) => _buildPopupMenuItems(),
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
            child: _buildBodyContent(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBodyContent(BuildContext context, ProjectState state) {
    // Check if data is empty (no villages or sls assigned)
    if (state.data.villages.isEmpty && state.data.sls.isEmpty) {
      return NoAssignmentWidget(
        isLoading: state.data.isDownloadingAssignments,
        errorMessage:
            state is DownloadAssignmentsFailed ? state.errorMessage : null,
        onRetry: () {
          _projectBloc.add(const DownloadAssignments());
        },
      );
    }

    // Main content - show villages and SLS list
    return _buildVillagesList(state);
  }

  Widget _buildVillagesList(ProjectState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: state.data.villages.length,
      itemBuilder: (context, index) {
        final village = state.data.villages[index];
        final isExpanded = true;
        final isDownloaded =
            village.hasDownloaded; // Extract to variable for easy testing
        final villageSlsList =
            state.data.sls
                .where((sls) => sls.village.id == village.id)
                .toList();

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                        isDownloaded
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
                        if (!isDownloaded) ...[
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
                        ],
                      ],
                    ),
                    subtitle: Text(
                      '${village.id} • ${villageSlsList.length} SLS',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                ),

                // Download Button Section - Only show for non-downloaded villages
                if (!isDownloaded) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _handleVillageDownload(village);
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],

                // SLS List (Expandable) - Only show for downloaded villages
                if (isExpanded &&
                    villageSlsList.isNotEmpty &&
                    isDownloaded) ...[
                  const SizedBox(height: 6),
                  ...villageSlsList.map(
                    (sls) => Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF667eea,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.map_outlined,
                            color: const Color(0xFF667eea),
                            size: 16,
                          ),
                        ),
                        title: Text(
                          sls.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          sls.code,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
