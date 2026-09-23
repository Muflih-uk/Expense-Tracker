import 'package:expense_tracker/core/network/dio_client.dart';
import 'package:expense_tracker/core/storage/local_storage.dart';
import 'package:expense_tracker/features/accounts/data/datasources/account_remote_datasource.dart';
import 'package:expense_tracker/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:expense_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/auth/domain/usecases/auth_usecases.dart';
import 'package:expense_tracker/features/auth/presentation/auth_bloc.dart';
import 'package:expense_tracker/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:expense_tracker/features/categories/data/repositories/category_repository_impl.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:expense_tracker/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:expense_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:expense_tracker/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:expense_tracker/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/features/users/data/datasources/user_remote_datasource.dart';
import 'package:expense_tracker/features/users/data/repositories/user_repository_impl.dart';
import 'package:expense_tracker/features/users/domain/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

late LocalStorage localStorage;
late DioClient dioClient;

late AuthRepository authRepository;
late UserRepository userRepository;
late CategoryRepository categoryRepository;
late AccountRepository accountRepository;
late TransactionRepository transactionRepository;
late DashboardRepository dashboardRepository;

late AuthBloc authBloc;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  localStorage = LocalStorage(prefs);
  dioClient = DioClient(localStorage: localStorage);

  final authRemote = AuthRemoteDataSource(dioClient);
  final userRemote = UserRemoteDataSource(dioClient);
  final categoryRemote = CategoryRemoteDataSource(dioClient);
  final accountRemote = AccountRemoteDataSource(dioClient);
  final transactionRemote = TransactionRemoteDataSource(dioClient);
  final dashboardRemote = DashboardRemoteDataSource(dioClient);

  authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemote,
    localStorage: localStorage,
  );
  userRepository = UserRepositoryImpl(userRemote);
  categoryRepository = CategoryRepositoryImpl(categoryRemote);
  accountRepository = AccountRepositoryImpl(accountRemote);
  transactionRepository = TransactionRepositoryImpl(transactionRemote);
  dashboardRepository = DashboardRepositoryImpl(dashboardRemote);

  authBloc = AuthBloc(
    signIn: SignIn(authRepository),
    signUp: SignUp(authRepository),
    signOut: SignOut(authRepository),
    restoreSession: RestoreSession(authRepository),
  );

  dioClient.onUnauthorized = () => authBloc.add(const AuthSessionExpired());
  authBloc.add(const AuthStarted());
}