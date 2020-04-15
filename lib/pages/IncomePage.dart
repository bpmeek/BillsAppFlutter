import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:billsappflutter/services/PayInfo.dart';

class IncomePage extends StatefulWidget {
  @override
  _IncomePageState createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  PayInfo income = new PayInfo();
  final _datecontroller = TextEditingController();

  Future<PayInfo> loadData() {
    Future<PayInfo> futureIncome;
    futureIncome = income.loadIncome();
    return futureIncome;
  }

  @override
  void initState() {
    _datecontroller.addListener(() {
      _datecontroller.value = _datecontroller.value.copyWith();
    });
    //load data
    loadData().then((value) {
      income.setNextPayDate(value.getNextPayDate());
      _datecontroller.text = Jiffy(income.getNextPayDate()).yMMMd;
    });
    super.initState();
  }

  DateTime selectedDate = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2018, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        income.setNextPayDate(selectedDate);
        income.saveIncome(income);
        _datecontroller.text = Jiffy(selectedDate).yMMMd;
      });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Bills App"),
        backgroundColor: Color(0xFF6200EE),
      ),
      body: Stack(children: <Widget>[
        Center(
          child: Container(
            decoration: new BoxDecoration(boxShadow: [
              new BoxShadow(
                color: Colors.grey,
                blurRadius: 20.0,
              )
            ]),
            padding: EdgeInsets.all(10),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Income Frequency:",
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 14),
                          child: Text(
                            "Every 14 Days",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ]),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextField(
                        style: TextStyle(fontSize: 20),
                        controller: _datecontroller,
                        /*decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Next Pay Date'),*/
                        decoration: new InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Color(0xFF6200EE))),
                          labelText: 'Next Pay Date',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),),
            ),
          ),
        ),
      ]),
    );
  }
}
