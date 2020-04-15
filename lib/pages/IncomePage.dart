import 'package:billsappflutter/services/PayFrequency.dart';
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
  DateTime selectedDate = DateTime.now();

  List<PayFrequency> _incomeList = <PayFrequency>[
    PayFrequency("Every 7 days", 7),
    PayFrequency('Every 14 days', 14)
  ];

  PayFrequency _currentSelectedValue;

  Future<PayInfo> _loadData() {
    Future<PayInfo> futureIncome;
    futureIncome = income.loadIncome();
    futureIncome.then((value) {
      income.setPayFrequency(value.getPayFrequency());
      income.setNextPayDate(value.getNextPayDate());
      int payFrequency = income.getPayFrequency();
      _incomeList.forEach((value) {
        if (value.payFrequency == payFrequency) {
          _currentSelectedValue = value;
        }
      });
      _datecontroller.text = Jiffy(income.getNextPayDate()).yMMMd;
    });
    return futureIncome;
  }

  @override
  void initState() {
    _datecontroller.addListener(() {
      _datecontroller.value = _datecontroller.value.copyWith();
    });
    super.initState();
  }

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
        body: Container(
          child: FutureBuilder(
            future: _loadData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return Stack(children: <Widget>[
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
                                  FormField<String>(
                                      builder: (FormFieldState<String> state) {
                                    return InputDecorator(
                                      decoration: InputDecoration(
                                          enabledBorder:
                                              const OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color:
                                                          Color(0xFF6200EE))),
                                          labelText: 'Income Frequency'),
                                      isEmpty: _currentSelectedValue == '',
                                      child: DropdownButton<PayFrequency>(
                                        value: _currentSelectedValue,
                                        isDense: false,
                                        onChanged: (PayFrequency newValue) {
                                          setState(() {
                                            _currentSelectedValue = newValue;
                                            income.setPayFrequency(
                                                _currentSelectedValue
                                                    .payFrequency);
                                            income.saveIncome(income);
                                          });
                                        },
                                        items: _incomeList
                                            .map((PayFrequency value) {
                                          return DropdownMenuItem<PayFrequency>(
                                            value: value,
                                            child: Text(
                                              value.payStr,
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  }),
                                ]),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: TextField(
                                  style: TextStyle(fontSize: 20),
                                  controller: _datecontroller,
                                  decoration: new InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Color(0xFF6200EE))),
                                    labelText: 'Next Pay Date',
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ]);
            },
          ),
        ));
  }
}
