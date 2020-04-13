import 'dart:convert';

import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PayInfo {
  int _payPeriods;
  int _payFrequency;
  DateTime _nextPayDate;
  DateTime _prevPayDate;
  DateTime _initialDate;

  PayInfo() {
    _payPeriods = 26;
    _payFrequency = 14;
    _initialDate = _getInitialDate();
    _nextPayDate = _getInitialDate();
    _prevPayDate = _getInitialDate();
  }

  DateTime _getInitialDate() {
    return DateTime(2019, 02, 06);
  }

  void setNextPayDate(DateTime givenDate) {
    this._initialDate = givenDate;
    this._nextPayDate = getNextPayDate();
    this._prevPayDate = getPrevPayDate();
  }

  DateTime getNextPayDate() {
    DateTime today = DateTime.now();
    DateTime initDate = this._initialDate;
    if (today.isBefore(initDate)) {
      this._nextPayDate = initDate;
    } else {
      while (this._nextPayDate.isBefore(today)) {
        this._nextPayDate = Jiffy(this._nextPayDate).add(days: _payFrequency);
      }
    }
    return this._nextPayDate;
  }

  DateTime getFirstPayDate() {
    DateTime firstPayDate = this._nextPayDate;
    DateTime today = DateTime.now();
    int thisYear = today.year;

    DateTime jan1 = DateTime(thisYear, 1, 1);

    while (firstPayDate.isAfter(jan1)) {
      firstPayDate = Jiffy(firstPayDate.toUtc()).subtract(days: _payFrequency);
    }
    firstPayDate = Jiffy(firstPayDate).add(days: _payFrequency);
    return firstPayDate;
  }

  DateTime getPrevPayDate() {
    return Jiffy(this._nextPayDate).subtract(days: _payFrequency);
  }

  int getPayPeriods() {
    return this._payPeriods;
  }

  int getPayFrequency() {
    return this._payFrequency;
  }

  Map<String, dynamic> toJson() => {
        '_payPeriods': this._payPeriods,
        '_payFrequency': this._payFrequency,
        '_initialDate': this._initialDate.toIso8601String(),
        '_nextPayDate': this._nextPayDate.toIso8601String(),
        '_prevPayDate': this._prevPayDate.toIso8601String(),
      };

  PayInfo.fromJson(Map<String, dynamic> json)
        : _payPeriods = json['_payPeriods'],
        _payFrequency = json['_payFrequency'],
        _initialDate = DateTime.parse(json['_initialDate']),
        _nextPayDate = DateTime.parse(json['_nextPayDate']),
        _prevPayDate = DateTime.parse(json['_prevPayDate']);

  void saveIncome(PayInfo income) async {
    //String json = jsonEncode(income.toJson());
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("incomeInfo", jsonEncode(income));
  }

  Future<PayInfo> loadIncome() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    String json = sharedPrefs.getString("incomeInfo");
    Map incomeMap = jsonDecode(json);
    PayInfo income = PayInfo.fromJson(incomeMap);
    return income;
  }
}
