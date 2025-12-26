import 'package:equatable/equatable.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_state.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';
import 'package:latlong2/latlong.dart';

abstract class UpdatingEvent extends Equatable {
  const UpdatingEvent();
  @override
  List<Object?> get props => [];
}

class Init extends UpdatingEvent {
  final String slsId;
  const Init({required this.slsId});
}

class FilterByKeyword extends UpdatingEvent {
  final String keyword;
  const FilterByKeyword({required this.keyword});
}

class FilterByStatus extends UpdatingEvent {
  final BusinessStatus? status;
  const FilterByStatus({required this.status});
}

class ClearFilters extends UpdatingEvent {
  final bool? clearKeyword;
  final bool? clearStatus;
  const ClearFilters({this.clearKeyword = false, this.clearStatus = false});
}

class UpdateBusinessStatus extends UpdatingEvent {
  final Business business;
  final BusinessStatus status;

  const UpdateBusinessStatus({required this.business, required this.status});
}

class SortByEvent extends UpdatingEvent {
  final SortBy sortBy;
  const SortByEvent({required this.sortBy});
}

class SendData extends UpdatingEvent {
  const SendData();
}

class SendDataDirectToServer extends UpdatingEvent {
  const SendDataDirectToServer();
}

class UpdateSlsLockedStatus extends UpdatingEvent {
  final bool locked;
  const UpdateSlsLockedStatus({required this.locked});
}

class GetCurrentLocation extends UpdatingEvent {
  const GetCurrentLocation();
}

class UpdateChiefSlsName extends UpdatingEvent {
  final String chiefName;
  const UpdateChiefSlsName({required this.chiefName});
}

class UpdateChiefSlsPhone extends UpdatingEvent {
  final String chiefPhone;
  const UpdateChiefSlsPhone({required this.chiefPhone});
}

class UpdateChiefSlsLocation extends UpdatingEvent {
  final LatLng chiefLocation;
  const UpdateChiefSlsLocation({required this.chiefLocation});
}

class SaveChiefSlsInfo extends UpdatingEvent {
  const SaveChiefSlsInfo();
}

class ResetFormChiefSlsInfo extends UpdatingEvent {
  const ResetFormChiefSlsInfo();
}
