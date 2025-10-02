import '../entities/due.dart';
import '../repositories/due_repository.dart';

class GetAllDues {
  final DueRepository _repository;

  GetAllDues(this._repository);

  Future<List<Due>> call() async {
    return await _repository.getAllDues();
  }
}

