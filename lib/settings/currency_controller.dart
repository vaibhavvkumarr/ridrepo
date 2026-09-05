import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_currency.dart';

/// Which currency amounts and price fields are displayed in throughout the
/// app. Persisted so the choice survives across launches. Defaults to INR.
class CurrencyController {
  CurrencyController._();
  static final CurrencyController instance = CurrencyController._();

  static const _prefsKey = 'currency_code';

  final ValueNotifier<AppCurrency> currency =
      ValueNotifier(kDefaultCurrency);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == null) {
      currency.value = kDefaultCurrency;
      return;
    }
    currency.value = kSupportedCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => kDefaultCurrency,
    );
  }

  Future<void> setCurrency(AppCurrency selected) async {
    currency.value = selected;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, selected.code);
  }
}
