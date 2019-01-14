import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(),
    );
  }
}


class MyHomePage extends StatelessWidget {
  String name;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Training'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {

              showDialog(
                  context: context,
                  child: new AlertDialog(
                    title: new Text("Add new Vote"),
                    content: new TextField(
                      decoration: new InputDecoration(
                          labelText: "Enter Name"
                      ),
                      onChanged: (String text) {
                        name = text;
                      },
                    ),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text("Cancel"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      new FlatButton(
                        child: new Text("Add"),
                        onPressed: () =>   Firestore.instance.collection('flutter_data').document()
                            .setData({ "name": name,"vote": 0 }),
                      )
                    ],
                  )
              );

            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('flutter_data').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
         // return test(documents: snapshot.data.documents);
          return test();
        },
      ),
    );
  }
}
class test extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }
  Widget _buildBody(BuildContext context) {
    // TODO: get actual snapshot from Cloud Firestore
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('flutter_data').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context,List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

 /*   return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.name),
          trailing: Text(record.votes.toString()),
        isThreeLine: true,
        //  onTap: () => print(record),
            onTap: () => record.reference.updateData({'vote': record.votes + 1})
        ),
      ),
    );*/
//main
    return new Padding(padding: new EdgeInsets.all(1.0),
        child: new Card(
          child: new Column(
            children: <Widget>[
              new ListTile(
                title: new Text(
                    record.name
                ),
                subtitle: new Text(
                   "Votes: "+record.votes.toString()
                ),
              ),
              new Row(

                  children: <Widget>[
                    IconButton(
                      icon: new Icon(Icons.thumb_up),
                      alignment: Alignment.center,
                      padding: new EdgeInsets.all(5.0),
                      onPressed: () {
                        record.reference.updateData({'vote': record.votes + 1});
                      },
                    ),

                    new Text(
                      "Vote",
                      style: new TextStyle(fontSize:12.0,
                          color: const Color(0xFF000000)),
                    )
                  ]

              ),
            ],
          ),
        )
    );
  }

}

class Record {
  final String name;
  final int votes;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['vote'] != null),
        name = map['name'],
        votes = map['vote'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$votes>";
}