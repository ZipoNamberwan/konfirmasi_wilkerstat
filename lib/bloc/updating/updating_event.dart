import 'package:equatable/equatable.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_state.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';

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
  const ClearFilters();
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
