import '../models/insight_model.dart';
import '../services/api_service.dart';

/// Fetches money tips from dummyjson
class InsightRepository {
  const InsightRepository(this._api);

  final ApiService _api;

  Future<List<InsightModel>> getInsights({int limit = 6}) async {
    final List<Map<String, dynamic>> raw = await _api.fetchInsights(
      limit: limit,
    );

    return raw.map(InsightModel.fromJson).toList(growable: false);
  }
}
