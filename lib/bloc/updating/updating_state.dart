import 'package:equatable/equatable.dart';
import 'package:konfirmasi_wilkerstat/config/workflow_config.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';
import 'package:konfirmasi_wilkerstat/model/upload.dart';
import 'package:konfirmasi_wilkerstat/model/village.dart';
import 'package:latlong2/latlong.dart';

class UpdatingState extends Equatable {
  final UpdatingStateData data;

  const UpdatingState({required this.data});

  @override
  List<Object> get props => [data];
}

class Initializing extends UpdatingState {
  Initializing()
    : super(
        data: UpdatingStateData(
          businesses: [],
          filteredBusinesses: [],
          sortBy: SortBy.nameAsc,
          summary: {},
          keywordFilter: null,
          sls: Sls(
            id: '',
            code: '',
            name: '',
            village: Village(
              id: '',
              code: '',
              name: '',
              hasDownloaded: false,
              isDeleted: false,
            ),
            isDeleted: false,
            hasDownloaded: false,
            locked: false,
          ),
          selectedStatusFilter: null,
          isSendingToServer: false,
          sendingMessage: null,
          slsUploads: [],
          isUnlockingSls: false,
          isGettingLocation: false,
          slsChiefName: null,
          slsChiefPhone: null,
          slsChiefLocation: null,
          isSaveLoading: false,
        ),
      );
}

class TokenExpired extends UpdatingState {
  const TokenExpired({required super.data});
}

class SendDataSuccessful extends UpdatingState {
  const SendDataSuccessful({required super.data});
}

class SendDataSuccess extends UpdatingState {
  const SendDataSuccess({required super.data});
}

class SendDataFailed extends UpdatingState {
  const SendDataFailed({required super.data});
}

class SlsUnlocked extends UpdatingState {
  const SlsUnlocked({required super.data});
}

class GettingLocation extends UpdatingState {
  const GettingLocation({required super.data});
}

class SlsLocationUpdated extends UpdatingState {
  const SlsLocationUpdated({required super.data});
}

class SlsLocationFailed extends UpdatingState {
  final String errorMessage;
  const SlsLocationFailed({required this.errorMessage, required super.data});
}

class MockupLocationDetected extends UpdatingState {
  const MockupLocationDetected({required super.data});
}

class SaveSlsInfoSuccess extends UpdatingState {
  const SaveSlsInfoSuccess({required super.data});
}

class SaveSlsInfoError extends UpdatingState {
  final String errorMessage;
  const SaveSlsInfoError({required this.errorMessage, required super.data});
}

class NoBusinesses extends UpdatingState {
  const NoBusinesses({required super.data});
}

class UpdatingStateData {
  final Sls sls;
  final List<Business> businesses;
  final List<Business> filteredBusinesses;
  final BusinessStatus? selectedStatusFilter;
  final String? keywordFilter;
  final SortBy sortBy;
  final Map<int, int> summary;
  final bool isSendingToServer;
  final String? sendingMessage;
  final List<SlsUpload> slsUploads;
  final bool isUnlockingSls;
  final bool isGettingLocation;

  // Form Attributes
  final String? slsChiefName;
  final String? slsChiefPhone;
  final LatLng? slsChiefLocation;
  final bool isSaveLoading;

  UpdatingStateData({
    required this.sls,
    required this.businesses,
    required this.filteredBusinesses,
    this.selectedStatusFilter,
    this.keywordFilter,
    required this.sortBy,
    required this.summary,
    required this.isSendingToServer,
    this.sendingMessage,
    required this.slsUploads,
    required this.isUnlockingSls,
    required this.isGettingLocation,
    this.slsChiefName,
    this.slsChiefPhone,
    this.slsChiefLocation,
    required this.isSaveLoading,
  });

  UpdatingStateData copyWith({
    Sls? sls,
    List<Business>? businesses,
    List<Business>? filteredBusinesses,
    BusinessStatus? selectedStatusFilter,
    String? keywordFilter,
    bool clearSelectedStatusFilter = false,
    bool clearKeywordFilter = false,
    SortBy? sortBy,
    Map<int, int>? summary,
    bool? isSendingToServer,
    String? sendingMessage,
    bool? clearSendingMessage,
    List<SlsUpload>? slsUploads,
    bool? isUnlockingSls,
    bool? isGettingLocation,
    String? slsChiefName,
    String? slsChiefPhone,
    LatLng? slsChiefLocation,
    bool? resetForm,
    bool? isSaveLoading,
  }) {
    return UpdatingStateData(
      sls: sls ?? this.sls,
      businesses: businesses ?? this.businesses,
      filteredBusinesses: filteredBusinesses ?? this.filteredBusinesses,
      selectedStatusFilter:
          clearSelectedStatusFilter
              ? null
              : (selectedStatusFilter ?? this.selectedStatusFilter),
      keywordFilter:
          clearKeywordFilter ? null : (keywordFilter ?? this.keywordFilter),
      sortBy: sortBy ?? this.sortBy,
      summary: summary ?? this.summary,
      isSendingToServer: isSendingToServer ?? this.isSendingToServer,
      sendingMessage:
          clearSendingMessage ?? false
              ? null
              : (sendingMessage ?? this.sendingMessage),
      slsUploads: slsUploads ?? this.slsUploads,
      isUnlockingSls: isUnlockingSls ?? this.isUnlockingSls,
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,

      slsChiefName:
          resetForm ?? false ? null : (slsChiefName ?? this.slsChiefName),
      slsChiefPhone:
          resetForm ?? false ? null : (slsChiefPhone ?? this.slsChiefPhone),
      slsChiefLocation:
          resetForm ?? false
              ? null
              : (slsChiefLocation ?? this.slsChiefLocation),
      isSaveLoading: isSaveLoading ?? this.isSaveLoading,
    );
  }

  bool isFirstStepDone() {
    final unconfirmedCount =
        businesses.where((b) => b.status == BusinessStatus.notConfirmed).length;
    return unconfirmedCount == 0;
  }

  int getNotconfirmedCount() {
    return businesses
        .where((b) => b.status == BusinessStatus.notConfirmed)
        .length;
  }

  bool isSecondStepDone() {
    // If second step is not needed, consider it always done
    if (!isSecondStepNeeded()) return true;

    // This could check if photos are uploaded, etc.
    return sls.slsChiefLocation != null &&
        sls.slsChiefName != null &&
        sls.slsChiefName != ''; // Currently hardcoded as done
  }

  bool isSecondStepNeeded() {
    // Use centralized configuration for workflow mode
    return WorkflowConfig.isPhotoUploadStepNeeded;
  }
}

enum SortBy { nameDesc, nameAsc, statusDesc, statusAsc }
