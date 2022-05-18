import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:todo/models/item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:todo/home/donnees_vides.dart';
import 'package:todo/services/databaseClient.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My ToDo App',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MyHomePage(title: 'My Todo App'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double pad = 15.0;
  List<Item> items = [];
  String? nouvelleTache;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recuperer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          GestureDetector(
            onTap: () {
              ajouter(null);
            },
            child: Container(
                padding: EdgeInsets.only(right: pad),
                child: Row(
                  children: [const Icon(Icons.add), const Text("Ajouter")],
                )),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(pad),
        child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              Item item = items[index];
              return ListTile(
                title: Text(
                  item.nom ?? "No name",
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      DatabaseClient().delete(item.id ?? 0, 'item').then((i) {
                        print("Nombre d'éléments supprimés est : $i");
                        recuperer();
                      });
                    }),
                leading: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: (() => ajouter(item))),
              );
            }),
      ),
    );
  }

  void recuperer() {
    DatabaseClient().allItem().then((item) {
      setState(() {
        items = item;
      });
    });
  }

  Future<void> ajouter(Item? item) async {
    final elem = item;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Ajouter une liste de taches'),
          //  content: Text('DialBody'),
          content: TextField(
            decoration: InputDecoration(
              labelText: "Element",
              hintText: item?.nom ?? "exemple : ma prochaine tache",
            ),
            onChanged: (str) {
              setState(() {
                nouvelleTache = str;
              });
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler', style: TextStyle(color: Colors.red)),
              onPressed: () {
                //  Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                Navigator.pop(dialogContext);
              },
            ),
            TextButton(
              child:
                  const Text('Valider', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                if (nouvelleTache != null) {
                  Map<String, dynamic> map = {
                    'id': elem?.id,
                    'nom': nouvelleTache
                  };
                  Item item = Item(map);

                  // add to bd (ajouter item) and set to state (recuperer)

                  DatabaseClient()
                      .update_or_insert(item)
                      .then((value) => recuperer());
                }
                setState(() {
                  nouvelleTache = null;
                });

                // Ajouter le code pour l'insertion dans la base de données
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
          ],
        );
      },
    );
  }
}
