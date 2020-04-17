import 'package:billsappflutter/resources/Flavors.dart';
import 'package:billsappflutter/services/BillsGroup.dart';
import 'package:flutter/material.dart';
import 'package:billsappflutter/services/Bill.dart';
import 'package:flutter/foundation.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';

class BillEdit extends StatefulWidget {
  //declare field that holds bill
  final BillsGroup bills;
  final int index;

  BillEdit({Key key, @required this.bills, this.index}) : super(key: key);

  //
  @override
  _BillEditState createState() => _BillEditState();
}

class _BillEditState extends State<BillEdit> {
  final _datecontroller = TextEditingController();
  final _namecontroller = TextEditingController();
  final _amtcontroller = TextEditingController();

  final formatCurrency = new NumberFormat.simpleCurrency();
  DateTime selectedDate;
  double offsetPadding = 0;

  @override
  void initState() {
    Bill bill = new Bill();
    bill = widget.bills.get(widget.index);
    _datecontroller.addListener(() {
      _datecontroller.value = _datecontroller.value.copyWith();
    });

    selectedDate = bill.getNextDueDate();
    _namecontroller.text = bill.getName();
    _datecontroller.text = Jiffy(bill.getNextDueDate()).yMMMd;
    _amtcontroller.text = formatCurrency.format(bill.getDollarAmount());

    if (env.flavor == BuildFlavor.free) {
      offsetPadding = 60.0;
    }
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
        _datecontroller.text = Jiffy(selectedDate).yMMMd;
      });
  }

  void _removeBill(bill) {
    widget.bills.removeBill(bill);
  }

  final currencyToDouble = new NumberFormat("#,##0.00");

  void _addBill() {
    Bill bill = new Bill();
    String billName = _namecontroller.text;
    String billAmtString = _amtcontroller.text;
    billAmtString.replaceAll(new RegExp(","), '');
    var stringCheck = _amtcontroller.text;
    if (stringCheck[0] == "\$") {
      String billString = stringCheck.substring(1);
      billString = billString.replaceAll(new RegExp(","), '');
      _amtcontroller.text = billString;
    }
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
    //final width = MediaQuery.of(context).size.height;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("BillsApp"),
        backgroundColor: Color(0xFF6200EE),
      ),
      body: Container(
        padding: EdgeInsets.only(top: offsetPadding),
        decoration: new BoxDecoration(boxShadow: [
          new BoxShadow(
            color: Colors.grey,
            blurRadius: 20.0,
          )
        ]),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: SizedBox(
                height: length * .8,
                //width: width * .95,
                child: Stack(children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        TextField(
                          controller: _namecontroller,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF6200EE))),
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
                                  borderSide: const BorderSide(
                                      color: Color(0xFF6200EE))),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: SizedBox(
                              child: RaisedButton(
                                onPressed: () {
                                  _removeBill(widget.bills.get(widget.index));
                                  widget.bills.saveBills();
                                  Navigator.pop(context, widget.bills);
                                },
                                color: Color(0xFF85bb65),
                                textColor: Colors.white,
                                child: new Text("Delete"),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: SizedBox(
                              child: RaisedButton(
                                onPressed: () {
                                  _removeBill(widget.bills.get(widget.index));
                                  _addBill();
                                  widget.bills.saveBills();
                                  Navigator.pop(context, widget.bills);
                                },
                                color: Color(0xFF85bb65),
                                textColor: Colors.white,
                                child: new Text("Save"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
