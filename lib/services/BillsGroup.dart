import 'dart:convert';

import 'package:billsappflutter/services/Bill.dart';
import 'package:billsappflutter/services/PayInfo.dart';
import 'package:jiffy/jiffy.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class BillsGroup {
  List<Bill> _billCart = new List<Bill>();

  void addBill(Bill bill) {
    //Adds new bill to array
    _billCart.add(bill);
  }

  void removeBill(Bill bill) {
    //removes bill from array
    if (_billCart.contains(bill)) {
      _billCart.remove(bill);
    }
  }

  int length() {
    return _billCart.length;
  }

  Bill get(int index) {
    return _billCart[index];
  }

  void set(Bill bill, int index){
    _billCart[index] = bill;
  }

  int index(Bill bill) {
    return _billCart.indexOf(bill);
  }

  BillsGroup sort() {
    BillsGroup sorted = new BillsGroup();
    _billCart.sort((a,b,) => a.daysTillDue.compareTo(b.daysTillDue));
    _billCart.forEach((element) {sorted.addBill(element);});
    return sorted;
  }

  double _getPerCheck(PayInfo income) {
    //returns amount due from each check
    double monthlyAmount;
    double annualAmount;
    double perCheckAmount;

    monthlyAmount = _getMonthly();

    annualAmount = monthlyAmount * 12;
    perCheckAmount = annualAmount / income.getPayPeriods();
    return perCheckAmount;
  }

  double _getMonthly() {
    //returns amount due from each check
    double monthlyAmount = 0;

    _billCart.forEach((element) {
      monthlyAmount += element.getDollarAmount();
    });

    return monthlyAmount;
  }

  List<double> _getDeposits(PayInfo income) {
    List<double> deposits = new List<double>();
    DateTime jan1;
    DateTime tempDate;
    DateTime futureDate;
    DateTime payDate;
    int year;
    int dayDiff;
    int payFrequency;
    double depositAmt;
    double perCheck;

    year = DateTime.now().year;
    jan1 = DateTime(year, 1, 1);
    payDate = income.getFirstPayDate();
    payDate = payDate.add(Duration(days: 1));

    tempDate = jan1;
    futureDate = jan1.add(Duration(days: 721));

    depositAmt = 0;
    payFrequency = income.getPayFrequency();
    perCheck = _getPerCheck(income);

    while (tempDate.isBefore(futureDate)) {
      dayDiff = tempDate.difference(payDate).inDays;
      if (dayDiff == 0) {
        payDate = payDate.add(Duration(days: payFrequency));
        depositAmt += perCheck;
      }
      deposits.add(depositAmt);
      //print("On $tempDate value is $depositAmt");
      tempDate = tempDate.add(Duration(days: 1));
    }
    return deposits;
  }

  List<double> _getPayments() {
    List<double> payments = new List<double>();
    DateTime jan1;
    DateTime tempDate;
    DateTime futureDate;
    int year;
    int todayInt;
    int daysInMonth;
    int dueDate;
    double amountPaid = 0;

    year = DateTime.now().year;
    jan1 = DateTime(year, 1, 1);

    tempDate = jan1;
    futureDate = jan1.add(Duration(days: 721));

    while (tempDate.isBefore(futureDate)) {
      todayInt = tempDate.day;
      daysInMonth = Jiffy(tempDate).daysInMonth;
      _billCart.forEach((element) {
        dueDate = element.getDueDateInt();
        dueDate = min(dueDate, daysInMonth);
        if (todayInt == dueDate) {
          amountPaid += element.getDollarAmount();
        }
      });
      payments.add(amountPaid);

      //print("On $tempDate value is $amountPaid");

      tempDate = tempDate.add(Duration(days: 1));
    }
    return payments;
  }

  List getAmountNeededNow(PayInfo income) {
    //Stopwatch stopwatch = new Stopwatch()..start();
    double amountNeeded;
    double amountToday = 0;
    double minValue = 0;
    double perCheck;
    DateTime jan1;
    DateTime today;
    int year;
    int dayDiff;

    List<double> payments = _getPayments();
    List<double> deposits = _getDeposits(income);

    perCheck = _getPerCheck(income);

    today = new DateTime.now();
    year = today.year;
    jan1 = new DateTime(year, 1, 1);

    dayDiff = today.difference(jan1).inDays;

    for (int i = 0; i <= 720; i++) {
      minValue = min((deposits[i] - payments[i]), minValue);
      if (i == dayDiff) {
        amountToday = deposits[i] - payments[i];
      }
    }
    amountNeeded = minValue.abs();
    amountToday += amountNeeded;
    //print("Executed in ${stopwatch.elapsed}");
    return [amountToday, perCheck];
  }

  void saveBills() async {
    String json = jsonEncode(_billCart.map((e) => e.toJson()).toList());
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("billsInfo", json);
  }

  Future<BillsGroup> loadBills() async {
    BillsGroup futureGroup = new BillsGroup();
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    String json = sharedPrefs.getString("billsInfo");
    List<dynamic> jsonList = jsonDecode(json);
    jsonList.forEach((jsonMap) {
      Bill bill = new Bill();
      bill = bill.loadBill(jsonMap);
      futureGroup.addBill(bill);
    });
    return futureGroup;
  }
}
