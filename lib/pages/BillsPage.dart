import 'package:billsappflutter/pages/BillNew.dart';
import 'package:billsappflutter/pages/BillEdit.dart';
import 'package:billsappflutter/services/BillsGroup.dart';
import 'package:billsappflutter/services/Bill.dart';
import 'package:flutter/material.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:intl/intl.dart';

class BillsPage extends StatefulWidget {
  @override
  _BillsPageState createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  final Duration animationDuration = Duration(milliseconds: 200);
  final Duration delay = Duration(milliseconds: 200);
  GlobalKey rectGetterKey = RectGetter.createGlobalKey();
  Rect rect;

  BillsGroup bills = new BillsGroup();

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
    return futureBills;
  }

  void _navigateAndReturnNewBill() async {
    setState(() => rect = RectGetter.getRectFromKey(rectGetterKey));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() =>
          rect = rect.inflate(1.3 * MediaQuery.of(context).size.longestSide));
      Future.delayed(animationDuration + delay, _goToNextPage);
    });
  }

  void _goToNextPage() async {
    final result = await Navigator.of(context).push(FadeRouteBuilder(
        page: BillNew(
      bills: bills,
    )));
    if (result != null) {
      bills = result;
    }
    setState(() => rect = null);
  }

  void _navigateAndReturnEditBill(BillsGroup bills, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BillEdit(
                bills: bills,
                index: index,
              )),
    );

      bills = result;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        Scaffold(
            appBar: new AppBar(
              title: new Text("Bills App"),
              backgroundColor: Color(0xFF6200EE),
            ),
            body: Container(
              child: FutureBuilder(
                future: _loadData(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        child: Center(child: Text("Add bills below")));
                  } else {
                    return ListView.builder(
                      itemCount: bills.length(),
                      itemBuilder: (context, index) {
                        return Container(
                            decoration: new BoxDecoration(boxShadow: [
                              new BoxShadow(
                                color: Colors.grey[400],
                                blurRadius: 10.0,
                              )
                            ]),
                            child: Card(
                              child: InkWell(
                                splashColor: Color(0xFF85bb65),
                                onTap: () {
                                  _navigateAndReturnEditBill(bills, index);
                                },
                                child: Stack(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 15, top: 10),
                                              child: Text(
                                                bills.get(index).getName(),
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 20, bottom: 10),
                                              child: Text(
                                                bills
                                                    .get(index)
                                                    .getDaysTillDueString(),
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                              child: Text(
                                                '${formatCurrency.format(bills.get(index).getDollarAmount())}',
                                                //bills[index].getDollarAmount().toString(),
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ));
                      },
                    );
                  }
                },
              ),
            ),
            floatingActionButton: RectGetter(
                key: rectGetterKey,
                child: FloatingActionButton(
                  onPressed: () {
                    _navigateAndReturnNewBill();
                    //_navigateAndReturnNewBill(context, bills);
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  backgroundColor: Color(0xFF85bb65),
                ))),
        _ripple(),
      ],
    );
  }

  Widget _ripple() {
    if (rect == null) {
      return Container();
    }
    return AnimatedPositioned(
      duration: animationDuration,
      left: rect.left,
      right: MediaQuery.of(context).size.width - rect.right,
      top: rect.top,
      bottom: MediaQuery.of(context).size.height - rect.bottom,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF85bb65),
        ),
      ),
    );
  }
}

class FadeRouteBuilder<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeRouteBuilder({@required this.page})
      : super(
          pageBuilder: (context, animation1, animation2) => page,
          transitionsBuilder: (context, animation1, animation2, child) {
            return FadeTransition(opacity: animation1, child: child);
          },
        );
}
