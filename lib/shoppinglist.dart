
import 'shoppingitem.dart';
import 'storage.dart';

class ShoppingList {

  static List<String> get existingListNames {
    var rv=[];
    rv.add("hardware store");
    rv.add("WMT");
    rv.add("Taco fixings");
    //TODO:"select distinct(listName) from shoppinglist"
    return rv;
  }

  //listContents is here as a cache of sorts; DB access takes a good bit
  List<ShoppingItem>listContents;

  ShoppingList(){

    listContents=null;

    ShoppingItem("tomatoes",1,qty:1.25);
    ShoppingItem("lettuce",1.49,details:"For iceberg??");
    ShoppingItem("cheddar",1.99);
    ShoppingItem("ground turkey",3.49);
    ShoppingItem("corn shells",1.50);
    ShoppingItem("tortillas",2.50);
  }

  String name;
  String get runningTotal {
    var total=0.0;
    //this may be less resource-intensive than foisting it off on the DB engine
    if(listContents==null)
    {
      listContents=Storage.getListItems();
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
      listContents=Storage.getListItems();
    }
    /*
  TODO:"select * from item where id in (select itemId from shoppinglist where listName = ?)",
  arrayOf(this.name)
  */
    return listContents;
  }


  addItem(int itemID)
  {
    //TODO:"insert into shoppinglist values(this.name,itemID)"
    //force a reload;
    listContents = null;
  }

  removeItem(ShoppingItem item)
  {
    //TODO:define ShoppingItem.delete();
    item.update(qty:"0",name:item.name,total: "${item.linetotal}",details:item.notes);
  }
}