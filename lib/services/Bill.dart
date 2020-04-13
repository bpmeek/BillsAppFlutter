import 'package:jiffy/jiffy.dart';
import 'dart:math';

class Bill {

  DateTime dueDate;
  double dollarAmount;
  String name;
  int daysTillDue;

  Bill() {
    this.dueDate = new DateTime.now();
    this.dollarAmount = 0;
    this.name = "Name";
    this.daysTillDue = 0;
  }

  Map<String, dynamic> toJson() => {
    'dueDate' : this.dueDate.toIso8601String(),
    'dollarAmount' : this.dollarAmount,
    'name' : this.name,
    'daysTillDue' : this.daysTillDue,
  };

  Bill.fromJson(Map<String, dynamic> json)
      : dueDate = DateTime.parse(json['dueDate']),
      dollarAmount = json['dollarAmount'],
      name = json['name'],
      daysTillDue = json['daysTillDue'];

  Bill loadBill(Map jsonMap) {
    //Map billMap = jsonDecode(json);
    Bill bill = Bill.fromJson(jsonMap);
    return bill;
  }

  setDueDate(DateTime givenDueDate) {
    this.dueDate = givenDueDate;
  }

  setDollarAmount(double givenDollarAmt) {
    this.dollarAmount = givenDollarAmt.abs();
  }

  setName(String givenName) {
    this.name = givenName;
  }

  DateTime getNextDueDate() {
    DateTime today = new DateTime.now();
    if (this.dueDate.isBefore(today)) {
      while (this.dueDate.isBefore(today)) {
        this.dueDate = Jiffy(this.dueDate).add(months: 1);
      }
    }
    return this.dueDate;
  }

  int getDueDateInt() {
    return this.dueDate.day;
  }

  double getDollarAmount() {
    return this.dollarAmount;
  }

  String getName() {
    return this.name;
  }

  int getDaysTillDue() {
    int daysTillDue = 0;
    DateTime dueDate = this.dueDate;
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);
    int dateDiff = today.difference(dueDate).inDays;
    if (dateDiff == 0){
      daysTillDue = 0;
      this.daysTillDue = daysTillDue;
      return daysTillDue;
    }
    if (today.isAfter(dueDate)) {
      dueDate = this.getNextDueDate();
    }
    while (today.isBefore(dueDate)) {
      daysTillDue++;
      today = today.add(Duration(days: 1));
    }
    this.daysTillDue = daysTillDue;
    return daysTillDue;
  }

  String getDaysTillDueString() {
    int daysTillDue = this.getDaysTillDue();
    if (daysTillDue == 0) {
      return "Today";
    }
    else if (daysTillDue == 1) {
      return "Tomorrow";
    }
    else {
      return "Due in " + daysTillDue.toString() + " days";
    }
  }
}