import 'package:firebase_admob/firebase_admob.dart';
import 'package:billsappflutter/resources/Flavors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:billsappflutter/pages/HomePage.dart';
import 'package:billsappflutter/pages/BillsPage.dart';
import 'package:billsappflutter/pages/IncomePage.dart';

void main() {
  BuildEnvironment.init(flavor: BuildFlavor.free);
  assert(env != null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF6200EE),
        accentColor: Color(0xFF85bb65),
        //hintColor: Color(0xFF6200EE),
      ),
      home: MyBottomNavigationBar(),
    );
  }
}

class MyBottomNavigationBar extends StatefulWidget {
  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomePage(),
    BillsPage(),
    IncomePage(),
  ];

  void onTappedBar(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  static const String testDevices = 'Mobile_id';

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevices != null ? <String>[testDevices] : null,
    nonPersonalizedAds: true,
    keywords: <String>['Finance', 'Bills', 'Income'],
  );

  BannerAd _bannerAd;
  GlobalKey _titleKey = GlobalKey();
  String adUnitID;

  //double
  _getOffset() {
    final RenderBox renderBox = _titleKey.currentContext.findRenderObject();
    final titleHeight = renderBox.size.height;
    final titlePositionHeight = renderBox.localToGlobal(Offset.zero).dy;
    return titleHeight + titlePositionHeight;
  }

  BannerAd createBannerAd() {
    if (Platform.isAndroid) {
      adUnitID = "ca-app-pub-3969397110418936/1308433115";
    } else if (Platform.isIOS) {
      //TODO add iOS adUnitID
      // iOS-specific code
    }
    return BannerAd(
        adUnitId: adUnitID, //BannerAd.testAdUnitId,
        size: AdSize.fullBanner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("BannerAd $event");
        });
  }

  _setAds() {
    FirebaseAdMob.instance.initialize(appId: BannerAd.testAdUnitId);
    double offset = _getOffset();
    _bannerAd = createBannerAd()
      ..load()
      ..show(anchorType: AnchorType.top, anchorOffset: offset);
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setAds();
    });
    return new Scaffold(
      appBar: new AppBar(
        //key: _titleKey,
        title: new Text("BillsApp"),
        backgroundColor: Color(0xFF6200EE),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          onTap: onTappedBar,
          currentIndex: _currentIndex,
          selectedItemColor: Color(0xFF6200EE),
          items: [
            BottomNavigationBarItem(
                icon: new Icon(Icons.home), title: new Text("Home")),
            BottomNavigationBarItem(
                icon: new Icon(Icons.credit_card), title: new Text("Bills")),
            BottomNavigationBarItem(
                icon: new Icon(Icons.attach_money), title: new Text("Income")),
          ]),
    );
  }
}
