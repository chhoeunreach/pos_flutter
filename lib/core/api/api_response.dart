import 'package:equatable/equatable.dart';

class ApiResponse<T> extends Equatable {
  final bool success;
  final String message;
  final T? data;
  final Map<String, List<String>>? errors;

  const ApiResponse({
    required this.success,
    this.message = '',
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: json['errors'] != null
          ? (json['errors'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, List<String>.from(value as List)),
            )
          : null,
    );
  }

  bool get isSuccess => success;

  @override
  List<Object?> get props => [success, message, data, errors];
}

class PaginatedResponse<T> extends Equatable {
  final bool success;
  final String message;
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;
  final String? nextPageUrl;
  final String? prevPageUrl;

  const PaginatedResponse({
    required this.success,
    this.message = '',
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 20,
    this.total = 0,
    this.from,
    this.to,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final rawData = json['data'];
    final paginatorData =
        rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};
    final dataList = <T>[];
    final items = rawData is List ? rawData : paginatorData['data'];
    if (items is List) {
      for (final item in items) {
        dataList.add(fromJsonT(item));
      }
    }
    return PaginatedResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: dataList,
      currentPage: paginatorData['current_page'] as int? ?? 1,
      lastPage: paginatorData['last_page'] as int? ?? 1,
      perPage: paginatorData['per_page'] as int? ?? 20,
      total: paginatorData['total'] as int? ?? 0,
      from: paginatorData['from'] as int?,
      to: paginatorData['to'] as int?,
      nextPageUrl: paginatorData['next_page_url'] as String?,
      prevPageUrl: paginatorData['prev_page_url'] as String?,
    );
  }

  bool get isSuccess => success;
  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [
        success,
        message,
        data,
        currentPage,
        lastPage,
        perPage,
        total,
      ];
}
