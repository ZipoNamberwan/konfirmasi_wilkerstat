import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_state.dart';
import 'package:konfirmasi_wilkerstat/classes/app_config.dart';
  import 'package:konfirmasi_wilkerstat/pages/updating_page.dart';
import 'package:konfirmasi_wilkerstat/widgets/about_app_dialog.dart';
import 'package:konfirmasi_wilkerstat/widgets/assignment_state_widgets.dart';
import 'package:konfirmasi_wilkerstat/widgets/download_confirmation_dialog.dart';
import 'package:konfirmasi_wilkerstat/widgets/downloading_assignments_widget.dart';
import 'package:konfirmasi_wilkerstat/widgets/initializing_widget.dart';
import 'package:konfirmasi_wilkerstat/widgets/user_info_dialog.dart';
import 'package:konfirmasi_wilkerstat/widgets/village_card_widget.dart';
import 'package:konfirmasi_wilkerstat/widgets/logout_confirmation_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {}
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => LogoutConfirmationDialog(),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'assignment':
        _projectBloc.add(DownloadAssignments());
        break;
      case 'help':
        _openUrl(AppConfig.helpUrl);
        break;
      case 'feedback':
        _openUrl(AppConfig.feedbackUrl);
        break;
      case 'about':
        AboutAppDialog.show(context);
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
        value: 'help',
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
        value: 'feedback',
        child: Row(
          children: [
            Icon(
              Icons.feedback_rounded,
              color: const Color(0xFF667eea),
              size: 20,
            ),
            const SizedBox(width: 12),
            const Text(
              'Saran & Masukan',
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
    DownloadConfirmationDialog.showVillageDownload(
      context: context,
      villageName: village.name,
      onConfirm: () {
        _projectBloc.add(DownloadVillageData(villageId: village.id));
      },
    );
  }

  void _handleSlsDownload(sls) {
    DownloadConfirmationDialog.showSlsDownload(
      context: context,
      slsName: sls.name,
      onConfirm: () {
        _projectBloc.add(DownloadSlsData(slsId: sls.id));
      },
    );
  }

  void _handleSlsClick(sls) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => UpdatingPage(selectedSls: sls)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectBloc, ProjectState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return UserInfoDialog(
                      user: state.data.user,
                      onLogout: () {
                        _showLogoutConfirmation();
                      },
                    );
                  },
                );
              },
            ),
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
    // Check if app is initializing
    if (state is Initializing) {
      return const InitializingWidget();
    } else {
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
      } else {
        if (state.data.isDownloadingAssignments) {
          return const DownloadingAssignmentsWidget();
        }
      }
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
        final villageSlsList =
            state.data.sls
                .where((sls) => sls.village.id == village.id)
                .toList();

        return VillageCardWidget(
          village: village,
          villageSlsList: villageSlsList,
          onVillageDownload: _handleVillageDownload,
          onSlsDownload: _handleSlsDownload,
          onSlsClick: _handleSlsClick, // Add this line
        );
      },
    );
  }
}
