import 'package:equatable/equatable.dart';
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

