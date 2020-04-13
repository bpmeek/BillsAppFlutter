import 'package:billsappflutter/services/BillsGroup.dart';
import 'package:billsappflutter/services/PayInfo.dart';
import 'package:flutter/material.dart';
import 'package:billsappflutter/services/Bill.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var bills = new BillsGroup();
  var income = new PayInfo();

  List<dynamic> calculatedFields = new List<dynamic>(2);

  final formatCurrency = new NumberFormat.simpleCurrency();

  Future<BillsGroup> _loadData() {
    Future<BillsGroup> futureBills;
    if (bills.length() != 0) {
      return futureBills;
    }
    futureBills = bills.loadBills();
    futureBills.then((value) {
      for (int i = 0; i < value.length(); i++) {
        Bill bill = new Bill();
        bill.dueDate = value.get(i).dueDate;
        bill.dollarAmount = value.get(i).dollarAmount;
        bill.name = value.get(i).name;
        bill.daysTillDue = value.get(i).daysTillDue;
        bills.addBill(bill);
      }
    });
    Future<PayInfo> futureIncome;
    futureIncome = income.loadIncome();
    futureIncome.then((value) {
      income.setNextPayDate(value.getNextPayDate());
    });
    return futureBills;
  }

  @override
  Widget build(BuildContext context) {
    final length = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: new AppBar(
        title: new Text("BillsApp"),
        backgroundColor: Color(0xFF6200EE),
      ),
      body: Container(
        child: FutureBuilder(
          future: _loadData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Container(child: Center(child: Text("Add Bills and Income")));
            } else {
              calculatedFields = bills.getAmountNeededNow(income);
              return Container(
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      height: length * 0.15,
                    ),
                    Container(
                      decoration: new BoxDecoration(
                          boxShadow: [
                        new BoxShadow(
                          color: Colors.grey[400],
                          blurRadius: 10.0,
                        )
                      ]),
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                        child: Card(
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                height: length * .20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      height: length * .025,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Text(
                                        "Amount Needed Now",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 20, top: 4),
                                      child: Text(
                                        "This is the amount you must have set aside now",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Text(
                                        formatCurrency
                                            .format(calculatedFields[0]),
                                        style: TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: new BoxDecoration(boxShadow: [
                        new BoxShadow(
                          color: Colors.grey,
                          blurRadius: 20.0,
                        )
                      ]),
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Card(
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                height: length * .20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      height: length * .025,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Text(
                                        "Amount Needed Per Check",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 20, top: 4),
                                      child: Text(
                                        "This is the amount to set aside per check",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Text(
                                        formatCurrency
                                            .format(calculatedFields[1]),
                                        style: TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
