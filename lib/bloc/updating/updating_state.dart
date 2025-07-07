import 'package:equatable/equatable.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';

class UpdatingState extends Equatable {
  final UpdatingStateData data;

  const UpdatingState({required this.data});

  @override
  List<Object> get props => [data];
}

class Initializing extends UpdatingState {
  const Initializing({required super.data});
}

class UpdatingStateData {
  final List<Business> businesses;
  final List<Business> filteredBusinesses;
  final BusinessStatus? selectedStatusFilter;
  final String? keywordFilter;

  UpdatingStateData({
    required this.businesses,
    required this.filteredBusinesses,
    this.selectedStatusFilter,
    this.keywordFilter,
  });

  UpdatingStateData copyWith({
    List<Business>? businesses,
    List<Business>? filteredBusinesses,
    BusinessStatus? selectedStatusFilter,
    String? keywordFilter,
    bool clearSelectedStatusFilter = false,
    bool clearKeywordFilter = false,
  }) {
    return UpdatingStateData(
      businesses: businesses ?? this.businesses,
      filteredBusinesses: filteredBusinesses ?? this.filteredBusinesses,
      selectedStatusFilter:
          clearSelectedStatusFilter
              ? null
              : (selectedStatusFilter ?? this.selectedStatusFilter),
      keywordFilter:
          clearKeywordFilter ? null : (keywordFilter ?? this.keywordFilter),
    );
  }
}
