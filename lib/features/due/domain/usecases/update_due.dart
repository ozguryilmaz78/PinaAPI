import '../entities/due.dart';
import '../repositories/due_repository.dart';

class UpdateDue {
  final DueRepository _repository;

  UpdateDue(this._repository);

  Future<void> call(Due due) async {
    await _repository.updateDue(due);
  }
}

