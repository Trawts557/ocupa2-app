import 'package:ocupa2_app/core/networks/api_client.dart';
import 'package:ocupa2_app/models/contract.dart';

class ContractService {
  final ApiClient _api;
  ContractService(this._api);

  // GET /me/contracts
  Future<List<Contract>> getMyContracts() async {
    final data = await _api.get('/me/contracts');
    return (data as List).map((e) => Contract.fromJson(e)).toList();
  }
}