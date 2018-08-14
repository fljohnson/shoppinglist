
import 'shoppingitem.dart';
import 'storage.dart';

class ShoppingList {

  static List<String> listNames = [];
  static String getMostRecentListName()
  {
    String rv;
    if(listNames.isEmpty)
    {
      listNames=_getExistingListNames();
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

  static List<String> _getExistingListNames() {
    var aha=Storage.getExistingListNames()[0];
    if(aha.isEmpty)
    {
      ShoppingList tempList;

      tempList=new ShoppingList("Taco fixings");
      tempList.addItem(new ShoppingItem("tomatoes", 1, qty: 1.25));
      tempList.addItem(new ShoppingItem("lettuce", 1.49, details: "For iceberg??"));
      tempList.addItem(new ShoppingItem("cheddar", 1.99));
      tempList.addItem(new ShoppingItem("ground turkey", 3.49));
      tempList.addItem(new ShoppingItem("corn shells", 1.50));
      tempList.addItem(new ShoppingItem("tortillas", 2.50));

      tempList=new ShoppingList("hardware store");
      tempList.addItem(new ShoppingItem("spackle", 7.50));
      new ShoppingList("WMT");
      new ShoppingList("Acme");

      aha=Storage.getExistingListNames()[0];
    }
    //TODO:"select distinct(listName) from shoppinglist"
    return aha;
  }
  static List<String> get existingListNames {

    if(listNames.isEmpty)
    {
      listNames=_getExistingListNames();
    }
    return listNames;
  }



  //listContents is here as a cache of sorts; DB access takes a good bit
  List<ShoppingItem>listContents;

  num id=-1;
  String name;

  ShoppingList(String inName){
    assert(inName != null && inName.isNotEmpty);
    name=inName;
    listContents=null;
    Storage.addShoppingList(this);
  }

  static ShoppingList getNthList(int n)
  {
    ShoppingList rv;
    var suspects=Storage.getExistingListNames()[1];
    assert(n > -1 && n < suspects.length);

    rv=Storage.getListByID(suspects[n]);
    assert(rv != null);
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

  List<ShoppingItem> getList()
  {
    if(listContents == null)
    {
      listContents=Storage.getListItems(id);
    }
    /*
  TODO:"select * from item where id in (select itemId from shoppinglist where listName = ?)",
  arrayOf(this.name)
  */
    return listContents;
  }


  addItemByID(int itemID)
  {
    //TODO:"insert into shoppinglist values(this.name,itemID)"
    Storage.addItemToList(this.id,itemID);
    //force a reload;
    listContents = null;
  }

  addItem(ShoppingItem incoming)
  {
    this.addItemByID(incoming.id);
  }

  removeItem(ShoppingItem item)
  {
    //TODO:define ShoppingItem.delete();
    item.update(qty:"0",name:item.name,total: "${item.linetotal}",details:item.notes);
  }
}