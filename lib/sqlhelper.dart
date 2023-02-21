import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLhelper {
  static Future<void>createtables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   title TEXT,
   description TEXT
   createdAT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)
   """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'tabledata.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createtables(database);
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getitems() async {
    final db = await SQLhelper.db();
    return db.query('items', orderBy: "id");
  }
  static Future<int>createitems(String title,String? descrption)async {
    final db = await SQLhelper.db();
    final data = {'title': title, 'description': descrption};
    final id = await db.insert(
        'items', data);
    return id;
  }
  static Future<int>updateitem(int id,String title,String?description)async{
    final db=await SQLhelper.db();
    final data={'title':title,'description':description,'createdAt':DateTime.now().toString()};
    final result=db.update('items',data, where: 'id=?',whereArgs: [id]);
    return result;
  }
  static Future<void>deleteitem(int id)async{
    final db=await SQLhelper.db();
    try{
      await db.delete('items',where: 'id=?',whereArgs: [id]);
    }catch(e){
      debugPrint(e.toString());
    }
  }
}
