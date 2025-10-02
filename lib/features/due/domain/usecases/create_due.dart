import '../entities/due.dart';
import '../repositories/due_repository.dart';

class CreateDue {
  final DueRepository _repository;

  CreateDue(this._repository);

  Future<void> call(Due due) async {
    await _repository.createDue(due);
  }
}

