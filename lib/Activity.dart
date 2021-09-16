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

class _Activity extends State<Activity> {
  CollectionReference history =
      FirebaseFirestore.instance.collection('history');
  final Stream<QuerySnapshot> historyStream = FirebaseFirestore.instance
      .collection('history')
      .orderBy('date', descending: true)
      .snapshots();

  Random rand = new Random();

  @override
  void initState() {
    super.initState();
    if (null == FirebaseAuth.instance.currentUser) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Authenticate()));
    }
  }

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
                date = DateTime.now().toString(),
                history.add({
                  'name': FirebaseAuth.instance.currentUser!.displayName,
                  'money_amount': '1 万',
                  'date': date.substring(0, date.length - 7)
                })
              }
          },
        ),
        appBar: AppBar(
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
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: historyStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                          ));
                    }).toList(),
            );
          },
        ));
  }
}
