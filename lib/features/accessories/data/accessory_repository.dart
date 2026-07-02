import '../../../core/api/api_client.dart';

class AccessoryRepository {
  final ApiClient _api;

  AccessoryRepository(this._api);

  static const _basePath = '../pos/accessory/mobile/accessories';

  Future<List<Map<String, dynamic>>> getAll({String? search}) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final res = await _api.getPaginated<Map<String, dynamic>>(
      _basePath,
      queryParams: params.isNotEmpty ? params : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return res.data;
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final res = await _api.get<Map<String, dynamic>>(
      '$_basePath/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final res = await _api.post<Map<String, dynamic>>(
      _basePath,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    final res = await _api.put<Map<String, dynamic>>(
      '$_basePath/$id',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }

  Future<void> delete(int id) async {
    await _api.delete('$_basePath/$id');
  }
}
