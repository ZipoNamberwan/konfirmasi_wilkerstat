import 'package:equatable/equatable.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';
import 'package:konfirmasi_wilkerstat/model/sls.dart';

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
  final Sls? sls;
  final List<Business> businesses;
  final List<Business> filteredBusinesses;
  final BusinessStatus? selectedStatusFilter;
  final String? keywordFilter;
  final SortBy sortBy;
  final Map<int, int> summary;

  UpdatingStateData({
    this.sls,
    required this.businesses,
    required this.filteredBusinesses,
    this.selectedStatusFilter,
    this.keywordFilter,
    required this.sortBy,
    required this.summary,
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
    return true;
  }
}

enum SortBy { nameDesc, nameAsc, statusDesc, statusAsc }
