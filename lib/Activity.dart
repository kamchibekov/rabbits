import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Authenticate.dart';
import 'dart:math';

class Activity extends StatefulWidget {
  Activity({Key? key}) : super(key: key);

  @override
  _Activity createState() => _Activity();
}

class _Activity extends State<Activity> with SingleTickerProviderStateMixin {
  CollectionReference history =
      FirebaseFirestore.instance.collection('history');
  final Stream<QuerySnapshot> historyStream = FirebaseFirestore.instance
      .collection('history')
      .orderBy('date', descending: true)
      .snapshots();

  CollectionReference shopping =
      FirebaseFirestore.instance.collection('shopping');
  final Stream<QuerySnapshot> shoppingStream = FirebaseFirestore.instance
      .collection('shopping')
      .orderBy('date', descending: true)
      .snapshots();

  CollectionReference statistics =
      FirebaseFirestore.instance.collection('statistics');
  final Stream<QuerySnapshot> statisticsStream = FirebaseFirestore.instance
      .collection('statistics')
      .orderBy('date', descending: true)
      .snapshots();

  late TabController _tabController;
  final moneySpentController = TextEditingController();

  static const List<Tab> tabs = [
    Tab(icon: Icon(Icons.money_rounded)),
    Tab(icon: Icon(Icons.shopping_cart_rounded)),
    Tab(icon: Icon(Icons.query_stats_rounded)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
    if (null == FirebaseAuth.instance.currentUser) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Authenticate()));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    moneySpentController.dispose();
    super.dispose();
  }

  Random rand = new Random();
  @override
  Widget build(BuildContext context) {
    String date;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          child: Icon(Icons.add),
          onPressed: () => {
            if (null != FirebaseAuth.instance.currentUser)
              {
                if (_tabController.index == 0)
                  {
                    date = DateTime.now().toString(),
                    history.add({
                      'name': FirebaseAuth.instance.currentUser!.displayName,
                      'money_amount': '10,000',
                      'date': date.substring(0, date.length - 7)
                    })
                  },
                if (_tabController.index == 1)
                  {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Money spent'),
                        content: new TextField(
                            autofocus: true,
                            controller: moneySpentController,
                            keyboardType: TextInputType.numberWithOptions()),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => {
                              Navigator.pop(context, 'OK'),
                              date = DateTime.now().toString(),
                              shopping.add({
                                'name': FirebaseAuth
                                    .instance.currentUser!.displayName,
                                'money_amount': moneySpentController.text,
                                'date': date.substring(0, date.length - 7)
                              })
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                    moneySpentController.text = ''
                  }
              }
          },
        ),
        appBar: new AppBar(
          title: const Text('Food money list'),
          actions: <Widget>[
            TextButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut().then((value) =>
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => Authenticate()))),
              icon: Icon(Icons.logout),
              label: Text(''),
              style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white)),
            )
          ],
          bottom: new TabBar(
            controller: _tabController,
            tabs: tabs,
          ),
        ),
        body: new TabBarView(
          controller: _tabController,
          children: [
            getHistory(history, historyStream),
            getHistory(shopping, shoppingStream),
            getHistory(statistics, statisticsStream),
          ],
        ));
  }
}

getHistory(
    CollectionReference collection, Stream<QuerySnapshot<Object?>>? stream) {
  Random rand = new Random();
  return StreamBuilder<QuerySnapshot>(
    stream: stream,
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      List bgColors = [
        0xff019CAA,
        0xff6306B8,
        0xffFF4100,
        0xff065EB3,
        0xffFF7400,
        0xffAD00B3,
        0xff0658B3
      ];
      int index = 0;
      return ListView(
        children: !snapshot.hasData
            ? [Text("Loading...")]
            : snapshot.data!.docs.map((DocumentSnapshot document) {
                index++;
                Color tileColor = Color(bgColors[rand.nextInt(6)]);

                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;

                TextStyle style = TextStyle(color: Colors.white);

                return Container(
                    margin: EdgeInsets.only(top: 5),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      minLeadingWidth: 10,
                      tileColor: tileColor,
                      leading: Container(
                          child: Text(index.toString(), style: style),
                          padding: EdgeInsets.only(top: 10)),
                      trailing: Text(data['money_amount'], style: style),
                      title: Text(data['name'], style: style),
                      subtitle: Text(data['date'], style: style),
                      onLongPress: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Remove?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => {
                                Navigator.pop(context, 'OK'),
                                collection.doc(document.id).delete()
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      ),
                    ));
              }).toList(),
      );
    },
  );
}
