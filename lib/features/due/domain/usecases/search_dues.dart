import '../entities/due.dart';
import '../repositories/due_repository.dart';

class SearchDues {
  final DueRepository _repository;

  SearchDues(this._repository);

  Future<List<Due>> call(String query) async {
    return await _repository.searchDues(query);
  }
}

