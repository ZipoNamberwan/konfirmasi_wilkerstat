import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_event.dart';
import 'package:konfirmasi_wilkerstat/bloc/updating/updating_state.dart';
import 'package:konfirmasi_wilkerstat/classes/api_server_handler.dart';
import 'package:konfirmasi_wilkerstat/classes/repositories/local_db/assignment_db_repository.dart';
import 'package:konfirmasi_wilkerstat/model/business.dart';
// import 'dart:io';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:crypto/crypto.dart';
// import 'package:encrypt/encrypt.dart' as encrypt;
// import 'package:path_provider/path_provider.dart';

class UpdatingBloc extends Bloc<UpdatingEvent, UpdatingState> {
  UpdatingBloc()
    : super(
        Initializing(
          data: UpdatingStateData(
            businesses: [],
            filteredBusinesses: [],
            sortBy: SortBy.nameAsc,
            summary: {},
          ),
        ),
      ) {
    on<Init>((event, emit) async {
      final businesses = await AssignmentDbRepository().getBusinessesBySls(
        event.slsId,
      );
      final sls = await AssignmentDbRepository().getSlsById(event.slsId);
      final summary = _getBusinessStatusSummary(businesses);

      // Apply default sorting
      final sortedBusinesses = _sortBusinesses(
        businesses: businesses,
        sortBy: state.data.sortBy,
      );

      emit(
        UpdatingState(
          data: state.data.copyWith(
            businesses: businesses,
            filteredBusinesses: sortedBusinesses,
            summary: summary,
            sls: sls,
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

      // Apply current sort to filtered results
      final sortedBusinesses = _sortBusinesses(
        businesses: filteredBusinesses,
        sortBy: state.data.sortBy,
      );

      emit(
        UpdatingState(
          data: state.data.copyWith(
            filteredBusinesses: sortedBusinesses,
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

      // Apply current sort to filtered results
      final sortedBusinesses = _sortBusinesses(
        businesses: filteredBusinesses,
        sortBy: state.data.sortBy,
      );

      final updatedData =
          event.status == null
              ? state.data.copyWith(
                filteredBusinesses: sortedBusinesses,
                clearSelectedStatusFilter: true,
              )
              : state.data.copyWith(
                filteredBusinesses: sortedBusinesses,
                selectedStatusFilter: event.status,
              );

      emit(UpdatingState(data: updatedData));
    });

    on<ClearFilters>((event, emit) async {
      // Apply current sort to all businesses (no filters)
      final sortedBusinesses = _sortBusinesses(
        businesses: state.data.businesses,
        sortBy: state.data.sortBy,
      );

      emit(
        UpdatingState(
          data: state.data.copyWith(
            filteredBusinesses: sortedBusinesses,
            clearKeywordFilter: true,
            clearSelectedStatusFilter: true,
          ),
        ),
      );
    });

    on<UpdateBusinessStatus>((event, emit) async {
      await AssignmentDbRepository().updateBusinessStatus(
        event.business.id,
        event.status.key,
      );

      // Update the business in both main and filtered lists
      final updatedBusinesses =
          state.data.businesses.map((business) {
            if (business.id == event.business.id) {
              return business.copyWith(status: event.status);
            }
            return business;
          }).toList();

      // Re-filter and sort the businesses
      final filteredBusinesses = _filterBusinesses(
        businesses: updatedBusinesses,
        keyword: state.data.keywordFilter,
        status: state.data.selectedStatusFilter,
      );

      final sortedBusinesses = _sortBusinesses(
        businesses: filteredBusinesses,
        sortBy: state.data.sortBy,
      );

      final summary = _getBusinessStatusSummary(updatedBusinesses);

      emit(
        UpdatingState(
          data: state.data.copyWith(
            businesses: updatedBusinesses,
            filteredBusinesses: sortedBusinesses,
            summary: summary,
          ),
        ),
      );
    });

    on<SendData>((event, emit) async {
      await ApiServerHandler.run(
        action: () async {
          // final user = AuthRepository().getUser();
          // final gDriveRequest =
          //     await ThirdPartyRepository().getGoogleDriveToken();
          // final gDriveToken = gDriveRequest['access_token'] as String;
          // final file = await _createJsonFile(
          //   user?.email ?? '',
          //   state.data.sls?.id ?? '',
          //   state.data.businesses.length,
          //   state.data.businesses,
          // );
          // final result = await ThirdPartyRepository().uploadFileToGoogleDrive(
          //   token: gDriveToken,
          //   filePath: file.path,
          //   fileName: '${state.data.sls?.id}.json',
          //   folderId: '1bKoOGTtL6niuogM6XNl1EpgizNgPeRQ6',
          // );
          // print(result);
        },
        onLoginExpired: (e) {},
        onDataProviderError: (e) {},
        onOtherError: (e) {},
      );
    });
  }

  // Future<File> _createJsonFile(
  //   String email,
  //   String slsId,
  //   int total,
  //   List<Business> businesses,
  // ) async {
  //   // 1. Get the app's document directory
  //   final directory = await getApplicationDocumentsDirectory();

  //   // 2. Create full file path
  //   final file = File('${directory.path}/$slsId.json');

  //   final data = <String, dynamic>{};
  //   data['user_id'] = email;
  //   data['wilayah'] = slsId;
  //   data['total'] = total;
  //   data['data'] =
  //       businesses.map((business) => business.toJsonForUpload()).toList();

  //   // 3. Encode data to JSON string
  //   final jsonString = jsonEncode(data);

  //   // 4. Write the JSON string to file
  //   return await file.writeAsString(jsonString);
  // }

  // String _encryptVillageId(String villageId) {
  //   final secret = 'TqubAjeim3xjLf5AR6KCGWUQRjR0PQdK';

  //   final hashed = sha256.convert(utf8.encode(secret)).toString();

  //   List<int> hexToBytes(String hex) {
  //     final result = <int>[];
  //     for (var i = 0; i < hex.length; i += 2) {
  //       result.add(int.parse(hex.substring(i, i + 2), radix: 16));
  //     }
  //     return result;
  //   }

  //   final keyBytes = hexToBytes(hashed.substring(0, 32)); // 16 bytes
  //   final ivSourceBytes = hexToBytes(
  //     hashed.substring(32, 48),
  //   ); // 8 bytes only (matches JS)

  //   // Pad IV to 16 bytes like CryptoJS does
  //   final ivPadded = Uint8List(16)
  //     ..setRange(0, ivSourceBytes.length, ivSourceBytes);

  //   final key = encrypt.Key(Uint8List.fromList(keyBytes));
  //   final iv = encrypt.IV(ivPadded);

  //   final encrypter = encrypt.Encrypter(
  //     encrypt.AES(key, mode: encrypt.AESMode.cbc),
  //   );

  //   final encrypted = encrypter.encrypt(villageId, iv: iv);

  //   return encrypted.base64
  //       .replaceAll('+', '-')
  //       .replaceAll('/', '_')
  //       .replaceAll(RegExp(r'=+$'), '');
  // }

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

  /// Helper method to sort businesses based on sort type
  List<Business> _sortBusinesses({
    required List<Business> businesses,
    required SortBy sortBy,
  }) {
    final sortedList = List<Business>.from(businesses);

    switch (sortBy) {
      case SortBy.nameAsc:
        sortedList.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case SortBy.nameDesc:
        sortedList.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case SortBy.statusAsc:
        // Sort by status: null (notConfirmed) -> found -> notFound
        sortedList.sort((a, b) {
          final aStatus = a.status;
          final bStatus = b.status;

          // Handle null status (notConfirmed)
          if (aStatus == null && bStatus == null) return 0;
          if (aStatus == null) return -1; // null comes first
          if (bStatus == null) return 1;

          // Compare status keys: notConfirmed(1) -> found(2) -> notFound(3)
          return aStatus.key.compareTo(bStatus.key);
        });
        break;
      case SortBy.statusDesc:
        // Sort by status: notFound -> found -> null (notConfirmed)
        sortedList.sort((a, b) {
          final aStatus = a.status;
          final bStatus = b.status;

          // Handle null status (notConfirmed)
          if (aStatus == null && bStatus == null) return 0;
          if (aStatus == null) return 1; // null comes last
          if (bStatus == null) return -1;

          // Compare status keys in descending order
          return bStatus.key.compareTo(aStatus.key);
        });
        break;
    }

    return sortedList;
  }

  /// Helper method to get business status summary from current state
  Map<int, int> _getBusinessStatusSummary(List<Business> businesses) {
    Map<int, int> statusCounts = {};
    for (var status in BusinessStatus.values) {
      statusCounts[status.key] = 0;
    }

    for (final business in businesses) {
      final statusKey = business.status?.key ?? 0; // Use 0 for null status
      statusCounts[statusKey] = (statusCounts[statusKey] ?? 0) + 1;
    }

    return statusCounts;
  }
}
