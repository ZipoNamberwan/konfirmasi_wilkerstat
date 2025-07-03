import 'package:flutter/material.dart';
import '../model/village.dart';
import '../model/sls.dart';

class SlsProjectList extends StatefulWidget {
  const SlsProjectList({super.key});

  @override
  State<SlsProjectList> createState() => _SlsProjectListState();
}

class _SlsProjectListState extends State<SlsProjectList> {
  // Dummy villages data
  final List<Village> _villages = [
    Village(id: '1', code: 'V001', name: 'Desa Sukamaju'),
    Village(id: '2', code: 'V002', name: 'Desa Makmur'),
    Village(id: '3', code: 'V003', name: 'Desa Sejahtera'),
    Village(id: '4', code: 'V004', name: 'Desa Harmoni'),
  ];

  // Available SLS data for selection
  final List<Sls> _availableSls = [
    Sls(
      id: '1',
      code: 'SLS001',
      name: 'SLS Kampung Baru',
      isAdded: false,
      village: Village(id: '1', code: 'V001', name: 'Desa Sukamaju'),
    ),
    Sls(
      id: '2',
      code: 'SLS002',
      name: 'SLS Pasar Minggu',
      isAdded: false,
      village: Village(id: '1', code: 'V001', name: 'Desa Sukamaju'),
    ),
    Sls(
      id: '3',
      code: 'SLS003',
      name: 'SLS Perumahan Indah',
      isAdded: false,
      village: Village(id: '1', code: 'V001', name: 'Desa Sukamaju'),
    ),
    Sls(
      id: '4',
      code: 'SLS004',
      name: 'SLS Kampung Nelayan',
      isAdded: false,
      village: Village(id: '2', code: 'V002', name: 'Desa Makmur'),
    ),
    Sls(
      id: '5',
      code: 'SLS005',
      name: 'SLS Industri',
      isAdded: false,
      village: Village(id: '2', code: 'V002', name: 'Desa Makmur'),
    ),
    Sls(
      id: '6',
      code: 'SLS006',
      name: 'SLS Pertanian',
      isAdded: false,
      village: Village(id: '3', code: 'V003', name: 'Desa Sejahtera'),
    ),
    Sls(
      id: '7',
      code: 'SLS007',
      name: 'SLS Pemukiman',
      isAdded: false,
      village: Village(id: '3', code: 'V003', name: 'Desa Sejahtera'),
    ),
    Sls(
      id: '8',
      code: 'SLS008',
      name: 'SLS Perdagangan',
      isAdded: false,
      village: Village(id: '4', code: 'V004', name: 'Desa Harmoni'),
    ),
  ];

  // Map to store selected SLS for each village
  final Map<String, List<Sls>> _villageSlsMap = {};

  // Map to track which villages are expanded
  final Map<String, bool> _expandedVillages = {};

  @override
  void initState() {
    super.initState();
    // Initialize all villages as expanded with empty SLS lists
    for (var village in _villages) {
      _expandedVillages[village.id] = true;
      _villageSlsMap[village.id] = [];
    }
  }

  void _showAddSlsDialog(Village village) {
    // Get available SLS for this village
    List<Sls> availableSlsForVillage =
        _availableSls
            .where((sls) => sls.village.id == village.id)
            .where(
              (sls) =>
                  !_villageSlsMap[village.id]!.any(
                    (selectedSls) => selectedSls.id == sls.id,
                  ),
            )
            .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Tambah SLS untuk ${village.name}'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child:
                    availableSlsForVillage.isEmpty
                        ? const Center(
                          child: Text(
                            'Tidak ada SLS yang tersedia',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                        : ListView.builder(
                          itemCount: availableSlsForVillage.length,
                          itemBuilder: (context, index) {
                            final sls = availableSlsForVillage[index];
                            return CheckboxListTile(
                              title: Text(sls.name),
                              subtitle: Text('Kode: ${sls.code}'),
                              value: sls.isAdded,
                              onChanged: (bool? value) {
                                setDialogState(() {
                                  availableSlsForVillage[index] = Sls(
                                    id: sls.id,
                                    code: sls.code,
                                    name: sls.name,
                                    isAdded: value ?? false,
                                    village: sls.village,
                                  );
                                });
                              },
                              activeColor: const Color(0xFF667eea),
                            );
                          },
                        ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add selected SLS to village
                    List<Sls> selectedSls =
                        availableSlsForVillage
                            .where((sls) => sls.isAdded)
                            .toList();

                    setState(() {
                      _villageSlsMap[village.id]!.addAll(selectedSls);
                    });

                    Navigator.of(context).pop();

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${selectedSls.length} SLS berhasil ditambahkan',
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeSls(Village village, Sls sls) {
    setState(() {
      _villageSlsMap[village.id]!.removeWhere((item) => item.id == sls.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${sls.name} dihapus dari ${village.name}'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Desa & SLS',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
          itemCount: _villages.length,
          itemBuilder: (context, index) {
            final village = _villages[index];
            final isExpanded = _expandedVillages[village.id] ?? true;
            final villageSlsList = _villageSlsMap[village.id] ?? [];

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
                            const Color(0xFF667eea).withOpacity(0.1),
                            const Color(0xFF764ba2).withOpacity(0.1),
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Add SLS Button
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF667eea),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                onPressed: () => _showAddSlsDialog(village),
                                tooltip: 'Tambah SLS',
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Expand/Collapse Button
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: const Color(0xFF2D3748),
                                  size: 16,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _expandedVillages[village.id] = !isExpanded;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // SLS List (Expandable)
                    if (isExpanded && villageSlsList.isNotEmpty) ...[
                      ...villageSlsList
                          .map(
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
                                    ).withOpacity(0.2),
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
                                trailing: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 14,
                                    ),
                                    onPressed: () => _removeSls(village, sls),
                                    tooltip: 'Hapus SLS',
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
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
  }
}
