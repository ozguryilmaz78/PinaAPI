import 'package:provider/provider.dart';
import '../../features/customer/data/datasources/customer_local_datasource.dart';
import '../../features/customer/data/repositories/customer_repository_impl.dart';
import '../../features/customer/domain/repositories/customer_repository.dart';
import '../../features/customer/domain/usecases/create_customer.dart';
import '../../features/customer/domain/usecases/get_all_customers.dart';
import '../../features/customer/domain/usecases/update_customer.dart';
import '../../features/customer/domain/usecases/delete_customer.dart';
import '../../features/customer/presentation/providers/customer_provider.dart';
import '../../features/payment/data/datasources/payment_local_datasource.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/domain/usecases/create_payment.dart';
import '../../features/payment/domain/usecases/get_all_payments.dart';
import '../../features/payment/domain/usecases/update_payment.dart';
import '../../features/payment/domain/usecases/delete_payment.dart';
import '../../features/payment/domain/usecases/search_payments.dart';
import '../../features/payment/domain/usecases/get_payments_by_customer.dart';
import '../../features/payment/domain/usecases/get_total_amount.dart';
import '../../features/payment/presentation/providers/payment_provider.dart';
import '../../features/due/data/datasources/due_local_datasource.dart';
import '../../features/due/data/repositories/due_repository_impl.dart';
import '../../features/due/domain/repositories/due_repository.dart';
import '../../features/due/domain/usecases/create_due.dart';
import '../../features/due/domain/usecases/get_all_dues.dart';
import '../../features/due/domain/usecases/update_due.dart';
import '../../features/due/domain/usecases/delete_due.dart';
import '../../features/due/domain/usecases/search_dues.dart';
import '../../features/due/domain/usecases/get_dues_by_customer.dart';
import '../../features/due/domain/usecases/get_total_due_amount.dart';
import '../../features/due/domain/usecases/get_total_paid_amount.dart';
import '../../features/due/domain/usecases/create_monthly_dues.dart';
import '../../features/due/presentation/providers/due_provider.dart';
import 'api_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final ApiService _apiService;
  late final CustomerLocalDataSource _customerLocalDataSource;
  late final CustomerRepository _customerRepository;
  late final CreateCustomer _createCustomer;
  late final GetAllCustomers _getAllCustomers;
  late final UpdateCustomer _updateCustomer;
  late final DeleteCustomer _deleteCustomer;
  late final CustomerProvider _customerProvider;

  // Payment services
  late final PaymentLocalDataSource _paymentLocalDataSource;
  late final PaymentRepository _paymentRepository;
  late final CreatePayment _createPayment;
  late final GetAllPayments _getAllPayments;
  late final UpdatePayment _updatePayment;
  late final DeletePayment _deletePayment;
  late final SearchPayments _searchPayments;
  late final GetPaymentsByCustomer _getPaymentsByCustomer;
  late final GetTotalAmount _getTotalAmount;
  late final PaymentProvider _paymentProvider;

  // Due services
  late final DueLocalDataSource _dueLocalDataSource;
  late final DueRepository _dueRepository;
  late final CreateDue _createDue;
  late final GetAllDues _getAllDues;
  late final UpdateDue _updateDue;
  late final DeleteDue _deleteDue;
  late final SearchDues _searchDues;
  late final GetDuesByCustomer _getDuesByCustomer;
  late final GetTotalDueAmount _getTotalDueAmount;
  late final GetTotalPaidAmount _getTotalPaidAmount;
  late final CreateMonthlyDues _createMonthlyDues;
  late final DueProvider _dueProvider;

  void init() {
    // Core services
    _apiService = ApiService();

    // Data sources - API üzerinden HTTP servisi kullan
    _customerLocalDataSource = CustomerLocalDataSourceImpl(_apiService);
    _paymentLocalDataSource = PaymentLocalDataSourceImpl(_apiService);
    _dueLocalDataSource = DueLocalDataSourceImpl(_apiService);

    // Repositories
    _customerRepository = CustomerRepositoryImpl(_customerLocalDataSource);
    _paymentRepository = PaymentRepositoryImpl(_paymentLocalDataSource);
    _dueRepository =
        DueRepositoryImpl(_dueLocalDataSource, _customerRepository);

    // Use cases
    _createCustomer = CreateCustomer(_customerRepository);
    _getAllCustomers = GetAllCustomers(_customerRepository);
    _updateCustomer = UpdateCustomer(_customerRepository);
    _deleteCustomer = DeleteCustomer(_customerRepository);

    // Payment use cases
    _createPayment = CreatePayment(_paymentRepository);
    _getAllPayments = GetAllPayments(_paymentRepository);
    _updatePayment = UpdatePayment(_paymentRepository);
    _deletePayment = DeletePayment(_paymentRepository);
    _searchPayments = SearchPayments(_paymentRepository);
    _getPaymentsByCustomer = GetPaymentsByCustomer(_paymentRepository);
    _getTotalAmount = GetTotalAmount(_paymentRepository);

    // Due use cases
    _createDue = CreateDue(_dueRepository);
    _getAllDues = GetAllDues(_dueRepository);
    _updateDue = UpdateDue(_dueRepository);
    _deleteDue = DeleteDue(_dueRepository);
    _searchDues = SearchDues(_dueRepository);
    _getDuesByCustomer = GetDuesByCustomer(_dueRepository);
    _getTotalDueAmount = GetTotalDueAmount(_dueRepository);
    _getTotalPaidAmount = GetTotalPaidAmount(_dueRepository);
    _createMonthlyDues = CreateMonthlyDues(_dueRepository);

    // Providers
    _customerProvider = CustomerProvider(
      createCustomer: _createCustomer,
      getAllCustomers: _getAllCustomers,
      updateCustomer: _updateCustomer,
      deleteCustomer: _deleteCustomer,
    );

    _paymentProvider = PaymentProvider(
      createPayment: _createPayment,
      getAllPayments: _getAllPayments,
      updatePayment: _updatePayment,
      deletePayment: _deletePayment,
      searchPayments: _searchPayments,
      getPaymentsByCustomer: _getPaymentsByCustomer,
      getTotalAmount: _getTotalAmount,
    );

    _dueProvider = DueProvider(
      createDue: _createDue,
      getAllDues: _getAllDues,
      updateDue: _updateDue,
      deleteDue: _deleteDue,
      searchDues: _searchDues,
      getDuesByCustomer: _getDuesByCustomer,
      getTotalDueAmount: _getTotalDueAmount,
      getTotalPaidAmount: _getTotalPaidAmount,
      createMonthlyDues: _createMonthlyDues,
    );
  }

  List<ChangeNotifierProvider> get providers => [
        ChangeNotifierProvider<CustomerProvider>.value(
            value: _customerProvider),
        ChangeNotifierProvider<PaymentProvider>.value(value: _paymentProvider),
        ChangeNotifierProvider<DueProvider>.value(value: _dueProvider),
      ];

  // Getters for direct access if needed
  CustomerProvider get customerProvider => _customerProvider;
  PaymentProvider get paymentProvider => _paymentProvider;
  DueProvider get dueProvider => _dueProvider;

  // API servisini başlat
  Future<void> initializeApi() async {
    await _apiService.initialize();
  }
}
