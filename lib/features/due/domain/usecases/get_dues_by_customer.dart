import '../entities/due.dart';
import '../repositories/due_repository.dart';

class GetDuesByCustomer {
  final DueRepository _repository;

  GetDuesByCustomer(this._repository);

  Future<List<Due>> call(String customerId) async {
    return await _repository.getDuesByCustomer(customerId);
  }
}

