import 'package:flutter/material.dart';

class InfoNeededNow extends StatelessWidget {
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
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(),
                        ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
