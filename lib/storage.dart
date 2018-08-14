import 'package:intl/intl.dart';
import 'shoppinglist.dart';
import 'shoppingitem.dart';
class Storage {

  static NumberFormat moneyFormatter= new NumberFormat.simpleCurrency();
  static NumberFormat qtyFormatter = new NumberFormat("####.##");

  static Map<int, ShoppingItem> allItems = new Map();
  static Map<int, ShoppingList> allLists = new Map();
  static Map<int, Map<int,bool>> listsToItems = new Map();

  static addShoppingList(ShoppingList incoming)
  {
    assert(incoming != null);
    var truid=allLists.length+1;
    //TODO:set truid to result of DB insert
    incoming.id=truid;
    allLists[truid]=incoming;
  }
  static addShoppingItem(ShoppingItem incoming){
    assert(incoming != null);
    var truid=allItems.length+1;
    //TODO:set truid to result of DB insert
    incoming.id=truid;
    allItems[truid]=incoming;
  }



  static updateShoppingItem(ShoppingItem incoming) {
    //TODO:DB update
  }
  static List<ShoppingItem> getListItems(int listID) {
    List<ShoppingItem> rv=new List();

    if(listsToItems.containsKey(listID)) {
      var entry=listsToItems[listID];
      var itemIds = entry.keys.toList();
      var totalcount = itemIds.length;
      for (num i = 0; i < totalcount; i++) {
        var proto = allItems[itemIds[i]];
        //TODO:the real deal calls the ShoppingItem constructor that assigns an ID
        rv.add(proto);
      }
    }
    return rv;
  }

  static List<List> getExistingListNames() {
    List<String> rv=new List();
    List<int> ids=[];

    var listIds=allLists.keys.toList();
    var totalcount=listIds.length;
    for(num i=0;i<totalcount;i++)
    {
      var proto=allLists[listIds[i]];
      //TODO:the real deal calls the ShoppingList constructor that assigns an ID
      rv.add(proto.name);
      ids.add(proto.id);
    }
    return [rv,ids];
  }

  static ShoppingList getListByID(int id)
  {
    ShoppingList rv;
    if(allLists.containsKey(id))
    {
       rv=allLists[id];
    }
    return rv;
  }

  //this is where get hairy:connect items to lists
  static addItemToList(listID,itemID)
  {
    Map<int,bool> entry;
    if(listsToItems.containsKey(listID)) {
      entry = listsToItems[listID];
    }
    else {
      entry = new Map();
    }
    entry[itemID]=true;
    listsToItems[listID] = entry;
  }

}