import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_state.dart';

class LocationDialog extends StatefulWidget {
  const LocationDialog({super.key});

  @override
  State<LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  final TextEditingController _chiefNameController = TextEditingController();
  final TextEditingController _chiefPhoneController = TextEditingController();

  late final UpdatingBloc _updatingBloc;

  @override
  void initState() {
    super.initState();
    _updatingBloc = context.read<UpdatingBloc>();
    final String initialChiefName =
        _updatingBloc.state.data.sls.slsChiefName ?? '';
    _chiefNameController.text = initialChiefName;
    if (initialChiefName.isNotEmpty) {
      _updatingBloc.add(UpdateChiefSlsName(chiefName: initialChiefName));
    }

    final String initialChiefPhone =
        _updatingBloc.state.data.sls.slsChiefPhone ?? '';
    _chiefPhoneController.text = initialChiefPhone;
    if (initialChiefPhone.isNotEmpty) {
      _updatingBloc.add(UpdateChiefSlsPhone(chiefPhone: initialChiefPhone));
    }

    final chiefLocation = _updatingBloc.state.data.sls.slsChiefLocation;
    if (chiefLocation != null) {
      _updatingBloc.add(UpdateChiefSlsLocation(chiefLocation: chiefLocation));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdatingBloc, UpdatingState>(
      listener: (context, state) {
        if (state is SaveSlsInfoSuccess) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
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
                  Icons.location_on,
                  color: Color(0xFF667eea),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Data Ketua SLS & Lokasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Isi data berikut untuk dokumentasi SLS.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
                ),
                const SizedBox(height: 12),

                // Chief Name
                _buildTextField(
                  label: 'Nama Ketua SLS',
                  icon: Icons.person_rounded,
                  keyboardType: TextInputType.name,
                  onChanged: (value) {
                    _updatingBloc.add(UpdateChiefSlsName(chiefName: value));
                  },
                  isMandatory: true,
                  controller: _chiefNameController,
                ),
                const SizedBox(height: 8),
                // Chief Phone
                _buildTextField(
                  label: 'No. HP Ketua SLS',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    _updatingBloc.add(UpdateChiefSlsPhone(chiefPhone: value));
                  },
                  controller: _chiefPhoneController,
                ),
                const SizedBox(height: 8),

                // Location Button
                ElevatedButton.icon(
                  onPressed:
                      state.data.isGettingLocation
                          ? null
                          : () {
                            _updatingBloc.add(GetCurrentLocation());
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
                  icon:
                      state.data.isGettingLocation
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Icon(Icons.location_on, size: 16),
                  label: Text(
                    state.data.isGettingLocation
                        ? 'Mengambil Lokasi...'
                        : 'Ambil Lokasi',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),

                // Show current location if available
                if (state.data.slsChiefLocation != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey[200] ?? Colors.grey,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lokasi Tersimpan',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Lat: ${state.data.slsChiefLocation!.latitude.toStringAsFixed(6)}\nLng: ${state.data.slsChiefLocation!.longitude.toStringAsFixed(6)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Show error if location failed
                if (state is SlsLocationFailed ||
                    state is SaveSlsInfoError) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gagal Mengambil Lokasi',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state is SlsLocationFailed
                                    ? state.errorMessage
                                    : (state as SaveSlsInfoError).errorMessage,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
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
              onPressed:
                  state.data.slsChiefLocation != null &&
                          state.data.slsChiefName != null &&
                          state.data.slsChiefName != '' &&
                          !state.data.isSaveLoading
                      ? () {
                        _updatingBloc.add(SaveChiefSlsInfo());
                      }
                      : null,
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
              icon:
                  state.data.isSaveLoading
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(Icons.save, size: 16),
              label: Text(
                state.data.isSaveLoading ? 'Menyimpan...' : 'Simpan',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    bool isMandatory = false,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      onChanged: onChanged,
      decoration: InputDecoration(
        label:
            isMandatory
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                : Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF667eea), size: 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
