class ApiEndpoints {
  static const String version = '/api/version/';
  static const String signup = '/api/auth/signup/';
  static const String signin = '/api/auth/signin/';
  static const String logout = '/api/auth/logout/';
  static const String token = '/api/token/';

  static const String users = '/api/users/';
  static String userById(int id) => '/api/users/$id/';

  static const String categories = '/api/categories/';
  static const String categoriesWithStats = '/api/categories/with_stats/';
  static String categoryById(int id) => '/api/categories/$id/';
  static String categoryTransactions(int id) =>
      '/api/categories/$id/transactions/';

  static const String accounts = '/api/accounts/';
  static const String accountsWithBalance = '/api/accounts/with_balance/';
  static const String accountsSummary = '/api/accounts/summary/';
  static String accountById(int id) => '/api/accounts/$id/';
  static String accountTransactions(int id) =>
      '/api/accounts/$id/transactions/';
  static String accountBalanceHistory(int id) =>
      '/api/accounts/$id/balance_history/';

  static const String transactions = '/api/transactions/';
  static const String transactionsSummary = '/api/transactions/summary/';
  static const String transactionsExpenses = '/api/transactions/expenses/';
  static const String transactionsIncome = '/api/transactions/income/';
  static const String transactionsByCategory = '/api/transactions/by_category/';
  static const String transactionsByAccount = '/api/transactions/by_account/';
  static const String transactionsDateRange = '/api/transactions/date_range/';
  static String transactionById(int id) => '/api/transactions/$id/';

  static const String dashboard = '/api/dashboard/';
  static const String dashboardQuickStats = '/api/dashboard/quick-stats/';
}
