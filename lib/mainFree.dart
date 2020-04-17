import 'package:billsappflutter/resources/Flavors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billsappflutter/pages/HomePage.dart';
import 'package:billsappflutter/pages/BillsPage.dart';
import 'package:billsappflutter/pages/IncomePage.dart';

void main() {
  //TODO figure out how to fix build flavors
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
  void initState(){
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
