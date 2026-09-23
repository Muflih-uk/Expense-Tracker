class ApiEndpoints {
  static const String version = '/version/';
  static const String signup = '/auth/signup/';
  static const String signin = '/auth/signin/';
  static const String logout = '/auth/logout/';
  static const String token = '/token/';

  static const String users = '/users/';
  static String userById(int id) => '/users/$id/';

  static const String categories = '/categories/';
  static const String categoriesWithStats = '/categories/with_stats/';
  static String categoryById(int id) => '/categories/$id/';
  static String categoryTransactions(int id) => '/categories/$id/transactions/';

  static const String accounts = '/accounts/';
  static const String accountsWithBalance = '/accounts/with_balance/';
  static const String accountsSummary = '/accounts/summary/';
  static String accountById(int id) => '/accounts/$id/';
  static String accountTransactions(int id) => '/accounts/$id/transactions/';
  static String accountBalanceHistory(int id) =>
      '/accounts/$id/balance_history/';

  static const String transactions = '/transactions/';
  static const String transactionsSummary = '/transactions/summary/';
  static const String transactionsExpenses = '/transactions/expenses/';
  static const String transactionsIncome = '/transactions/income/';
  static const String transactionsByCategory = '/transactions/by_category/';
  static const String transactionsByAccount = '/transactions/by_account/';
  static const String transactionsDateRange = '/transactions/date_range/';
  static String transactionById(int id) => '/transactions/$id/';

  static const String dashboard = '/dashboard/';
  static const String dashboardQuickStats = '/dashboard/quick-stats/';
}
