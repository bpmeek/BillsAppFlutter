import 'package:billsappflutter/resources/Flavors.dart';
import 'package:billsappflutter/services/BillsGroup.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';
import 'package:billsappflutter/services/Bill.dart';

class BillNew extends StatefulWidget {
  //declare field that holds BillsGroup
  final BillsGroup bills;

  BillNew({Key key, @required this.bills}) : super(key: key);

  //

  @override
  _BillNewState createState() => _BillNewState();
}

class _BillNewState extends State<BillNew> {
  BillsGroup bills = new BillsGroup();

  final _datecontroller = TextEditingController();
  final _namecontroller = TextEditingController();
  final _amtcontroller = TextEditingController();

  final formatCurrency = new NumberFormat.simpleCurrency();

  double offsetPadding = 0.0;

  @override
  void initState() {
    _datecontroller.addListener(() {
      _datecontroller.value = _datecontroller.value.copyWith();
    });

    if (env.flavor == BuildFlavor.free) {
      offsetPadding = 60.0;
    }
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
        _datecontroller.text = Jiffy(selectedDate).yMMMd;
      });
  }

  void _addBill() {
    Bill bill = new Bill();
    String billName = _namecontroller.text;
    double billAmount = double.parse(_amtcontroller.text);

    if (billName != null && billAmount != null) {
      bill.setName(_namecontroller.text);
      bill.setDueDate(selectedDate);
      bill.setDollarAmount(billAmount);
      widget.bills.addBill(bill);
    }
  }

  @override
  Widget build(BuildContext context) {
    final length = MediaQuery.of(context).size.height;
    //final width = MediaQuery.of(context).size.width;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("BillsApp"),
        backgroundColor: Color(0xFF6200EE),
      ),
      body: Center(
        child: Container(
          decoration: new BoxDecoration(boxShadow: [
            new BoxShadow(
              color: Colors.grey,
              blurRadius: 20.0,
            )
          ]),
          child: Padding(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 60, top: 60),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Stack(children: <Widget>[
                Container(
                  //color: Color(0xFF85bb65).withAlpha(90),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      TextField(
                        controller: _namecontroller,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xFF6200EE))),
                            labelText: 'Name'),
                      ),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _datecontroller,
                            //keyboardType: TextInputType.datetime,
                            decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(0xFF6200EE))),
                                labelText: 'Next Due Date'),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _amtcontroller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xFF6200EE))),
                            labelText: 'Amount Due'),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(4.0),
                        ),
                        onPressed: () {
                          _addBill();
                          widget.bills.saveBills();
                          Navigator.pop(context, bills);
                        },
                        color: Color(0xFF85bb65),
                        textColor: Colors.white,
                        child: new Text("Save"),
                      ),
                    ),
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
