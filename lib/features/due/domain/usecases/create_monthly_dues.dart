import '../repositories/due_repository.dart';

class CreateMonthlyDues {
  final DueRepository _repository;

  CreateMonthlyDues(this._repository);

  Future<void> call(double amount, String period, int dueDay) async {
    await _repository.createMonthlyDuesForActiveCustomers(
        amount, period, dueDay);
  }
}
