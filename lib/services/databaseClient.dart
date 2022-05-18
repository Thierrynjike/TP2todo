import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:io'; // pour l'utilisation de la classe Directory
import 'package:todo/models/item.dart';

class DatabaseClient {
  Database? _database;

  Future<Database?> get database async {
    return _database ?? await create();
  }

  Future create() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String database_directory = p.join(directory.path, 'database.db');

    var bdd =
        await openDatabase(database_directory, version: 1, onCreate: _onCreate);
    return bdd;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE IF NOT EXISTS item (id INTEGER PRIMARY KEY, nom TEXT)");
    print("database created!");
    await db.insert("item", {'nom': 'tache1'});
  }

  // Ecriture des données
  Future<Item> ajouItem(Item item) async {
    Database? maDatabase = await database; // fait appel au get database
    item.id = await maDatabase?.insert('item',
        item.toMap()); // la fontion insert renvoie un id qui va initialiser l'id de l'item en cours
    return item;
  }

  // Lecture des données
  Future<List<Item>> allItem() async {
    Database? maDatabase = await database;
    List<Map<String, dynamic>>? resultat = await maDatabase?.rawQuery(
        'select * FROM item'); // Une liste de maps, chaque enregistrement est une //map composée de clés valeurs nom, nom et id id
    List<Item> items = [];
    resultat?.forEach((map) {
      Item item = Item(map);
      items.add(item);
    });
    return items;
  }

  Future<int?> delete(int id, String table) async {
    Database? maDatabase = await database;
    return await maDatabase?.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int?> updateItem(Item item) async {
    Database? maDatabase = await database;
    return await maDatabase
        ?.update('item', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> update_or_insert(Item item) async {
    Database? maDatabase = await database;
    if (item.id == null) {
      await maDatabase?.insert('item', item.toMap());
    } else {
      await maDatabase
          ?.update('item', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
    }
  }
}
