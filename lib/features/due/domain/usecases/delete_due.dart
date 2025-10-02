import '../repositories/due_repository.dart';

class DeleteDue {
  final DueRepository _repository;

  DeleteDue(this._repository);

  Future<void> call(String id) async {
    await _repository.deleteDue(id);
  }
}

