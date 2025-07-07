import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_state.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/local_db/assignment_db_repository.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';

class UpdatingBloc extends Bloc<UpdatingEvent, UpdatingState> {
  UpdatingBloc()
    : super(
        Initializing(
          data: UpdatingStateData(businesses: [], filteredBusinesses: []),
        ),
      ) {
    on<Init>((event, emit) async {
      final businesses = await AssignmentDbRepository().getBusinessesBySls(
        event.slsId,
      );

      emit(
        UpdatingState(
          data: state.data.copyWith(
            businesses: businesses,
            filteredBusinesses: businesses,
          ),
        ),
      );
    });

    on<FilterByKeyword>((event, emit) async {
      final filteredBusinesses = _filterBusinesses(
        businesses: state.data.businesses,
        keyword: event.keyword,
        status: state.data.selectedStatusFilter,
      );

      emit(
        UpdatingState(
          data: state.data.copyWith(
            filteredBusinesses: filteredBusinesses,
            keywordFilter: event.keyword,
          ),
        ),
      );
    });

    on<FilterByStatus>((event, emit) async {
      final filteredBusinesses = _filterBusinesses(
        businesses: state.data.businesses,
        keyword: state.data.keywordFilter,
        status: event.status,
      );

      final updatedData =
          event.status == null
              ? state.data.copyWith(
                filteredBusinesses: filteredBusinesses,
                clearSelectedStatusFilter: true,
              )
              : state.data.copyWith(
                filteredBusinesses: filteredBusinesses,
                selectedStatusFilter: event.status,
              );

      emit(UpdatingState(data: updatedData));
    });

    on<ClearFilters>((event, emit) async {
      emit(
        UpdatingState(
          data: state.data.copyWith(
            filteredBusinesses: state.data.businesses,
            clearKeywordFilter: true,
            clearSelectedStatusFilter: true,
          ),
        ),
      );
    });
  }

  /// Helper method to filter businesses based on keyword and status
  List<Business> _filterBusinesses({
    required List<Business> businesses,
    String? keyword,
    BusinessStatus? status,
  }) {
    return businesses.where((business) {
      // Filter by keyword (search in name, owner, and address)
      bool matchesKeyword = true;
      if (keyword != null && keyword.isNotEmpty) {
        final searchTerm = keyword.toLowerCase();
        matchesKeyword =
            business.name.toLowerCase().contains(searchTerm) ||
            (business.owner?.toLowerCase().contains(searchTerm) ?? false) ||
            (business.address?.toLowerCase().contains(searchTerm) ?? false);
      }

      // Filter by status
      bool matchesStatus = true;
      if (status != null) {
        matchesStatus = business.status?.key == status.key;
      } else {
        // If status is null, don't filter by status - show all
        matchesStatus = true;
      }

      return matchesKeyword && matchesStatus;
    }).toList();
  }
}
