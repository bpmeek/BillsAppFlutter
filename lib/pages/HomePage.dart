import 'package:firebase_admob/firebase_admob.dart';
import 'package:billsappflutter/resources/Flavors.dart';
import 'package:billsappflutter/services/BillsGroup.dart';
import 'package:billsappflutter/services/PayInfo.dart';
import 'package:flutter/material.dart';
import 'package:billsappflutter/services/Bill.dart';
import 'package:intl/intl.dart';

const String testDevices = 'Mobile_id';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevices != null ? <String>[testDevices] : null,
    nonPersonalizedAds: true,
    keywords: <String>['Finance', 'Bills', 'Income'],
  );

  BannerAd _bannerAd;
  GlobalKey _titleKey = GlobalKey();

  //double
  _getOffset() {
    final RenderBox renderBox = _titleKey.currentContext.findRenderObject();
    final titleHeight = renderBox.size.height;
    final titlePositionHeight = renderBox.localToGlobal(Offset.zero).dy;
    return titleHeight + titlePositionHeight;
  }

  BannerAd createBannerAd() {
    return BannerAd(
        //TODO change adUnitId
        adUnitId: BannerAd.testAdUnitId,
        size: AdSize.fullBanner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("BannerAd $event");
        });
  }

  /*@override
  void initState() {
    //TODO change appId
    FirebaseAdMob.instance.initialize(appId: BannerAd.testAdUnitId);
    double offset = _getOffset();
    if (env.flavor == BuildFlavor.free) {
        _bannerAd = createBannerAd()
        ..load()
        ..show(anchorType: AnchorType.top, anchorOffset: offset);
        }
    super.initState();
  }*/

  _setAds() {
      FirebaseAdMob.instance.initialize(appId: BannerAd.testAdUnitId);
      double offset = _getOffset();
      if (env.flavor == BuildFlavor.free) {
        _bannerAd = createBannerAd()
          ..load()
          ..show(anchorType: AnchorType.top, anchorOffset: offset);
      }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  var bills = new BillsGroup();
  var income = new PayInfo();

  List<dynamic> calculatedFields = new List<dynamic>(2);

  final formatCurrency = new NumberFormat.simpleCurrency();

  String amtNowTitle = "Amount needed now";
  String amtNowDesc =
      "If you use a secondary account just for bills this is the amount that should be in it today. This is to make sure all future expenses are covered, while minimizing the per paycheck amount. It will adjust automatically for payments and deposits.";
  String amtPerTitle = "Amount Needed Per Check";
  String amtPerDesc =
      "This is the minimum amount required from each paycheck to evenly distribute your bills across your paychecks.";

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
      income.setPayFrequency(value.getPayFrequency());
    });
    return futureBills;
  }

  _loadNeededNowInfo(String title, String desc) {
    final length = MediaQuery.of(context).size.height;
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
        builder: (context) => GestureDetector(
            onTap: () {
              overlayEntry.remove();
            },
            child: Stack(
              children: <Widget>[
                Opacity(
                    opacity: .7,
                    child: Container(
                      color: Colors.grey[500],
                    )),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: SizedBox(
                      height: length * .3,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: length * .025,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 15),
                                child: Text(
                                  title,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20, top: 4, right: 20),
                                child: Text(desc,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    softWrap: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )));
    overlayState.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      _setAds();
    });*/
    final length = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        child: FutureBuilder(
          future: _loadData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Container(
                  child: Center(child: Text("Add Bills and Income")));
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
                      decoration: new BoxDecoration(boxShadow: [
                        new BoxShadow(
                          color: Colors.grey[400],
                          blurRadius: 10.0,
                        )
                      ]),
                      child: Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 5),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: InkWell(
                            splashColor: Color(0xFF85bb65),
                            onTap: () {
                              _loadNeededNowInfo(amtNowTitle, amtNowDesc);
                            },
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  height: length * .20,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: length * .025,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 15),
                                        child: Text(
                                          amtNowTitle,
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 20, top: 4),
                                        child: Text(
                                          "This is how much you should have set aside",
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: InkWell(
                            splashColor: Color(0xFF85bb65),
                            onTap: () {
                              _loadNeededNowInfo(amtPerTitle, amtPerDesc);
                            },
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  height: length * .20,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: length * .025,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 15),
                                        child: Text(
                                          amtPerTitle,
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
