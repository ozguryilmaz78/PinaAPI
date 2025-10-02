import '../repositories/due_repository.dart';

class GetTotalDueAmount {
  final DueRepository _repository;

  GetTotalDueAmount(this._repository);

  Future<double> call() async {
    return await _repository.getTotalDueAmount();
  }
}

