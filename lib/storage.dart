import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'shoppinglist.dart';
import 'shoppingitem.dart';
class Storage {

  static NumberFormat moneyFormatter= new NumberFormat.simpleCurrency();
  static NumberFormat qtyFormatter = new NumberFormat("####.##");

  static Database _realdatabase;
  

  static Map<int, ShoppingItem> allItems = new Map();
  static Map<int, ShoppingList> allLists = new Map();
  static Map<int, Map<int,bool>> listsToItems = new Map();

  static initStorage() async
  {

    await _heavyDatabase();
    return 1;
  }

  static bool isReady()
  {
    return _realdatabase != null;
  }

  static Database get _database
  {
    if(_realdatabase != null) {
      return _realdatabase;
    }
  }


  static  _heavyDatabase() async {

    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "demo2.db");
    //var hold = await deleteDatabase(path);
    path = join(databasesPath, "demo2.db");
    _realdatabase =  await openDatabase(path, version: 3,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await _versionOnePointO(db, version);
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          await _masterUpgrade(db,oldVersion,newVersion);
        }
    );

  }

  static _versionOnePointO(Database db,int version)
  {
    /*
    db.execute(
        "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)");
    */
    return db.transaction((txn) async {
      await txn.execute(
          "CREATE TABLE allLists (id INTEGER PRIMARY KEY autoincrement, name TEXT)"
      );
      await txn.execute(
          "CREATE TABLE allItems (id INTEGER PRIMARY KEY autoincrement, name TEXT,qty REAL,linetotal REAL,notes TEXT)"
      );

      await txn.execute(
          "CREATE TABLE listsToItems (listID INTEGER, itemID INTEGER)"
      );
      await txn.execute(
          "CREATE INDEX listsToItems_IDX_list on listsToItems(listID)"
      );
      await txn.execute(
          "CREATE TABLE autoCompletes (namekey TEXT NOT NULL PRIMARY KEY,propername TEXT)"
      );
      /*
      int id1 = await txn.rawInsert(
          'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
      print("inserted1: $id1");
      int id2 = await txn.rawInsert(
          'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
          ["another name", 12345678, 3.1416]);
      print("inserted2: $id2");
      */
    });
    //uncertain if onUpgrade called by framework after this

  }
  static _masterUpgrade(Database db, int oldVersion, int newVersion)
  {
    //this is where a loop from oldVersion to newVersion goes
    //the body is a switch statement, each match invoking a structure change
    for (var i=oldVersion;i<newVersion;i++)
    {
      switch(i)
      {
        case 1:
          _moveToV2(db);
          break;
        case 2:
          _moveToV3(db);
          break;
      }
    }
  }

  static _moveToV2(db)
  {
    return db.transaction((txn) async {
      await txn.execute(
          "CREATE TABLE autoCompletes (namekey TEXT NOT NULL PRIMARY KEY,propername TEXT)"
      );
    });
  }

  static _moveToV3(db)
  {
    return db.transaction((txn) async {
      await txn.execute(
          "CREATE TABLE config (namekey TEXT NOT NULL PRIMARY KEY,val TEXT)"
      );
      print("just moved to version 3");
    });
  }

  static putConfigValue(String key,String value) async
  {
    assert(key != null && key.isNotEmpty);
    try {
      var tuple = Map<String,String>();
      tuple["namekey"] = key;
      tuple["val"] = value;
      await _database.transaction((txn) async {
        await txn.insert("config", tuple,conflictAlgorithm: ConflictAlgorithm.replace);
      });
      return "OK";
    }
    catch(ecch)
    {
      return ecch.toString();
    }
  }

  static getConfigValue(String key) async
  {
    assert(key != null && key.isNotEmpty);
    var sql="select val from config  where namekey = ? ";
    var params=[key];
    try {
      var theValue = await _database.transaction((txn) async {
        var goods = await txn.rawQuery(
            sql,
            params);

        var numRecords=goods.length;

        if(numRecords == 0)
        {
          return "";
        }
        var fields = goods[0].keys.toList();
        return goods[0][fields[0]] as String;
      });

      return theValue;
    }
    catch(ecch)
    {
      ShoppingList.completed = ecch.toString();
    }
  }
  static countQuery(String sql,List<dynamic> params) async
  {
    try {

      var theCount = await _database.transaction((txn) async {
          List<Map<String, dynamic>> goods = await txn.rawQuery(
          sql,
          params);


          var fields = goods[0].keys.toList();
          //a cheat of sorts
      return goods[0][fields[0]] as int;
    });

    return theCount;

    }
    catch(ecch)
    {
      ShoppingList.completed = ecch.toString();
    }
  }
  static addShoppingList(ShoppingList incoming) async
  {
    assert(incoming != null);

try {
  await _database.transaction((txn) async {
    /*
    //This is the outline of a Query
    List<Map<String, dynamic>> goods = await txn.rawQuery(
       "SELECT count(*) FROM allLists WHERE name = ?",
        [incoming.name]);
    var id2 = -1;
    var fields = goods[0].keys.toList();
    //a cheat of sorts
    id2 = goods[0][fields[0]] as int;


    //this is sort of how to do it when we have no idea what the fields are
    var count = fields.length;
    for(var i=0;i<count;i++)
      {
        id2 = goods[0][fields[i]] as int;
      }

//if some untoward data showed up, throw an Exception(what was wrong);
   return id2;
   */


    int id1 = await txn.rawInsert(
        'INSERT INTO allLists(name) VALUES(?)', [incoming.name]);

    //print("NEW ID:$id1");
    incoming.id = id1;
    return id1;


  }) ;


  return "OK";
}
catch(ecch)
  {
    return ecch.toString();
  }
    /*
  }).then((value){
    truid = value;
    incoming.id=truid;
    allLists[truid]=incoming;
    return "OK";
  }).catchError((error){
    return error.toString();
    //assert(error == null,error.toString());
  }) ;
  */



  }
  static addShoppingItem(ShoppingItem incoming) async {
    assert(incoming != null);
    /*
    var truid=allItems.length+1;
    //TODO:set truid to result of DB insert
    incoming.id=truid;
    allItems[truid]=incoming;
    */
    try {
      await _database.transaction((txn) async {

      //throw Exception("USER:magical goof");

        int id1 = await txn.rawInsert(
            'INSERT INTO allItems(name,qty,linetotal,notes) VALUES(?,?,?,?)', [incoming.name,incoming.qty,incoming.linetotal,incoming.notes]
        );

        incoming.id = id1;

        //now, the autoComplete table
        //this is a bit dirty, IMHO, but it may save some code
        var lowered = incoming.name.toLowerCase();
        var tuple = Map<String,String>();
        tuple["namekey"] = lowered;
        tuple["propername"] = incoming.name;
        await txn.insert("autoCompletes", tuple,conflictAlgorithm: ConflictAlgorithm.replace);
        //that is, I deferred to the conflict-handling facilities of the DB engine to handle preexistence

        
        
        return id1;


      }) ;


      return "OK";
    }
    catch(ecch)
    {
      return ecch.toString();
    }
  }



  static updateShoppingItem(ShoppingItem incoming) async {
    //DB update
    assert(incoming != null);
    try {
      await _database.transaction((txn) async {

        //throw Exception("USER:magical goof");

        int affected = await txn.rawUpdate(
            'UPDATE allItems SET name=?,qty=?,linetotal=?,notes=? where id=?', [incoming.name,incoming.qty,incoming.linetotal,incoming.notes,incoming.id]
        );




        return affected;


      }) ;


      return "OK";
    }
    catch(ecch)
    {
      return ecch.toString();
    }
  }
  static getListItems(int listID) async {
    List<ShoppingItem> rv=new List();


    var sql="select * from listsToItems join allItems on itemID=allItems.id where listID = ?";
    var params=[listID];

    try {
      await _database.transaction((txn) async {

        List<Map<String, dynamic>> goods = await txn.rawQuery(
            sql,
            params);

        var numRecords=goods.length;

        ShoppingItem incoming;

        for(var j=0;j<numRecords;j++)
        {

          incoming = ShoppingItem.fromFile(
            goods[j]
          );
          rv.add(incoming);

        }


      });

    }
    catch(ecch)
    {
      ShoppingList.completed = ecch.toString();
    }

    if(listsToItems.containsKey(listID)) {
      var entry=listsToItems[listID];
      var itemIds = entry.keys.toList();
      var totalcount = itemIds.length;
      for (num i = 0; i < totalcount; i++) {
        var proto = allItems[itemIds[i]];

        rv.add(proto);
      }
    }
    return rv;
  }

  static  getExistingListNames() async {
    List<String> rv=new List();
    List<int> ids=[];
/*
    var listIds=allLists.keys.toList();
    var totalcount=listIds.length;

    for(num i=0;i<totalcount;i++)
    {
      var proto=allLists[listIds[i]];

      rv.add(proto.name);
      ids.add(proto.id);
    }*/

    var sql="SELECT id,name FROM allLists";
    var params =[];


    try {
     await _database.transaction((txn) async {

        List<Map<String, dynamic>> goods = await txn.rawQuery(
            sql,
            params);

        var fields;

        var numFields;
        var numRecords=goods.length;

        for(var j=0;j<numRecords;j++)
        {

          fields = goods[j].keys.toList();
          numFields = fields.length;
          for(var i=0;i<numFields;i++)
          {
            if(fields[i] == "id")
            {
              ids.add(goods[j][fields[i]] as int);
            }
            if(fields[i] == "name")
            {
              rv.add(goods[j][fields[i]] as String);
            }
          }
        }


      });

    }
    catch(ecch)
    {
      ShoppingList.completed = ecch.toString();
    }

    return [rv,ids];
  }

  static getListByID(int id) async
  {
    ShoppingList rv;

    var sql="SELECT * FROM allLists where id = ?";
    var params =[id.toString()];

    try {
      await _database.transaction((txn) async {

        List<Map<String, dynamic>> goods = await txn.rawQuery(
            sql,
            params);

        var fields;

        var numFields;
        var numRecords=goods.length;

        var extantID;
        var extantName;
        for(var j=0;j<numRecords;j++)
        {

          extantID = -1;
          extantName = null;

          fields = goods[j].keys.toList();
          numFields = fields.length;
          for(var i=0;i<numFields;i++)
          {
            if(fields[i] == "id")
            {
              extantID = (goods[j][fields[i]] as int);
            }
            if(fields[i] == "name")
            {
              extantName = (goods[j][fields[i]] as String);
            }
          }

          if(extantID > 0 && extantName != null) {
            rv=ShoppingList.fromFile(extantID,extantName);
          }
        }


      });

    }
    catch(ecch)
    {
      ShoppingList.completed = ecch.toString();
    }

    return rv;


    /*
    if(allLists.containsKey(id))
    {
       rv=allLists[id];

    }
    */



  }

  //this is where get hairy:connect items to lists
  static addItemToList(listID,itemID) async
  {
    /*
    Map<int,bool> entry;
    if(listsToItems.containsKey(listID)) {
      entry = listsToItems[listID];
    }
    else {
      entry = new Map();
    }
    entry[itemID]=true;
    listsToItems[listID] = entry;
    */
    assert(listID > -1 && itemID > -1,"list and item IDs are messed up");
    try {
      await _database.transaction((txn) async {




        int id1 = await txn.rawInsert(
            'INSERT INTO listsToItems(listID,itemID) VALUES(?,?)', [listID,itemID]);


        return id1;


      }) ;


      return "OK";
    }
    catch(ecch)
    {
      return ecch.toString();
    }

  }
  static num roundToPlaces(num raw,int places)
  {
      num rv=raw;
      int multiplier = 1;
      try {
        multiplier = pow(10, places).toInt();
      }
      catch(ecch)
      {
        print("FAIL!"+ecch.toString());
      }
      rv *= multiplier;
      rv = rv.round()/multiplier;
      return rv;
  }

}
