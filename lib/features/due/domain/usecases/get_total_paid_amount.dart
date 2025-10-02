import '../repositories/due_repository.dart';

class GetTotalPaidAmount {
  final DueRepository _repository;

  GetTotalPaidAmount(this._repository);

  Future<double> call() async {
    return await _repository.getTotalPaidAmount();
  }
}

