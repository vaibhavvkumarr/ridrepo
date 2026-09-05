class AppCurrency {
  final String code;
  final String symbol;
  final String currencyName;

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.currencyName,
  });
}

/// Currencies the manager can pick from in the profile menu.
const List<AppCurrency> kSupportedCurrencies = [
  AppCurrency(code: 'INR', symbol: '₹', currencyName: 'Indian Rupee'),
  AppCurrency(code: 'USD', symbol: '\$', currencyName: 'US Dollar'),
  AppCurrency(code: 'EUR', symbol: '€', currencyName: 'Euro'),
  AppCurrency(code: 'GBP', symbol: '£', currencyName: 'British Pound'),
  AppCurrency(code: 'AED', symbol: 'AED', currencyName: 'UAE Dirham'),
  AppCurrency(code: 'AUD', symbol: 'A\$', currencyName: 'Australian Dollar'),
  AppCurrency(code: 'CAD', symbol: 'C\$', currencyName: 'Canadian Dollar'),
  AppCurrency(code: 'JPY', symbol: '¥', currencyName: 'Japanese Yen'),
  AppCurrency(code: 'NPR', symbol: 'Rs.', currencyName: 'Nepalese Rupee'),
  AppCurrency(code: 'LKR', symbol: 'Rs.', currencyName: 'Sri Lankan Rupee'),
];

const AppCurrency kDefaultCurrency =
    AppCurrency(code: 'INR', symbol: '₹', currencyName: 'Indian Rupee');
