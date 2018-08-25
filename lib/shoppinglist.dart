
import 'shoppingitem.dart';
import 'storage.dart';
import 'dart:io';

class ShoppingList {

  static String completed;
  static List<String> listNames = [];
  static List<List<dynamic>>listIndex =[[],[]];
  static init() async
  {

    await Storage.initStorage();
    listIndex = await Storage.getExistingListNames() as List<List<dynamic>>;
  }


  static checkName(String incomingName) async {
    String rv;
    completed=null;
    var suspect = await Storage.countQuery(
        "SELECT count(*) FROM allLists WHERE name = ?",
        [incomingName]);
    if(completed != null)
    {
      rv = "Error:$completed";
      return rv;
    }
    if(suspect > 0)
    {
      rv="There is already a shopping list named '$incomingName'";
    }
    return rv;
  }
  static bool isReady()
  {
    return Storage.isReady();
  }

  static setMostRecentList(int listID) async
  {
    completed = null;
    String goods = await Storage.putConfigValue("last_list_id","$listID") as String;

    if(goods != "OK")
    {
      if(goods.startsWith("USER:"))
      {
        //the user put in something that isn't gonna work
        completed =  goods.replaceFirst("USER:", "");
      }
      else {
        //something database-related went wrong;
        completed = "Error:$goods\n-from setMostRecentList $listID";
      }
    }
  }

  static getMostRecentList() async
  {
    var rv;
    var finalID;
    var prospect = await Storage.getConfigValue("last_list_id") as String;
    if(prospect.isEmpty)
    {
      rv = await getNthList(0);
      return rv;
    }
    finalID = int.tryParse(prospect);
    if(finalID == null){
      rv = await getNthList(0);
    }
    else {
      rv = await Storage.getListByID(finalID);
    }
    rv.listContents=null;
    return rv;
  }
  static getMostRecentListName() async
  {
    String rv;
    if(listNames.isEmpty)
    {
      listNames=await _getExistingListNames() as List<String>;
    }
    if(listNames.isEmpty)
    {
      return rv;
    }
    if(listNames.length > 2)
    {
      rv=listNames[1];
    }
    else
    {
      rv=listNames[0];
    }
    return rv;
  }

  static  _getExistingListNames() async {
    listIndex = await Storage.getExistingListNames() as List<List<dynamic>>;

    var aha=listIndex[0];
    return aha;
    //this block is for putting in test data (FLJ, 8/15/18)
/*
    if(aha.isEmpty)
    {
      ShoppingList tempList;


      tempList=new ShoppingList("Taco fixings");
      await tempList.checkResult();
      if(completed !=null)
      {
        return aha;
      }
      tempList.addItem(new ShoppingItem("tomatoes", 1, qty: 1.25));
      tempList.addItem(new ShoppingItem("lettuce", 1.49, details: "For iceberg??"));
      tempList.addItem(new ShoppingItem("cheddar", 1.99));
      tempList.addItem(new ShoppingItem("ground turkey", 3.49));
      tempList.addItem(new ShoppingItem("corn shells", 1.50));
      tempList.addItem(new ShoppingItem("tortillas", 2.50));

      tempList = new ShoppingList("hardware store");
      await tempList.checkResult();
      tempList.addItem(new ShoppingItem("spackle", 7.50));
      tempList = new ShoppingList("WMT");
      await tempList.checkResult();
      tempList = new ShoppingList("Acme");
      await tempList.checkResult();
      listIndex = await Storage.getExistingListNames() as List<List<dynamic>>;
      aha=listIndex[0];
    }

    //TODO:"select distinct(listName) from shoppinglist"
    return aha;
    */
  }
  static get existingListNames async{

    if(listNames.isEmpty)
    {
      listNames= await _getExistingListNames() as List<String>;
    }
    return listNames;
  }



  //listContents is here as a cache of sorts; DB access takes a good bit
  List<ShoppingItem>listContents;

  num id=-1;
  String name;


  ShoppingList(String inName) {
    assert(inName != null && inName.isNotEmpty);
    name=inName;
    listContents=null;
    completed = null;

  }

  ShoppingList.fromFile(int extantID,String extantName)
  {
    id=extantID;
    name=extantName;
    listContents=null;
    completed = null;
  }

  checkResult() async {
    String goods = await Storage.addShoppingList(this) as String;
    if(goods != "OK")
    {
      if(goods.startsWith("USER:"))
      {
        //the user put in something that isn't gonna work
        completed =  goods.replaceFirst("USER:", "");
      }
      else {
        //something database-related went wrong;
      completed = "Error:$goods\n-from new ShoppingList ${this.name}";
      }
    }
    //assert( goods == "OK", goods);
  }

  String poopLoop() {
    while(completed == null)
    {
      sleep(new Duration(milliseconds: 100));
    }
    return "AH";
  }

  static newList(String name) async {
    ShoppingList rv = new ShoppingList(name);
    await rv.checkResult();
    listNames.clear();
    return rv;
  }
  static getNthList(int n) async
  {
    ShoppingList rv;
//    var prospects=Storage.getExistingListNames();
    listIndex = await Storage.getExistingListNames() as List<List<dynamic>>;
    var suspects=listIndex[1];
    if(suspects.isEmpty)
    {
      return rv;
    }
    assert(n > -1 && n < suspects.length);

    rv=await Storage.getListByID(suspects[n]) as ShoppingList;
    assert(rv != null);
    //print("GOT $n:${rv.name}");
    rv.listContents=null;
    return rv;
  }
  String get runningTotal {
    var total=0.0;
    //this may be less resource-intensive than foisting it off on the DB engine
    if(listContents==null)
    {
      listContents=Storage.getListItems(id);
    }
    var count=listContents.length;
    for(num i=0;i<count;i++)
    {
      if(listContents[i].qty > 0) {
        total += listContents[i]
            .linetotal; //if "friend" classes were possible in Dart...linetotal would be protected
      }
    }



    //TODO:""select sum(item.rowTotal) as total from shoppinglist join item on itemId=item.id where listName = ? and qty>0"
    //first bound param is this.name

    return Storage.moneyFormatter.format(total);
  }

  //TODO: Item getItem(itemId)
  //"select * from item where id = ? and list_name = ?",arrayOf(itemId!!,this.name)

  getList() async
  {
    if(listContents == null)
    {
      listContents=await Storage.getListItems(id);
    }
    /*
  TODO:"select * from item where id in (select itemId from shoppinglist where listName = ?)",
  arrayOf(this.name)
  */

    return listContents;
  }


  addItemByID(int itemID) async
  {

    completed = null;
    var result = await Storage.addItemToList(this.id,itemID) as String;

    var rv;
    if(result != "OK")
    {

        var placeOfUserErr = result.indexOf("USER:");
        if( placeOfUserErr > -1)
        {
          rv = result.substring(placeOfUserErr + 5);
        }
        else
        {
          rv = "Error:$result\n-from new ShoppingItem ${this.name}";
        }
          completed =rv;
    }

    //force a reload;
    listContents = null;
  }

  addItem(ShoppingItem incoming)
  {
    this.addItemByID(incoming.id);
  }

  removeItem(ShoppingItem item) async
  {
    completed = null;
    var rv = await item.update(qty:"0",name:item.name,total: "${item.linetotal}",details:item.notes) as String;
    if(rv != "OK")
    {
      completed=rv;
    }
  }
}