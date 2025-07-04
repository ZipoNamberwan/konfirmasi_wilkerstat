import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/project/project_state.dart';

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
    _projectBloc = ProjectBloc()..add(Init());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _projectBloc,
      child: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Daftar Desa & SLS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFF667eea),
              elevation: 0,
              centerTitle: true,
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
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.data.villages.length,
                itemBuilder: (context, index) {
                  final village = state.data.villages[index];
                  final isExpanded = true;
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
                                  const Color(
                                    0xFF667eea,
                                  ).withValues(alpha: 0.1),
                                  const Color(
                                    0xFF764ba2,
                                  ).withValues(alpha: 0.1),
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
                                    colors: [
                                      Color(0xFF667eea),
                                      Color(0xFF764ba2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.location_city,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                village.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              subtitle: Text(
                                'Kode: ${village.code} • ${villageSlsList.length} SLS',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                          // SLS List (Expandable)
                          if (isExpanded && villageSlsList.isNotEmpty) ...[
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
                                    'Kode: ${sls.code}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
